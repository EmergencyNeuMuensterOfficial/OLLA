-- vms_documentsv2: document-based license provider.
if not IsDuplicityVersion() then return end

SkyLicenseProviders = SkyLicenseProviders or {}

local RESOURCE_NAME = "vms_documentsv2"

local function registerLicenseType(results, seen, licenseType)
    if type(licenseType) ~= "string" then
        return
    end

    licenseType = licenseType:gsub("^%s+", ""):gsub("%s+$", "")
    if licenseType == "" then
        return
    end

    local key = licenseType:lower()
    if seen[key] then
        return
    end

    seen[key] = true
    results[#results + 1] = licenseType
end

local function collectLicenseTypes(value, results, seen, depth)
    if depth > 4 or type(value) ~= "table" then
        return
    end

    registerLicenseType(results, seen, value.name)
    registerLicenseType(results, seen, value.type)
    registerLicenseType(results, seen, value.document)
    registerLicenseType(results, seen, value.documentName)
    registerLicenseType(results, seen, value.item)
    registerLicenseType(results, seen, value.itemName)

    for _, entry in pairs(value) do
        collectLicenseTypes(entry, results, seen, depth + 1)
    end
end

local function getDiscoveredLicenseTypes(identifier)
    local results = {}
    local seen = {}

    for _, entry in ipairs(SkyLicenseHelpers.GetConfiguredCatalog()) do
        registerLicenseType(results, seen, entry.type)
    end

    local documents = exports[RESOURCE_NAME]:getMyDocuments(identifier) or {}
    collectLicenseTypes(documents, results, seen, 0)

    return results
end

SkyLicenseProviders.vms = {
    IsAvailable = function()
        return GetResourceState(RESOURCE_NAME) == "started"
    end,
    Check = function(target, licenseType)
        return exports[RESOURCE_NAME]:isAnyDocumentValid(target.identifier, licenseType) ~= nil
    end,
    Add = function(target, licenseType)
        local source = SkyLicenseHelpers.RequireSource(target, "AddLicense", licenseType)
        if not source then return false end
        exports[RESOURCE_NAME]:giveDocument(source, licenseType, nil, true)
        return true
    end,
    Remove = function(target, licenseType)
        local serialNumber = exports[RESOURCE_NAME]:isAnyDocumentValid(target.identifier, licenseType)
        if not serialNumber then
            return true
        end

        exports[RESOURCE_NAME]:invalidateDocument(target.identifier, serialNumber)
        return true
    end,
    List = function(target)
        local configuredCatalog = SkyLicenseHelpers.GetConfiguredCatalog()
        local labels = {}
        for _, entry in ipairs(configuredCatalog) do
            labels[entry.type:lower()] = entry.label or entry.type
        end

        local results = {}
        for _, licenseType in ipairs(getDiscoveredLicenseTypes(target.identifier)) do
            local serialNumber = exports[RESOURCE_NAME]:isAnyDocumentValid(target.identifier, licenseType)
            if serialNumber then
                results[#results + 1] = {
                    type = licenseType,
                    label = labels[licenseType:lower()] or licenseType,
                    serialNumber = serialNumber
                }
            end
        end

        table.sort(results, function(a, b)
            return tostring(a.type) < tostring(b.type)
        end)

        return results
    end,
    Catalog = function()
        return SkyLicenseHelpers.GetConfiguredCatalog()
    end
}
