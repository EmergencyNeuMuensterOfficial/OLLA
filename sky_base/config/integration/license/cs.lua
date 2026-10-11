-- CodeStudio Ultimate License System: persistent, item-named licenses.
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.cs = {
    IsAvailable = function()
        return GetResourceState("cs_license") == "started"
    end,
    Check = function(target, license_type)
        return exports["cs_license"]:CheckID(target.identifier, license_type)
    end,
    Add = function(target, license_type)
        local player_id = target.source or target.identifier
        exports["cs_license"]:RegisterCard(player_id, license_type, false, target.source ~= nil)
        return exports["cs_license"]:CheckID(target.identifier, license_type)
    end,
    Remove = function(target, license_type)
        exports["cs_license"]:RevokeCard(target.identifier, license_type)
        return not exports["cs_license"]:CheckID(target.identifier, license_type)
    end,
    List = function(target)
        local licenses = {}
        for _, entry in ipairs(exports["cs_license"]:GetPlayerLicenses(target.identifier)) do
            if exports["cs_license"]:CheckID(target.identifier, entry.license) then
                licenses[#licenses + 1] = { type = entry.license, label = entry.heading }
            end
        end
        return licenses
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end
}
