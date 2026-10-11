---@diagnostic disable: duplicate-set-field
if not IsDuplicityVersion() then return end

Sky.FW = Sky.FW or {}
SkyLicenseProviders = SkyLicenseProviders or {}

local DETECTION_ORDER = { "cs", "ak47", "codem", "quasar", "papa", "bit", "vms", "stg-walletv2", "esx", "qbox", "qb", "standalone" }
local warned_provider = {}

local function normalizeLicenseType(license_type)
    if type(license_type) ~= "string" then
        return nil
    end

    license_type = license_type:gsub("^%s+", ""):gsub("%s+$", "")
    if license_type == "" then
        return nil
    end

    return license_type
end

local function resolveProvider()
    local selected = Sky.Config.license

    if type(selected) == "string" and selected ~= "" and selected ~= "auto" then
        local provider = SkyLicenseProviders[selected]
        if provider and provider.IsAvailable() then
            return provider
        end

        if not warned_provider[selected] then
            warned_provider[selected] = true
            print(("[sky_base][license] configured provider '%s' is unavailable")
                :format(tostring(selected)))
        end

        return nil
    end

    for _, name in ipairs(DETECTION_ORDER) do
        local provider = SkyLicenseProviders[name]
        if provider and provider.IsAvailable() then
            return provider
        end
    end

    return nil
end

local function appendUniqueLicenses(target, seen, entries)
    for _, entry in ipairs(entries or {}) do
        local license_type = type(entry) == "table" and entry.type or entry
        if type(license_type) == "string" and license_type ~= "" and not seen[license_type] then
            seen[license_type] = true
            target[#target + 1] = {
                type = license_type,
                label = type(entry) == "table" and entry.label or nil
            }
        end
    end
end

function Sky.FW.CheckLicense(source_or_identifier, license_type)
    license_type = normalizeLicenseType(license_type)
    if not license_type then
        print("[sky_base][license] CheckLicense failed: invalid license type")
        return false
    end

    local target = SkyLicenseHelpers.ResolveTarget(source_or_identifier)
    if not target then
        print(("[sky_base][license] CheckLicense failed: invalid target %s"):format(tostring(source_or_identifier)))
        return false
    end

    local provider = resolveProvider()
    if not provider then return false end
    if provider.Check(target, license_type) then
        return true
    end

    return false
end

function Sky.FW.AddLicense(source_or_identifier, license_type)
    license_type = normalizeLicenseType(license_type)
    if not license_type then
        print("[sky_base][license] AddLicense failed: invalid license type")
        return false
    end

    local target = SkyLicenseHelpers.ResolveTarget(source_or_identifier)
    if not target then
        print(("[sky_base][license] AddLicense failed: invalid target %s"):format(tostring(source_or_identifier)))
        return false
    end

    local provider = resolveProvider()
    if not provider then return false end
    if provider.Add(target, license_type) then
        return true
    end

    return false
end

function Sky.FW.RemoveLicense(source_or_identifier, license_type)
    license_type = normalizeLicenseType(license_type)
    if not license_type then
        print("[sky_base][license] RemoveLicense failed: invalid license type")
        return false
    end

    local target = SkyLicenseHelpers.ResolveTarget(source_or_identifier)
    if not target then
        print(("[sky_base][license] RemoveLicense failed: invalid target %s"):format(tostring(source_or_identifier)))
        return false
    end

    local provider = resolveProvider()
    if not provider then return false end
    return provider.Remove(target, license_type)
end

function Sky.FW.GetLicenses(source_or_identifier)
    local target = SkyLicenseHelpers.ResolveTarget(source_or_identifier)
    if not target then
        print(("[sky_base][license] GetLicenses failed: invalid target %s"):format(tostring(source_or_identifier)))
        return {}
    end

    local provider = resolveProvider()
    if not provider then return {} end
    local licenses = {}
    local seen = {}
    appendUniqueLicenses(licenses, seen, provider.List(target))

    local labels = {}
    for _, entry in ipairs(SkyLicenseHelpers.GetConfiguredCatalog()) do
        labels[entry.type] = entry.label
    end
    for _, entry in ipairs(licenses) do
        entry.label = entry.label or labels[entry.type] or entry.type
    end

    table.sort(licenses, function(a, b)
        return a.type < b.type
    end)
    return licenses
end

function Sky.FW.GetLicenseCatalog(source_or_identifier)
    local provider = resolveProvider()
    if not provider then return {} end
    local target = source_or_identifier and SkyLicenseHelpers.ResolveTarget(source_or_identifier) or nil
    local catalog = {}
    local seen = {}
    appendUniqueLicenses(catalog, seen, provider.Catalog(target))
    appendUniqueLicenses(catalog, seen, SkyLicenseHelpers.GetConfiguredCatalog())

    table.sort(catalog, function(a, b)
        return a.type < b.type
    end)
    return catalog
end

-- Complete current holder snapshot, including offline characters. Unsupported is
-- distinct from an empty register; consumers must never infer revocations from it.
function Sky.FW.GetLicenseHolders(license_type)
    license_type = normalizeLicenseType(license_type)
    if not license_type then return nil, "invalid_license_type" end
    local provider = resolveProvider()
    if not provider then return nil, "license_provider_unavailable" end
    if not provider.Holders then return nil, "license_holders_unsupported" end
    local entries, failure = provider.Holders(license_type)
    if entries == nil then return nil, failure end
    local result, seen = {}, {}
    for _, entry in ipairs(entries) do
        if type(entry) ~= "table" or type(entry.identifier) ~= "string" or entry.identifier == "" or #entry.identifier > 128 then
            error("[sky_base][license] Holder snapshot contains an invalid character identifier")
        end
        if not seen[entry.identifier] then
            seen[entry.identifier] = true
            result[#result + 1] = entry
        end
    end
    return result
end
