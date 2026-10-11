if not IsDuplicityVersion() then return end

Sky.Housing.RegisterOwnershipAdapter("esx_property", function(source)
    if Sky.Config.framework ~= "esx"
        or GetResourceState("esx_property") ~= "started"
    then
        return nil, "provider_unavailable"
    end
    if not Sky.FW or type(Sky.FW.GetIdentifier) ~= "function" then
        return nil, "identifier_not_found"
    end

    local identifier = Sky.FW.GetIdentifier(source)
    if identifier == nil or tostring(identifier) == "" then
        return nil, "identifier_not_found"
    end
    identifier = tostring(identifier)

    local ok, properties = pcall(function()
        return exports.esx_property:GetProperties()
    end)
    if not ok then
        Sky.Debug("error", "[housing/esx_property] GetProperties failed: %s", tostring(properties))
        return nil, "provider_error"
    end
    if type(properties) ~= "table" then
        Sky.Debug("error", "[housing/esx_property] GetProperties returned invalid data.")
        return nil, "invalid_result"
    end

    local count = 0
    for _, property in pairs(properties) do
        if type(property) ~= "table" then
            Sky.Debug("error", "[housing/esx_property] GetProperties returned a malformed property entry.")
            return nil, "invalid_result"
        end
        if property.Owned == true
            and property.Owner ~= nil
            and tostring(property.Owner) == identifier
        then
            count = count + 1
        end
    end
    return count
end)
