if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.esx = {
    IsAvailable = function()
        return Sky.Config.framework == "esx" and GetResourceState("esx_license") == "started"
    end,
    Check = function(target, license_type)
        local rows = Sky.Query(
            "SELECT 1 FROM user_licenses WHERE owner = ? AND type = ? LIMIT 1",
            { target.identifier, license_type }
        ) or {}
        return rows[1] ~= nil
    end,
    Add = function(target, license_type)
        Sky.Query(
            "INSERT IGNORE INTO user_licenses (owner, type) VALUES (?, ?)",
            { target.identifier, license_type }
        )
        return true
    end,
    Remove = function(target, license_type)
        Sky.Query(
            "DELETE FROM user_licenses WHERE owner = ? AND type = ?",
            { target.identifier, license_type }
        )
        return true
    end,
    List = function(target)
        return Sky.Query([[
            SELECT user_licenses.type, COALESCE(licenses.label, user_licenses.type) AS label
            FROM user_licenses
            LEFT JOIN licenses ON licenses.type = user_licenses.type
            WHERE user_licenses.owner = ?
        ]], { target.identifier }) or {}
    end,
    Catalog = function()
        return Sky.Query("SELECT type, label FROM licenses ORDER BY label", {}) or {}
    end,
    Holders = function(license_type)
        local rows = Sky.Query("SELECT DISTINCT owner AS identifier FROM user_licenses WHERE type = ?", { license_type })
        assert(type(rows) == "table", "[sky_base][license] ESX holder query failed")
        return rows
    end
}
