-- ak47_idcardv2: id-card based license resource (driverlicense item).
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.ak47 = {
    IsAvailable = function()
        return GetResourceState("ak47_idcardv2") == "started"
    end,
    Check = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "CheckLicense", licenseType)
        if not source then return false end
        return exports['ak47_idcardv2']:HasLicense(source, "driverlicense", licenseType)
    end,
    Add = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "AddLicense", licenseType)
        if not source then return false end
        exports['ak47_idcardv2']:GiveIdCard(source, {
            item = 'driverlicense', -- item name
            class = licenseType,
            address = 'Greenlight', -- player address
            expire = 3,             -- in month
        })
        return true
    end,
    Remove = function(target, licenseType)
        print(("[sky_base][license] RemoveLicense is not supported by ak47_idcardv2 (identifier %s, license %s)"):format(tostring(target.identifier), tostring(licenseType)))
        return false
    end,
    List = function(target)
        local source = SkyLicenseHelpers.RequireSource(target, "GetLicenses", "-")
        if not source then return {} end
        local ok, result = pcall(function()
            return exports['ak47_idcardv2']:GetLicenses(source, "driverlicense")
        end)
        if ok and type(result) == "table" then
            return result
        end

        local licenses = {}
        for _, entry in ipairs(SkyLicenseHelpers.GetConfiguredCatalog()) do
            if exports['ak47_idcardv2']:HasLicense(source, "driverlicense", entry.type) then
                licenses[#licenses + 1] = { type = entry.type, label = entry.label }
            end
        end
        return licenses
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end
}
