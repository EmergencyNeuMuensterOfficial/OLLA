if Sky.Config.garage == "rx" then
    local tableName = Sky.Config.framework == "esx" and "owned_vehicles" or "player_vehicles"

    function Sky.Functions.IsPlateUsed(plate)
        result = Sky.Query('SELECT plate FROM ' .. tableName .. ' WHERE plate = ?', { plate })
        return result[1] ~= nil
    end

    function Sky.Functions.GeneratePlate()
        math.randomseed(GetGameTimer())
        local plate = string.upper(Sky.Math.GetRandomLetters(3) .. ' ' .. Sky.Math.GetRandomNumbers(3))

        if Sky.Functions.IsPlateUsed(plate) then
            return Sky.Functions.GeneratePlate()
        end

        return plate
    end

    function Sky.Functions.GiveVehicle(source, model)
        local plate = Sky.Functions.GeneratePlate()
        local vehicleProps = { model = GetHashKey(model), plate = plate }

        if Sky.Config.framework == "esx" then
            local identifier = Sky.FW.GetIdentifier(source)
            Sky.Query('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type, parked_at) VALUES (@owner, @plate, @vehicle, @stored, @type, @parked_at)',
            {
                ['@owner'] = identifier,
                ['@plate'] = plate,
                ['@vehicle'] = json.encode(vehicleProps),
                ['@stored'] = 1,
                ['@type'] = 'car',
                ['@parked_at'] = 'garage'
            })
        else
            local pData = nil
            if Sky.Config.framework == "qb" then
                pData = QBCore.Functions.GetPlayer(source)
            elseif Sky.Config.framework == "qbox" then
                pData = exports.qbx_core:GetPlayer(source)
            end 
            Sky.Query('INSERT INTO player_vehicles (license, citizenid, plate, vehicle, parked_at) VALUES (@license, @citizenid, @plate, @vehicle, @parked_at)',
            {
                ['@license'] = string.gsub(pData.PlayerData.license, "license:", ""),
                ['@citizenid'] = pData.PlayerData.citizenid,
                ['@plate'] = plate,
                ['@vehicle'] = json.encode(vehicleProps),
                ['@parked_at'] = 'garage'
            })
        end
    end
end

