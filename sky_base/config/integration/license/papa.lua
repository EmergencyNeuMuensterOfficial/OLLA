-- papa_licensecreator: access-based license resource. License ids come from
-- Config.Licenses.catalog (e.g. papa_id, papa_driver_license) because the
-- resource does not expose a list export.
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.papa = {
    IsAvailable = function()
        return GetResourceState("papa_licensecreator") == "started"
    end,
    Check = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "CheckLicense", licenseType)
        if not source then return false end
        return exports['papa_licensecreator']:hasLicenseAccess(source, licenseType) and true or false
    end,
    Add = function(target, licenseType)
        exports['papa_licensecreator']:addLicenseAccess(target.identifier, licenseType)
        if (Config.Licenses or {}).papaGiveItem then
            exports['papa_licensecreator']:giveLicenseItem(target.identifier, licenseType)
        end
        return true
    end,
    Remove = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "RemoveLicense", licenseType)
        if not source then return false end
        exports['papa_licensecreator']:removeLicenseAccess(source, licenseType)
        return true
    end,
    List = function(target)
        local source = SkyLicenseHelpers.RequireSource(target, "GetLicenses", "-")
        if not source then return {} end
        local licenses = {}
        for _, entry in ipairs(SkyLicenseHelpers.GetConfiguredCatalog()) do
            if exports['papa_licensecreator']:hasLicenseAccess(source, entry.type) then
                licenses[#licenses + 1] = { type = entry.type, label = entry.label }
            end
        end
        return licenses
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end
}
