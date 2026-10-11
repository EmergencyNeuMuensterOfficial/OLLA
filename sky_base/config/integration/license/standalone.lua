if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.standalone = {
    IsAvailable = function()
        return true
    end,
    Check = function(target, license_type)
        local rows = Sky.Query(
            "SELECT 1 FROM sky_base_licenses WHERE identifier = ? AND license_type = ? LIMIT 1",
            { target.identifier, license_type }
        ) or {}
        return rows[1] ~= nil
    end,
    Add = function(target, license_type)
        Sky.Query(
            "INSERT IGNORE INTO sky_base_licenses (identifier, license_type) VALUES (?, ?)",
            { target.identifier, license_type }
        )
        return true
    end,
    Remove = function(target, license_type)
        Sky.Query(
            "DELETE FROM sky_base_licenses WHERE identifier = ? AND license_type = ?",
            { target.identifier, license_type }
        )
        return true
    end,
    List = function(target)
        local rows = Sky.Query(
            "SELECT license_type AS type FROM sky_base_licenses WHERE identifier = ?",
            { target.identifier }
        ) or {}
        return rows
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end,
    Holders = function(license_type)
        local rows = Sky.Query("SELECT identifier FROM sky_base_licenses WHERE license_type = ?", { license_type })
        assert(type(rows) == "table", "[sky_base][license] Standalone holder query failed")
        return rows
    end
}
