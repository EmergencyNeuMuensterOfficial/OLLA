if Sky.Config.garage == "jg" then
    local tableName = Sky.Config.framework == "esx" and "owned_vehicles" or "player_vehicles"
    local modsColumnName = Sky.Config.framework == "esx" and "vehicle" or "mods"

    function Sky.Functions.IsPlateUsed(plate)
        local result
        if Sky.Config.framework == "esx" then
            result = Sky.Query('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate})
        elseif Sky.Config.framework == "qb" or Sky.Config.framework == "qbox" then
            result = Sky.Query('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
        end
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
        mods.plate = plate
        local vehicleType = "vehicle"
        local garage = "Legion Square"

        if mods.class == 14 then
            garage = "Boats"
            vehicleType = "boat"
        elseif mods.class == 15 or mods.class == 16 then
            garage = "Hangar"
            vehicleType = "plane"
        end
        if Sky.Config.framework == "esx" then
            local xPlayer = ESX.GetPlayerFromId(source)
            Sky.Query('INSERT INTO owned_vehicles (owner, plate, vehicle, in_garage, garage_id, type) VALUES (@owner, @plate, @vehicle, @stored, @garage, @type)',
            {
                ['@owner']   = xPlayer.identifier,
                ['@plate']   = plate,
                ['@vehicle'] = json.encode(mods),
                ['@stored'] = 1,
                ['@garage'] = garage,
                ['@type'] = vehicleType
            })
        elseif Sky.Config.framework == "qb" or Sky.Config.framework == "qbox" then
            local pData
            if Sky.Config.framework == "qb" then
                pData = QBCore.Functions.GetPlayer(source)
            elseif Sky.Config.framework == "qbox" then
                pData = exports.qbx_core:GetPlayer(source)
            end
            Sky.Query('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, in_garage, garage_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                pData.PlayerData.license,
                pData.PlayerData.citizenid, 
                model, 
                GetHashKey(model),
                json.encode(mods), 
                plate, 
                1,
                garage
            })
        end
        TriggerClientEvent("sky_base:client:giveVehicleKeys", source, plate, model)
    end

    function Sky.Functions.ChangePlate(oldPlate, newPlate)
        Sky.Query("UPDATE " .. tableName .. " SET plate = ? WHERE plate = ?", { newPlate, oldPlate })
        local rows = Sky.Query("SELECT * FROM " .. tableName .. " WHERE plate = ?", { newPlate })
        if not rows or not rows[1] then
            return
        end

        local row = rows[1]
        local modsJson = row[modsColumnName]

        local okMods, mods = pcall(json.decode, modsJson or "")
        if okMods and type(mods) == "table" then
            mods.plate = newPlate
            modsJson = json.encode(mods)
        end

        Sky.Query("UPDATE ".. tableName .. " SET ".. modsColumnName .." = ? WHERE plate = ?", {
            modsJson or row.mods,
            newPlate
        })
    end

    -- function Sky.Functions.ChangePlate(oldPlate, newPlate, src)
    --     local newPlate = string.upper(newPlate)
    --     if Sky.Config.framework == "esx" then
    --         Sky.Query('UPDATE owned_vehicles SET plate = ? WHERE plate = ?', {newPlate, oldPlate})
    --     elseif Sky.Config.framework == "qb" or Sky.Config.framework == "qbox" then
    --         Sky.Query('UPDATE player_vehicles SET plate = ?, mods = JSON_SET(mods, "$.plate", ?) WHERE plate = ?',{newPlate, newPlate, oldPlate})
    --         TriggerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', newPlate)
    --     end
    -- end
end
