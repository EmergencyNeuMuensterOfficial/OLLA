if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

local core_object

local function getCoreObject()
    core_object = core_object or exports["qb-core"]:GetCoreObject()
    return core_object
end

local function getPlayer(identifier)
    return getCoreObject().Functions.GetPlayerByCitizenId(identifier)
end

local function getMetadata(target)
    local player = getPlayer(target.identifier)
    if player then
        return player.PlayerData.metadata or {}, player
    end

    local rows = Sky.Query("SELECT metadata FROM players WHERE citizenid = ? LIMIT 1", { target.identifier }) or {}
    if not rows[1] or not rows[1].metadata then
        print(("[sky_base][license] QB metadata not found for identifier %s"):format(target.identifier))
        return nil, nil
    end

    return json.decode(rows[1].metadata) or {}, nil
end

local function saveMetadata(target, metadata, player)
    if player then
        player.Functions.SetMetaData("licences", metadata.licences)
        return true
    end

    Sky.Query("UPDATE players SET metadata = ? WHERE citizenid = ?", {
        json.encode(metadata),
        target.identifier
    })
    return true
end

local function getDefaultLicences()
    local defaults = getCoreObject().Config.Player.PlayerDefaults.metadata.licences or {}
    return defaults
end

SkyLicenseProviders.qb = {
    IsAvailable = function()
        return Sky.Config.framework == "qb"
    end,
    Check = function(target, license_type)
        local metadata = getMetadata(target)
        local licences = metadata and (metadata.licences or metadata.licenses) or {}
        return licences[license_type] == true
    end,
    Add = function(target, license_type)
        local metadata, player = getMetadata(target)
        if not metadata then return false end

        metadata.licences = metadata.licences or metadata.licenses or {}
        metadata.licences[license_type] = true
        metadata.licenses = nil
        return saveMetadata(target, metadata, player)
    end,
    Remove = function(target, license_type)
        local metadata, player = getMetadata(target)
        if not metadata then return false end

        metadata.licences = metadata.licences or metadata.licenses or {}
        metadata.licences[license_type] = false
        metadata.licenses = nil
        return saveMetadata(target, metadata, player)
    end,
    List = function(target)
        local metadata = getMetadata(target)
        local results = {}

        for license_type, enabled in pairs(metadata and (metadata.licences or metadata.licenses) or {}) do
            if enabled then
                results[#results + 1] = { type = license_type }
            end
        end

        return results
    end,
    Catalog = function()
        local results = {}
        for license_type in pairs(getDefaultLicences()) do
            results[#results + 1] = { type = license_type }
        end
        return results
    end,
    Holders = function(license_type)
        local players = getCoreObject().Functions.GetQBPlayers()
        return SkyLicenseHelpers.MetadataHolders(license_type, players)
    end
}
