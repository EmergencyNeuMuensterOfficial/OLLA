if Sky.Config.garage == "op" then
    local resource_version = GetResourceMetadata("op-garages", "version", 0)
    local major_version = type(resource_version) == "string"
        and tonumber(resource_version:match("^v?(%d+)"))
        or nil

    if major_version and major_version >= 3 then
        return
    end

    local tableName = Sky.Config.framework == "esx" and "owned_vehicles" or "player_vehicles"
    local defaultParking = "Würfelpark"

    function Sky.Functions.IsPlateUsed(plate)
        local result = Sky.Query("SELECT plate FROM " .. tableName .. " WHERE plate = ?", { plate })
        return result[1] ~= nil
    end

    function Sky.Functions.GeneratePlate()
        math.randomseed(GetGameTimer())
        local plate = string.upper(Sky.Math.GetRandomLetters(3) .. Sky.Math.GetRandomNumbers(3))

        if Sky.Functions.IsPlateUsed(plate) then
            return Sky.Functions.GeneratePlate()
        end

        return plate
    end

    function Sky.Functions.GiveVehicle(source, model)
        local plate = Sky.Functions.GeneratePlate()
        local hash = GetHashKey(model)
        local vehicleData = {
            plate = plate,
            model = hash,
            hash = hash
        }

        if Sky.Config.framework == "esx" then
            local xPlayer = ESX.GetPlayerFromId(source)
            Sky.Query("INSERT INTO owned_vehicles (owner, plate, vehicle, stored, parking) VALUES (?, ?, ?, ?, ?)", {
                xPlayer.identifier,
                plate,
                json.encode(vehicleData),
                1,
                defaultParking
            })
        elseif Sky.Config.framework == "qbox" then
            local player = exports.qbx_core:GetPlayer(source)
            Sky.Query("INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {
                player.PlayerData.license,
                player.PlayerData.citizenid,
                model,
                hash,
                json.encode(vehicleData),
                plate,
                1,
                defaultParking
            })
        end

        TriggerClientEvent("sky_base:client:giveVehicleKeys", source, plate, model)
    end

    function Sky.Functions.ChangePlate(oldPlate, newPlate)
        Sky.Query("UPDATE " .. tableName .. " SET plate = ? WHERE plate = ?", { newPlate, oldPlate })
    end
end
