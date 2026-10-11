-- bit-licenses: source-based license resource. License ids come from
-- Config.Licenses.catalog (e.g. driving, weapon, hunting, idcard) because the
-- resource does not expose a list export.
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.bit = {
    IsAvailable = function()
        return GetResourceState("bit-licenses") == "started"
    end,
    Check = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "CheckLicense", licenseType)
        if not source then return false end
        return exports['bit-licenses']:CheckLicense(source, licenseType) and true or false
    end,
    Add = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "AddLicense", licenseType)
        if not source then return false end
        exports['bit-licenses']:Addlicense(source, licenseType)
        return true
    end,
    Remove = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "RemoveLicense", licenseType)
        if not source then return false end
        exports['bit-licenses']:RemoveLicense(source, licenseType)
        return true
    end,
    List = function(target)
        local source = SkyLicenseHelpers.RequireSource(target, "GetLicenses", "-")
        if not source then return {} end
        local licenses = {}
        for _, entry in ipairs(SkyLicenseHelpers.GetConfiguredCatalog()) do
            if exports['bit-licenses']:CheckLicense(source, entry.type) then
                licenses[#licenses + 1] = { type = entry.type, label = entry.label }
            end
        end
        return licenses
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end
}
