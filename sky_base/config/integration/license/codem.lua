-- codem-wallet: identifier-based license store backed by codem_wallet_cards.
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

SkyLicenseProviders.codem = {
    IsAvailable = function()
        return GetResourceState("codem-wallet") == "started"
    end,
    Check = function(target, licenseType)
        return exports['codem-wallet']:hasLicense(target.identifier, licenseType) and true or false
    end,
    Add = function(target, licenseType)
        if exports['codem-wallet']:hasLicense(target.identifier, licenseType) then
            return true
        end
        exports['codem-wallet']:addLicense(target.identifier, licenseType, { source = target.source })
        return true
    end,
    Remove = function(target, licenseType)
        Sky.Query("DELETE FROM codem_wallet_cards WHERE identifier = ? AND type = ? AND licenseType = ?;",
            { target.identifier, "license", licenseType })
        return true
    end,
    List = function(target)
        local rows = Sky.Query([[
            SELECT licenseType
            FROM codem_wallet_cards
            WHERE identifier = ? AND type = ? AND licenseType IS NOT NULL AND licenseType <> ''
        ]], { target.identifier, "license" }) or {}

        local labels = {}
        for _, entry in ipairs(SkyLicenseHelpers.GetConfiguredCatalog()) do
            labels[entry.type] = entry.label
        end

        local resolved = {}
        local seen = {}
        for _, row in ipairs(rows) do
            local licenseType = row.licenseType
            if type(licenseType) == "string" and licenseType ~= "" and not seen[licenseType] then
                seen[licenseType] = true
                resolved[#resolved + 1] = {
                    type = licenseType,
                    label = labels[licenseType] or licenseType
                }
            end
        end
        return resolved
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end,
    Holders = function(license_type)
        local rows = Sky.Query("SELECT DISTINCT identifier FROM codem_wallet_cards WHERE type = ? AND licenseType = ?", { "license", license_type })
        assert(type(rows) == "table", "[sky_base][license] CodeM holder query failed")
        return rows
    end
}
