Sky.Housing.RegisterAdapter("sn_properties", function()
    if IsDuplicityVersion() or GetResourceState("sn_properties") ~= "started" then
        return nil
    end

    local ok, property = pcall(function()
        return exports.sn_properties:getProperty()
    end)
    if not ok or type(property) ~= "table" then
        local propertyId
        ok, propertyId = pcall(function()
            return exports.sn_properties:getPropertyID()
        end)
        if not ok or not propertyId then
            return nil
        end

        ok, property = pcall(function()
            return exports.sn_properties:getProperty(propertyId)
        end)
        if not ok then
            return nil
        end
    end

    return Sky.Housing.ResolvePropertyEntrance(property)
end)

if IsDuplicityVersion() then
    Sky.Housing.RegisterOwnershipAdapter("sn_properties", function(source)
        if GetResourceState("sn_properties") ~= "started" then
            return nil, "provider_unavailable"
        end

        local ok, properties = pcall(function()
            return exports.sn_properties:getPlayerProperties(source)
        end)
        if not ok then
            Sky.Debug("error", "[housing/sn_properties] getPlayerProperties failed: %s", tostring(properties))
            return nil, "provider_error"
        end
        if properties == nil or properties == false then
            return 0
        end

        local valueType = type(properties)
        if valueType == "number" or valueType == "string" then
            if tonumber(properties) == 0 then
                return 0
            end
            if Sky.Housing._PositivePropertyId(properties) then
                return 1
            end

            Sky.Debug("error", "[housing/sn_properties] getPlayerProperties returned a malformed property identifier.")
            return nil, "invalid_result"
        end
        if valueType ~= "table" then
            Sky.Debug("error", "[housing/sn_properties] getPlayerProperties returned invalid data.")
            return nil, "invalid_result"
        end

        local count = Sky.Housing._CountPositivePropertyIds(properties)
        if count == nil then
            Sky.Debug("error", "[housing/sn_properties] getPlayerProperties returned malformed property identifiers.")
            return nil, "invalid_result"
        end
        return count
    end)
end
