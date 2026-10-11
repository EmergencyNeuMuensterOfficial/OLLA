if Sky.Config.garage == "qbox" then
    function Sky.Functions.IsPlateUsed(plate)
        local result = Sky.Query('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
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
    
        -- Qbox --
        local pData = exports.qbx_core:GetPlayer(source)
        Sky.Query('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            pData.PlayerData.license,
            pData.PlayerData.citizenid, 
            model, 
            GetHashKey(model),
            '{}',
            plate,
            1,
            "pillboxgarage"
        })
        TriggerClientEvent("sky_base:client:giveVehicleKeys", source, plate, model)
    end

    function Sky.Functions.ChangePlate(oldPlate, newPlate)
        Sky.Query('UPDATE player_vehicles SET plate = ? WHERE plate = ?', {newPlate, oldPlate})
    end
end
