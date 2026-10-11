if not IsDuplicityVersion() then return end

Sky.Housing.RegisterOwnershipAdapter("qbx_properties", function(source)
    if Sky.Config.framework ~= "qbox"
        or GetResourceState("qbx_properties") ~= "started"
    then
        return nil, "provider_unavailable"
    end
    if not Sky.FW or type(Sky.FW.GetIdentifier) ~= "function" then
        return nil, "identifier_not_found"
    end
    if not Sky.DB or type(Sky.DB.Select) ~= "function" then
        return nil, "database_unavailable"
    end

    local identifier = Sky.FW.GetIdentifier(source)
    if identifier == nil or tostring(identifier) == "" then
        return nil, "identifier_not_found"
    end

    local rows = Sky.DB.Select(
        "SELECT COUNT(*) AS `property_count` FROM `properties` WHERE `owner` = ?",
        { identifier }
    )
    if rows == nil then
        Sky.Debug("error", "[housing/qbx_properties] Property ownership query failed.")
        return nil, "query_failed"
    end

    local count = tonumber(rows[1] and rows[1].property_count)
    if not count or count < 0 or count ~= math.floor(count) then
        Sky.Debug("error", "[housing/qbx_properties] Property ownership query returned an invalid result.")
        return nil, "invalid_result"
    end
    return count
end)
