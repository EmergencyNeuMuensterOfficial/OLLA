if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

local backing_provider = SkyLicenseProviders[Sky.Config.framework]

SkyLicenseProviders["stg-walletv2"] = {
    IsAvailable = function()
        return GetResourceState("stg-walletv2") == "started"
            and backing_provider
            and backing_provider.IsAvailable()
    end,
    Check = function(target, license_type)
        return backing_provider.Check(target, license_type)
    end,
    Add = function(target, license_type)
        local source = SkyLicenseHelpers.RequireSource(target, "AddLicense", license_type)
        if not source then return false end

        exports["stg-walletv2"]:giveLicense(source, license_type)
        return true
    end,
    Remove = function(target, license_type)
        local source = SkyLicenseHelpers.RequireSource(target, "RemoveLicense", license_type)
        if not source then return false end

        exports["stg-walletv2"]:removeLicense(source, license_type)
        return true
    end,
    List = function(target)
        return backing_provider.List(target)
    end,
    Catalog = function(target)
        return backing_provider.Catalog(target)
    end,
    Holders = function(license_type)
        if not backing_provider.Holders then return nil, "license_holders_unsupported" end
        return backing_provider.Holders(license_type)
    end
}
