if Sky.Config.phone ~= "sky" then return end

function Sky.Functions.GetPhoneCallCapabilities()
    local controls = false
    if IsDuplicityVersion() and GetResourceState("sky_phone") == "started" then
        local api = exports["sky_phone"]:GetApiCapabilities()
        controls = api.ready and api.features.calls.externalControl == true
    end
    return { provider = "sky", observe = controls, poll = false, answer = controls,
        finish = controls, decline = controls, availability = controls }
end

function Sky.Functions.GetPhoneCall(source, call_id)
    if not IsDuplicityVersion() then return nil, "server_only" end
    if GetResourceState("sky_phone") ~= "started" then return nil, "phone_unavailable" end
    local call, error_code
    if source == nil then
        call, error_code = exports["sky_phone"]:GetActiveCallById(call_id)
    else
        call, error_code = exports["sky_phone"]:GetActiveCallBySource(source)
    end
    if not call or call_id and call.id ~= call_id then return nil, error_code or "call_not_found" end
    return {
        id = call.id,
        provider = "sky",
        state = call.state,
        direction = call.direction,
        serviceCall = call.serviceCall,
        anonymous = call.anonymous,
        number = call.anonymous and "" or call.otherNumber,
        companyId = call.companyId,
        recipientSource = call.state == "connected" and call.callee.source or nil
    }
end

function Sky.Functions.ControlPhoneCall(source, call_id, action)
    local capabilities = Sky.Functions.GetPhoneCallCapabilities()
    if not capabilities[action == "accept" and "answer" or action] then
        Sky.Debug("warn", "sky_phone does not expose the requested authoritative call action: %s.", tostring(action))
        return { success = false, error = "unsupported_phone" }
    end
    local call, error_code = Sky.Functions.GetPhoneCall(source, call_id)
    if not call or call.direction ~= "incoming" or not call.serviceCall then
        return { success = false, error = error_code or "call_not_found" }
    end
    if action == "accept" then
        if call.state == "connected" then return { success = true, data = call } end
        local result, answer_error = exports["sky_phone"]:AnswerCallForSource(source, { id = call_id })
        return result or { success = false, error = answer_error }
    end
    if action == "finish" then
        local success, end_error = exports["sky_phone"]:EndCallForSource(source)
        return { success = success == true, error = end_error }
    end
    return { success = false, error = "unsupported_call_action" }
end

function Sky.Functions.SetPhoneDispatchAvailability(source, enabled)
    if not Sky.Functions.GetPhoneCallCapabilities().availability then
        return { success = false, error = "unsupported_phone" }
    end
    local result, error_code = exports["sky_phone"]:SetCallAvailabilityForSource(source, { available = enabled, dispatcher = enabled })
    return result or { success = false, error = error_code }
end

if IsDuplicityVersion() and GetCurrentResourceName() == "sky_base" then
    AddEventHandler("sky_phone:server:apiReady", function()
        TriggerEvent("sky_base:phone:ready")
    end)
    AddEventHandler("onServerResourceStart", function(resource_name)
        if resource_name == "sky_phone" and Sky.Functions.GetPhoneCallCapabilities().availability then
            TriggerEvent("sky_base:phone:ready")
        end
    end)
    AddEventHandler("sky_phone:server:callChanged", function(source, call)
        if call.serviceCall and call.direction == "incoming" then
            TriggerEvent("sky_base:phone:callChanged", source, call.id, call.state)
        end
    end)
end

local custom_app_resources = {}

local social_media_tracking_platforms = {
    "twitter",
    "instagram",
    "tiktok",
    "darkchat",
    "tinder"
}

local social_media_tracking_queries = {
    twitter = [[
        SELECT s.`phone_number`
        FROM `sky_phone_feather_profiles` p
        JOIN `sky_phone_devices` d ON d.`account_id` = p.`account_id`
        JOIN `sky_phone_sims` s ON s.`id` = d.`sim_id`
        WHERE p.`handle` = ?
        ORDER BY d.`updated_at` DESC
        LIMIT 1
    ]],
    instagram = [[
        SELECT s.`phone_number`
        FROM `sky_phone_picstagram_profiles` p
        JOIN `sky_phone_picstagram_sessions` ps ON ps.`profile_id` = p.`id`
        JOIN `sky_phone_devices` d ON d.`imei` = ps.`device_imei`
        JOIN `sky_phone_sims` s ON s.`id` = d.`sim_id`
        WHERE p.`handle` = ?
        ORDER BY ps.`updated_at` DESC
        LIMIT 1
    ]],
    tiktok = [[
        SELECT s.`phone_number`
        FROM `sky_phone_fliptok_profiles` p
        JOIN `sky_phone_fliptok_sessions` fs ON fs.`profile_id` = p.`id`
        JOIN `sky_phone_devices` d ON d.`imei` = fs.`device_imei`
        JOIN `sky_phone_sims` s ON s.`id` = d.`sim_id`
        WHERE p.`handle` = ?
        ORDER BY fs.`updated_at` DESC
        LIMIT 1
    ]],
    darkchat = [[
        SELECT s.`phone_number`
        FROM `sky_phone_darkchat_profiles` p
        JOIN `sky_phone_devices` d ON d.`account_id` = p.`account_id`
        JOIN `sky_phone_sims` s ON s.`id` = d.`sim_id`
        WHERE p.`dark_id` = ?
        ORDER BY d.`updated_at` DESC
        LIMIT 1
    ]],
    tinder = [[
        SELECT s.`phone_number`
        FROM `sky_phone_flare_profiles` p
        JOIN `sky_phone_devices` d ON d.`account_id` = p.`account_id`
        JOIN `sky_phone_sims` s ON s.`id` = d.`sim_id`
        WHERE p.`name` = ?
        ORDER BY d.`updated_at` DESC
        LIMIT 1
    ]]
}

local function append_query_parameter(url, key, value)
    local separator = url:find("?", 1, true) and "&" or "?"
    return ("%s%s%s=%s"):format(url, separator, key, tostring(value))
end

local function normalize_asset_url(value, resource)
    if type(value) ~= "string" or value == "" then
        return value
    end
    if value:find("^https?://") or value:find("^nui://") then
        return value
    end

    local resource_prefix = resource .. "/"
    if value:sub(1, #resource_prefix) == resource_prefix then
        return value
    end
    return resource_prefix .. value
end

local function build_app_url(app, resource)
    local url = app.url or app.ui or app.uiPath or "source/html/index.html"
    url = normalize_asset_url(url, resource)

    if app.route and not url:find("skyPhoneRoute=", 1, true) then
        url = append_query_parameter(url, "skyPhoneRoute", app.route)
    end
    if not url:find("skyPhone=", 1, true) then
        url = append_query_parameter(url, "skyPhone", "sky_phone")
    end
    return url
end

local function build_permissions(app)
    local permissions = {}
    local has_notifications = false
    for index = 1, #(app.permissions or {}) do
        local permission = app.permissions[index]
        permissions[#permissions + 1] = permission
        if permission == "notifications" then
            has_notifications = true
        end
    end
    if app.notification ~= false and not has_notifications then
        permissions[#permissions + 1] = "notifications"
    end
    return permissions
end

function Sky.Functions.GetPhoneTrackingCapabilities()
    return { phoneNumber = true, socialMedia = true }
end

function Sky.Functions.GetSocialMediaTrackingPlatforms()
    local platforms = {}
    for index = 1, #social_media_tracking_platforms do
        platforms[index] = social_media_tracking_platforms[index]
    end
    return platforms
end

function Sky.Functions.ResolveSocialMediaPhoneNumber(platform, username)
    if not IsDuplicityVersion() then
        return nil, "server_only"
    end

    platform = type(platform) == "string" and platform:match("^%s*(.-)%s*$"):lower() or nil
    local query = platform and social_media_tracking_queries[platform] or nil
    if not query then
        return nil, "unsupported_platform"
    end

    username = type(username) == "string" and username:match("^%s*(.-)%s*$") or nil
    if not username or username == "" then
        return nil, "invalid_username"
    end

    local rows = Sky.Query(query, { username }) or {}
    local phone_number = rows[1] and rows[1].phone_number
    if phone_number == nil then
        return nil, "not_found"
    end
    return tostring(phone_number)
end

function Sky.Functions.ChangeNumber()
    Sky.Debug("error", "sky_phone number changes are not exposed through its public API.")
    return false, "unsupported_phone"
end

function Sky.Functions.IsNumberUsed(phone_number)
    if not IsDuplicityVersion() then
        Sky.Debug("error", "sky_phone number checks are only available on the server.")
        return false
    end

    local sim, lookup_error = exports["sky_phone"]:GetStoredSimByPhoneNumber(phone_number)
    if lookup_error == "api_not_ready" then
        error("sky_phone number check failed because its server API is not ready")
    end
    return sim ~= nil
end

function Sky.Functions.RegisterCustomPhoneApp(app)
    if IsDuplicityVersion() then
        Sky.Debug("error", "sky_phone custom apps register on the client.")
        return false, "client_only"
    end
    if type(app) ~= "table" then
        Sky.Debug("error", "sky_phone custom app registration expected an app table, got %s.", type(app))
        return false, "invalid_app"
    end

    local resource = app.resource or GetInvokingResource() or GetCurrentResourceName()
    local removable = app.removable
    if removable == nil then
        removable = app.defaultApp ~= true
    end

    local registered, registration_error = exports["sky_phone"]:AddCustomApp({
        schemaVersion = 1,
        id = app.identifier,
        name = app.name,
        description = app.description,
        developer = app.developer,
        category = app.category or ((app.game == true or app.games == true) and "games" or "utilities"),
        ui = build_app_url(app, resource),
        assetResource = resource,
        bridgeMode = app.bridgeMode or "legacy",
        icon = normalize_asset_url(app.icon, resource),
        defaultInstalled = app.defaultApp == true,
        removable = removable,
        orientation = app.orientation or (app.landscape == true and "landscape" or "portrait"),
        permissions = build_permissions(app),
        gridOrder = app.gridOrder,
        iconBackground = app.skyPhoneIconBackground
            or (type(app.iconBackground) == "string" and app.iconBackground or nil),
        onInstall = app.onInstall,
        onDelete = app.onDelete or app.onUninstall,
        onOpen = app.onOpen or app.onUse,
        onClose = app.onClose,
        compatibility = {
            provider = "sky_base",
            apiVersion = 1,
            fixBlur = app.fixBlur ~= false,
            resourceName = resource
        }
    })
    if registered then
        custom_app_resources[app.identifier] = resource
    end
    return registered, registration_error
end

function Sky.Functions.RemoveCustomPhoneApp(identifier)
    if IsDuplicityVersion() then return false, "client_only" end
    local removed, removal_error = exports["sky_phone"]:RemoveCustomApp(identifier)
    if removed or removal_error == "app_not_found" then
        custom_app_resources[identifier] = nil
    end
    return removed, removal_error
end

function Sky.Functions.SendCustomPhoneAppMessage(identifier, data)
    if IsDuplicityVersion() then
        Sky.Debug("error", "sky_phone custom app messages send from the client.")
        return false, "client_only"
    end
    return exports["sky_phone"]:SendCustomAppMessage(identifier, data or {})
end

function Sky.Functions.SendPhoneAppNotification(data, source)
    if type(data) ~= "table" then
        return false, "invalid_notification"
    end

    if IsDuplicityVersion() then
        local target = tonumber(source or data.source or data.src)
        if not target or target <= 0 then
            Sky.Debug("error", "sky_phone SendPhoneAppNotification called without a valid target source.")
            return false, "invalid_source"
        end

        TriggerClientEvent("sky_base:sky_phone:sendNotification", target, data)
        return true
    end

    local app_id = data.app or data.identifier
    local notification = {
        title = data.title,
        text = data.content or data.message or data.text,
        subtitle = data.subtitle,
        critical = data.critical,
        persistent = data.persistent,
        sound = data.sound
    }
    local delivered, delivery_error = exports["sky_phone"]:SendCustomAppNotification(app_id, notification)
    if delivered or (delivery_error ~= "app_not_found" and delivery_error ~= "app_owner_mismatch") then
        return delivered, delivery_error
    end

    return exports["lb-phone"]:SendNotification({
        app = app_id,
        title = data.title,
        content = data.content or data.message or data.text
    })
end

function Sky.Functions.GetPhoneNumber(source)
    if IsDuplicityVersion() then
        return exports["sky_phone"]:GetEquippedPhoneNumber(source)
    end
    return exports["sky_phone"]:GetEquippedPhoneNumber()
end

function Sky.Functions.RegisterCustomPhoneNumber()
    return false, "unsupported_phone"
end

function Sky.Functions.RemoveCustomPhoneNumber()
    return false
end

function Sky.Functions.OpenCustomPhoneApp(identifier, data)
    if IsDuplicityVersion() then
        return false, "client_only"
    end
    return exports["sky_phone"]:OpenCustomApp(identifier, data)
end

function Sky.Functions.GetSourceFromNumber(phone_number)
    if not IsDuplicityVersion() then
        Sky.Debug("error", "sky_phone source lookup is only available on the server.")
        return nil
    end
    return exports["sky_phone"]:GetSourceFromPhoneNumber(phone_number)
end

function Sky.Functions.HasAirplaneMode(phone_number)
    if not IsDuplicityVersion() then
        Sky.Debug("error", "sky_phone airplane-mode lookup is only available on the server.")
        return false
    end

    local device, lookup_error = exports["sky_phone"]:GetStoredDeviceByPhoneNumber(phone_number)
    if lookup_error == "api_not_ready" then
        error("sky_phone airplane-mode lookup failed because its server API is not ready")
    end
    if not device then
        return false
    end

    local rows = Sky.Query([[
        SELECT `payload`
        FROM `sky_phone_device_data`
        WHERE `device_imei` = ? AND `namespace` = 'settings'
        LIMIT 1
    ]], { device.imei }) or {}
    if not rows[1] or not rows[1].payload then
        return false
    end

    local payload = json.decode(rows[1].payload)
    return payload and payload.settings and payload.settings.airplaneMode == true or false
end

if not IsDuplicityVersion() then
    function Sky.Functions.SetPhoneInputFocus(focused)
        if type(focused) ~= "boolean" then
            Sky.Debug("warn", "sky_phone input focus expected a boolean, got %s.", type(focused))
            return false, "invalid_focus"
        end
        local game_input = nil
        if focused then game_input = false end
        return exports["sky_phone"]:SetPhoneGameInputEnabled(game_input)
    end

    AddEventHandler("onResourceStop", function(resource)
        if resource == "sky_phone" then
            custom_app_resources = {}
            return
        end

        -- Phone owns these apps under sky_base, so release each consumer's apps
        -- while its close hooks are still available during the stop event.
        for identifier, owner in pairs(custom_app_resources) do
            if owner == resource then
                local removed, removal_error = Sky.Functions.RemoveCustomPhoneApp(identifier)
                if not removed and removal_error ~= "app_not_found" then
                    Sky.Debug("error", "sky_phone failed to remove custom app %s while %s stopped: %s.",
                        identifier, resource, tostring(removal_error or "unknown_error"))
                end
            end
        end
    end)

    RegisterNetEvent("sky_base:sky_phone:sendNotification", function(data)
        local delivered, delivery_error = Sky.Functions.SendPhoneAppNotification(data)
        if not delivered then
            Sky.Debug(
                "error",
                "sky_phone client notification delivery failed: %s.",
                tostring(delivery_error or "unknown_error")
            )
        end
    end)
end
