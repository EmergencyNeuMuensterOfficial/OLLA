-- Set Config.license = "custom" to enable this server-side provider template.
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.custom = {
    IsAvailable = function()
        -- Config.license = "custom" selects this provider directly.
        return true
    end,
    Check = function(target, license_type)
        -- Return whether `target.identifier` owns `license_type`.
        error("Custom license integration: Check is not implemented")
    end,
    Add = function(target, license_type)
        -- Grant the license and return whether the operation succeeded.
        error("Custom license integration: Add is not implemented")
    end,
    Remove = function(target, license_type)
        -- Revoke the license and return whether the operation succeeded.
        error("Custom license integration: Remove is not implemented")
    end,
    List = function(target)
        -- Return an array of { type = string, label = string } entries.
        error("Custom license integration: List is not implemented")
    end,
    Catalog = function(target)
        -- Return all available { type = string, label = string } entries.
        -- Use SkyLicenseHelpers.GetConfiguredCatalog() when appropriate.
        error("Custom license integration: Catalog is not implemented")
    end,
    Holders = function(license_type)
        -- Optional: return ALL current holders (online + offline) as
        -- { { identifier = "character-id" }, ... }. Return {} only after a
        -- successful empty lookup. Throw on errors; never return partial results.
        return nil, "license_holders_unsupported"
    end
}
