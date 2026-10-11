Sky.Voice = Sky.Voice or {}

local volume = 1.0
local proximity_override = nil
local player_proximity_overrides = {}

local function normalizedScope(scope_id)
    if type(scope_id) ~= "string" then
        return nil
    end
    scope_id = scope_id:match("^%s*(.-)%s*$")
    if scope_id == "" or #scope_id > 128 then
        return nil
    end
    return scope_id
end

local function normalizedRange(range)
    range = tonumber(range)
    if not range or range ~= range or range == math.huge or range == -math.huge then
        return nil
    end
    if range < 1.0 or range > 100.0 then
        return nil
    end
    return range + 0.0
end

local function normalizedSource(player_source)
    player_source = tonumber(player_source)
    if not player_source or player_source ~= math.floor(player_source)
        or player_source <= 0
    then
        return nil
    end
    return player_source
end

-- Provider adapters replace these two functions on the client. Keeping the
-- ownership and validation here gives every consumer one stable contract.
Sky.Voice._ApplyProximityOverride = function()
    return false, "unsupported_provider_api"
end

Sky.Voice._ClearProximityOverride = function()
    return false, "unsupported_provider_api"
end

-- Server-capable providers replace these functions. The shared layer owns
-- validation and scopes so consumers never branch on a voice provider.
Sky.Voice._ApplyPlayerProximityOverride = function()
    return false, "unsupported_provider_api"
end

Sky.Voice._ClearPlayerProximityOverride = function()
    return false, "unsupported_provider_api"
end

function Sky.Voice.SetProximityOverride(scope_id, range, options)
    if IsDuplicityVersion() then
        return false, "client_only"
    end
    scope_id = normalizedScope(scope_id)
    range = normalizedRange(range)
    if not scope_id then
        return false, "invalid_scope"
    end
    if not range then
        return false, "invalid_range"
    end
    if proximity_override and proximity_override.scopeId ~= scope_id then
        return false, "override_in_use"
    end
    local ok, error_code = Sky.Voice._ApplyProximityOverride(
        range,
        type(options) == "table" and options or {}
    )
    if ok ~= true then
        return false, error_code or "provider_error"
    end
    proximity_override = {
        scopeId = scope_id,
        range = range,
        provider = Sky.Voice.GetCapabilities().provider,
    }
    return true
end

function Sky.Voice.ClearProximityOverride(scope_id)
    if IsDuplicityVersion() then
        return false, "client_only"
    end
    scope_id = normalizedScope(scope_id)
    if not scope_id then
        return false, "invalid_scope"
    end
    if not proximity_override then
        return true
    end
    if proximity_override.scopeId ~= scope_id then
        return false, "scope_mismatch"
    end
    local ok, error_code = Sky.Voice._ClearProximityOverride()
    if ok ~= true then
        return false, error_code or "provider_error"
    end
    proximity_override = nil
    return true
end

function Sky.Voice.GetProximityOverride()
    if not proximity_override then
        return nil
    end
    return {
        scopeId = proximity_override.scopeId,
        range = proximity_override.range,
        provider = proximity_override.provider,
    }
end

function Sky.Voice._InvalidateProximityOverride(reason)
    local previous = proximity_override
    proximity_override = nil
    if previous and not IsDuplicityVersion() then
        TriggerEvent(
            "sky_base:voice:proximityOverrideInvalidated",
            previous.scopeId,
            reason or "provider_unavailable"
        )
    end
end

function Sky.Voice.SetPlayerProximityOverride(player_source, scope_id, range, options)
    if not IsDuplicityVersion() then
        return false, "server_only"
    end
    player_source = normalizedSource(player_source)
    scope_id = normalizedScope(scope_id)
    range = normalizedRange(range)
    if not player_source then
        return false, "invalid_source"
    end
    if not scope_id then
        return false, "invalid_scope"
    end
    if not range then
        return false, "invalid_range"
    end
    local safe_options = type(options) == "table" and options or {}
    local owner_resource = nil
    if type(GetInvokingResource) == "function" then
        local owner_ok, invoking_resource = pcall(GetInvokingResource)
        if owner_ok then
            owner_resource = normalizedScope(invoking_resource)
        end
    end
    owner_resource = owner_resource
        or normalizedScope(safe_options.ownerResource)
    local current = player_proximity_overrides[player_source]
    if current and current.scopeId ~= scope_id then
        return false, "override_in_use"
    end
    if current and current.ownerResource
        and current.ownerResource ~= owner_resource
    then
        return false, "override_in_use"
    end
    local ok, error_code = Sky.Voice._ApplyPlayerProximityOverride(
        player_source,
        range,
        safe_options
    )
    if ok ~= true then
        return false, error_code or "provider_error"
    end
    player_proximity_overrides[player_source] = {
        scopeId = scope_id,
        range = range,
        provider = Sky.Voice.GetCapabilities().provider,
        ownerResource = current and current.ownerResource or owner_resource,
    }
    return true
end

function Sky.Voice.ClearPlayerProximityOverride(player_source, scope_id)
    if not IsDuplicityVersion() then
        return false, "server_only"
    end
    player_source = normalizedSource(player_source)
    scope_id = normalizedScope(scope_id)
    if not player_source then
        return false, "invalid_source"
    end
    if not scope_id then
        return false, "invalid_scope"
    end
    local current = player_proximity_overrides[player_source]
    if not current then
        return true
    end
    if current.scopeId ~= scope_id then
        return false, "scope_mismatch"
    end
    local ok, error_code =
        Sky.Voice._ClearPlayerProximityOverride(player_source, {})
    if ok ~= true then
        return false, error_code or "provider_error"
    end
    player_proximity_overrides[player_source] = nil
    return true
end

function Sky.Voice.GetPlayerProximityOverride(player_source)
    if not IsDuplicityVersion() then
        return nil, "server_only"
    end
    player_source = normalizedSource(player_source)
    if not player_source then
        return nil, "invalid_source"
    end
    local current = player_proximity_overrides[player_source]
    if not current then
        return nil
    end
    return {
        scopeId = current.scopeId,
        range = current.range,
        provider = current.provider,
        ownerResource = current.ownerResource,
    }
end

function Sky.Voice._InvalidatePlayerProximityOverride(player_source, reason)
    player_source = normalizedSource(player_source)
    local previous = player_source and player_proximity_overrides[player_source] or nil
    if not previous then
        return
    end
    player_proximity_overrides[player_source] = nil
    if IsDuplicityVersion() then
        TriggerEvent(
            "sky_base:voice:playerProximityOverrideInvalidated",
            player_source,
            previous.scopeId,
            reason or "provider_unavailable"
        )
    end
end

function Sky.Voice._InvalidatePlayerProximityOverrides(reason)
    local pending = {}
    for player_source in pairs(player_proximity_overrides) do
        pending[#pending + 1] = player_source
    end
    for _, player_source in ipairs(pending) do
        Sky.Voice._InvalidatePlayerProximityOverride(player_source, reason)
    end
end

function Sky.Voice.SetRadio()
    Sky.Debug("error", "[sky_base][voice] No supported voice adapter is active.")
    return false
end

function Sky.Voice.RemoveRadio()
    Sky.Debug("error", "[sky_base][voice] No supported voice adapter is active.")
    return false
end

function Sky.Voice.GetPlayersInChannel()
    return {}
end

function Sky.Voice.SetRadioChannel()
    Sky.Debug("error", "[sky_base][voice] No supported voice adapter is active.")
    return false
end

function Sky.Voice.GetRadioVolume()
    return volume
end

function Sky.Voice.SetRadioVolume(value)
    volume = math.max(0.0, math.min(1.0, tonumber(value) or 1.0))
    return false
end

function Sky.Voice.GetCapabilities()
    return {
        provider = "none",
        volume = false,
        multiChannel = false,
        radioActivity = false,
        proximityOverride = false,
        playerProximityOverride = false,
    }
end

if not IsDuplicityVersion() then
    AddEventHandler("onClientResourceStop", function(resource_name)
        if resource_name ~= GetCurrentResourceName() or not proximity_override then
            return
        end
        pcall(Sky.Voice._ClearProximityOverride)
        proximity_override = nil
    end)
else
    AddEventHandler("playerDropped", function()
        local player_source = tonumber(source)
        if not player_source or not player_proximity_overrides[player_source] then
            return
        end
        pcall(
            Sky.Voice._ClearPlayerProximityOverride,
            player_source,
            { playerDropped = true }
        )
        player_proximity_overrides[player_source] = nil
    end)

    AddEventHandler("onResourceStop", function(resource_name)
        local clear_all = resource_name == GetCurrentResourceName()
        local pending = {}
        for player_source, current in pairs(player_proximity_overrides) do
            if clear_all or current.ownerResource == resource_name then
                pending[#pending + 1] = player_source
            end
        end
        for _, player_source in ipairs(pending) do
            local ok, cleared = pcall(
                Sky.Voice._ClearPlayerProximityOverride,
                player_source,
                { resourceStop = true }
            )
            if ok and cleared == true then
                player_proximity_overrides[player_source] = nil
            end
        end
    end)
end
