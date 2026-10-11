if Sky.Config.garage == "okok" then
    local tableName = Sky.Config.framework == "esx" and "owned_vehicles" or "player_vehicles"

    function Sky.Functions.IsPlateUsed(plate)
        local result = Sky.Query("SELECT plate FROM " .. tableName .. " WHERE plate = ?", { plate })
        return result[1] ~= nil
    end

    function Sky.Functions.GeneratePlate() 
        math.randomseed(GetGameTimer())
        local plate = string.upper(Sky.Math.GetRandomLetters(3)..''..Sky.Math.GetRandomNumbers(3))

        if Sky.Functions.IsPlateUsed(plate) then
            return Sky.Functions.GeneratePlate()
        end
        
        return plate
    end

    function Sky.Functions.GiveVehicle(source, model)
        local plate = Sky.Functions.GeneratePlate()
    
        local mods = Sky.Cb.Trigger("sky_base:getVehicleMods", source, model)
        local vehicleType = "car"
        local garage = "Legion Square"

        if mods.class == 14 then
            garage = "Boat"
            vehicleType = "boat"
        elseif mods.class == 15 or mods.class == 16 then
            garage = "Air"
            vehicleType = "air"
        end

        if Sky.Config.framework == "esx" then
            local xPlayer = ESX.GetPlayerFromId(source)
            Sky.Query('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, parking, type) VALUES (?, ?, ?, ?, ?, ?)',{
                xPlayer.identifier,
                plate,
                json.encode(mods),
                1,
                garage,
                vehicleType
            })
        elseif Sky.Config.framework == "qb" or Sky.Config.framework == "qbox" then
            local pData
            if Sky.Config.framework == "qb" then
                pData = QBCore.Functions.GetPlayer(source)
            elseif Sky.Config.framework == "qbox" then
                pData = exports.qbx_core:GetPlayer(source)
            end
            Sky.Query("INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {
                pData.PlayerData.license,
                pData.PlayerData.citizenid,
                model,
                GetHashKey(model),
                json.encode(mods),
                plate,
                1,
                garage,
            })
        end
    end

    function Sky.Functions.ChangePlate(oldPlate, newPlate)
        Sky.Query("UPDATE " .. tableName .. " SET plate = ? WHERE plate = ?", { newPlate, oldPlate })
    end
end
