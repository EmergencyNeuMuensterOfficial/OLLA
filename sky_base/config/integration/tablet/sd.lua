if Sky.Config.tablet ~= "sd" then return end

function Sky.Functions.RegisterCustomTabletApp(app)
    if IsDuplicityVersion() then
        return false, "client_only"
    end

    local payload = {
        identifier = app.identifier,
        name = app.name,
        description = app.description,
        developer = app.developer,
        defaultApp = app.defaultApp == true,
        devices = "tablet",
        job = app.job or app.jobs,
        ui = app.ui or app.uiPath or app.url,
        icon = app.icon,
        images = app.images,
        size = app.size,
        price = app.price,
        fixBlur = app.fixBlur,
        onOpen = app.onOpen or app.onUse,
        onClose = app.onClose,
        onDelete = app.onDelete or app.onUninstall
    }

    return exports["sd-phone"]:addCustomApp(payload)
end

function Sky.Functions.RemoveCustomTabletApp(identifier)
    if IsDuplicityVersion() then
        return false, "client_only"
    end

    return exports["sd-phone"]:removeCustomApp(identifier)
end

function Sky.Functions.SendCustomTabletAppMessage(identifier, event, data)
    if IsDuplicityVersion() then
        return false, "client_only"
    end

    if type(event) == "table" and data == nil then
        data = event
        event = data.action or data.event or data.type
    end

    local payload = {}
    for key, value in pairs(data or {}) do
        payload[key] = value
    end
    payload.action = event or payload.action or "message"

    return exports["sd-phone"]:sendCustomAppMessage(identifier, payload)
end

function Sky.Functions.SendTabletAppNotification(data, source)
    data = data or {}
    local payload = {
        app = data.app or data.identifier,
        image = data.image or data.icon,
        title = data.title,
        body = data.body or data.content or data.message or data.text,
        time = data.time,
        appId = data.appId or data.app or data.identifier
    }

    if IsDuplicityVersion() then
        local target = tonumber(source or data.source or data.src)
        if not target or target <= 0 then
            Sky.Debug("error", "sd-tablet SendTabletAppNotification called without a valid target source.")
            return false
        end

        return exports["sd-phone"]:notify(target, payload)
    end

    return exports["sd-phone"]:showNotification(payload)
end

function Sky.Functions.CloseExternalTablet()
    Sky.Debug("error", "sd-tablet does not expose a documented close export.")
    return false, "unsupported_provider_api"
end
