if Sky.Config.garage == "cd" then
    local tableName = Sky.Config.framework == "esx" and "owned_vehicles" or "player_vehicles"

    function Sky.Functions.IsPlateUsed(plate)
        local result = Sky.Query("SELECT plate FROM " .. tableName .. " WHERE plate = ?", { plate })
        return result[1] ~= nil
    end

    function Sky.Functions.GeneratePlate()
        math.randomseed(GetGameTimer())
        local plate = string.upper(Sky.Math.GetRandomLetters(4) .. "" .. Sky.Math.GetRandomNumbers(4))

        if Sky.Functions.IsPlateUsed(plate) then
            return Sky.Functions.GeneratePlate()
        end

        return plate
    end

    function Sky.Functions.GiveVehicle(source, model)
        local plate = Sky.Functions.GeneratePlate()
        local hash = GetHashKey(model)
        local vehicleData = json.encode({
            plate = plate,
            engineHealth = 1000.0,
            bodyHealth = 1000.0,
            fuelLevel = 100.0,
            model = hash
        })

        if Sky.Config.framework == "esx" then
            local xPlayer = ESX.GetPlayerFromId(source)
            Sky.Query("INSERT INTO owned_vehicles (owner, plate, vehicle, in_garage, garage_id, garage_type, adv_stats, impound, impound_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {
                xPlayer.identifier,
                plate,
                vehicleData,
                1,
                "A",
                "car",
                json.encode({
                    plate = plate,
                    mileage = 0.0,
                    maxhealth = 1000.0
                }),
                0,
                json.encode({})
            })
        else
            local pData = QBCore.Functions.GetPlayer(source)
            Sky.Query("INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage, in_garage, garage_id, garage_type, impound, impound_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
                pData.PlayerData.license,
                pData.PlayerData.citizenid,
                model,
                hash,
                vehicleData,
                plate,
                1,
                "pillboxgarage",
                1,
                "A",
                "car",
                0,
                json.encode({})
            })
        end
    end

    function Sky.Functions.ChangePlate(oldPlate, newPlate)
        -- Update primary plate column
        Sky.Query("UPDATE " .. tableName .. " SET plate = ? WHERE plate = ?", { newPlate, oldPlate })

        -- Also update the plate inside JSON columns
        local rows = Sky.Query("SELECT * FROM " .. tableName .. " WHERE plate = ?", { newPlate })
        if not rows or not rows[1] then
            return
        end

        TriggerEvent('cd_garage:PlateChangedPersistentVehicles', oldPlate, newPlate)

        if Sky.Config.framework == "esx" then
            local row = rows[1]
            local vehicleJson = row.vehicle
            local advStatsJson = row.adv_stats

            local okVeh, vehicleData = pcall(json.decode, vehicleJson or "")
            if okVeh and type(vehicleData) == "table" then
                vehicleData.plate = newPlate
                vehicleJson = json.encode(vehicleData)
            end

            local okAdv, advStats = pcall(json.decode, advStatsJson or "")
            if okAdv and type(advStats) == "table" then
                advStats.plate = newPlate
                advStatsJson = json.encode(advStats)
            end

            Sky.Query("UPDATE owned_vehicles SET vehicle = ?, adv_stats = ? WHERE plate = ?", {
                vehicleJson or row.vehicle,
                advStatsJson or row.adv_stats,
                newPlate
            })
        else
            local row = rows[1]
            local modsJson = row.mods

            local okMods, mods = pcall(json.decode, modsJson or "")
            if okMods and type(mods) == "table" then
                mods.plate = newPlate
                modsJson = json.encode(mods)
            end

            Sky.Query("UPDATE player_vehicles SET mods = ? WHERE plate = ?", {
                modsJson or row.mods,
                newPlate
            })
        end
    end
end
