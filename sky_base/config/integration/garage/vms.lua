if Sky.Config.garage == "vms" then
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
        local garage = "Impound1"

        if mods.class == 14 then
            garage = "ImpoundBoat"
            vehicleType = "boat"
        elseif mods.class == 15 then
            garage = "ImpoundHeli"
            vehicleType = "helicopter"
        elseif mods.class == 16 then
            garage = "ImpoundPlane"
            vehicleType = "plane"
        end
        if Sky.Config.framework == "esx" then
            local xPlayer = ESX.GetPlayerFromId(source)
            Sky.Query('INSERT INTO owned_vehicles (owner, plate, vehicle, type, garage, impound_date) VALUES (?, ?, ?, ?, ?, ?)', {
                xPlayer.identifier,
                plate,
                json.encode({['model'] = GetHashKey(model), ['plate'] = plate}),
                vehicleType,
                garage,
                os.time()
            })
        elseif Sky.Config.framework == "qb" or Sky.Config.framework == "qbox" then
            local pData = QBCore.Functions.GetPlayer(source)
            Sky.Query('INSERT INTO player_vehicles (citizenid, vehicle, hash, mods, plate, type, garage, impound_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                pData.PlayerData.citizenid, 
                model, 
                GetHashKey(model),
                json.encode({['model'] = GetHashKey(model), ['plate'] = plate}),
                plate, 
                vehicleType,
                garage,
                os.time()
            })
        end
        TriggerClientEvent("sky_base:client:giveVehicleKeys", source, plate, model)
    end

    function Sky.Functions.ChangePlate(oldPlate, newPlate, src)
        if Sky.Config.framework == "esx" then
            local vehicleData = Sky.Query('SELECT vehicle, netid FROM owned_vehicles WHERE plate = ?', {oldPlate})
            if vehicleData[1] then
                local vehicle = json.decode(vehicleData[1].vehicle)
                vehicle.plate = newPlate
                Sky.Query('UPDATE owned_vehicles SET plate = ?, vehicle = ? WHERE plate = ?', {newPlate, json.encode(vehicle), oldPlate})
                
                if GetResourceState("vms_garagesv2") == "started" then
                    exports["vms_garagesv2"]:updateParkedVehiclePlate(oldPlate, newPlate, true)
                end
            
                local netId = vehicleData[1].netid
                if netId then
                    local vehicle = NetworkGetEntityFromNetworkId(netId)
                    while not DoesEntityExist(vehicle) do Wait(0) end

                    SetVehicleNumberPlateText(vehicle, newPlate)
                    local state = Entity(vehicle).state
                    local VehicleProperties = state.VehicleProperties
                    VehicleProperties.plate = newPlate
                    state:set("VehicleProperties", VehicleProperties, true)
                end
            end
        elseif Sky.Config.framework == "qb" or Sky.Config.framework == "qbox" then
            Sky.Query('UPDATE player_vehicles SET plate = ? WHERE plate = ?', {newPlate, oldPlate})
            TriggerClientEvent("sky_base:client:giveVehicleKeys", src, newPlate)
        end
    end
end
