-- qs-licenses: identifier-based reads/revokes with source-based license grants.
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

local resource_name = "qs-licenses"

SkyLicenseProviders.quasar = {
    IsAvailable = function()
        return GetResourceState(resource_name) == "started"
    end,
    Check = function(target, license_type)
        return exports[resource_name]:HasLicense(target.identifier, license_type) and true or false
    end,
    Add = function(target, license_type)
        local source = SkyLicenseHelpers.RequireSource(target, "AddLicense", license_type)
        if not source then return false end

        return exports[resource_name]:AddLicenseToPlayer(source, license_type) and true or false
    end,
    Remove = function(target, license_type)
        return exports[resource_name]:RevokeLicense(target.identifier, license_type) and true or false
    end,
    List = function(target)
        local active_licenses = exports[resource_name]:GetActiveLicenses(target.identifier)
        if type(active_licenses) ~= "table" then
            print(("[sky_base][license] qs-licenses GetActiveLicenses returned %s for identifier %s")
                :format(type(active_licenses), tostring(target.identifier)))
            return {}
        end

        local licenses = {}
        for _, entry in ipairs(active_licenses) do
            if type(entry) ~= "table" then
                print(("[sky_base][license] qs-licenses returned an invalid active license entry for identifier %s")
                    :format(tostring(target.identifier)))
            else
                local license_type = entry.template_id or entry.type
                if type(license_type) ~= "string" or license_type == "" then
                    print(("[sky_base][license] qs-licenses active license is missing template_id for identifier %s")
                        :format(tostring(target.identifier)))
                else
                    licenses[#licenses + 1] = {
                        type = license_type,
                        label = entry.display_name or entry.label
                    }
                end
            end
        end

        return licenses
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end
}
