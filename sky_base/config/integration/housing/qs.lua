Sky.Housing.RegisterAdapter("qs-housing", function()
    if IsDuplicityVersion() or GetResourceState("qs-housing") ~= "started" then
        return nil
    end

    local ok, houseId = pcall(function()
        return exports["qs-housing"]:getCurrentHouse()
    end)
    if not ok or not houseId then
        return nil
    end

    local house
    ok, house = pcall(function()
        return exports["qs-housing"]:GetHouseData(houseId)
    end)
    if not ok or type(house) ~= "table" then
        ok, house = pcall(function()
            local houses = exports["qs-housing"]:getHouseList()
            return type(houses) == "table" and houses[houseId] or nil
        end)
        if not ok then
            return nil
        end
    end

    return Sky.Housing.ResolvePropertyEntrance(house)
end)

if IsDuplicityVersion() then
    Sky.Housing.RegisterOwnershipAdapter("qs-housing", function(source)
        if GetResourceState("qs-housing") ~= "started" then
            return nil, "provider_unavailable"
        end

        local ok, properties = pcall(function()
            return exports["qs-housing"]:GetPlayerHouses(source)
        end)
        if not ok then
            Sky.Debug("error", "[housing/qs-housing] GetPlayerHouses failed: %s", tostring(properties))
            return nil, "provider_error"
        end
        if type(properties) ~= "table" then
            Sky.Debug("error", "[housing/qs-housing] GetPlayerHouses returned invalid data.")
            return nil, "invalid_result"
        end

        local count = Sky.Housing._CountOwnedCollection(properties)
        if count == nil then
            Sky.Debug("error", "[housing/qs-housing] GetPlayerHouses returned malformed property entries.")
            return nil, "invalid_result"
        end
        return count
    end)
end
