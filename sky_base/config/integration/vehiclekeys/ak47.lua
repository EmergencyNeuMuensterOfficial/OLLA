if Sky.Config.vehiclekeys == "ak47" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        if Sky.Config.framework == "esx" then 
            exports['ak47_vehiclekeys']:GiveKey(plate, false)
        elseif Sky.Config.framework == "qb" or "qbox" then
            exports['ak47_qb_vehiclekeys']:GiveKey(plate, false)
        end
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        if Sky.Config.framework == "esx" then 
            exports['ak47_vehiclekeys']:RemoveKey(plate, false)
        elseif Sky.Config.framework == "qb" or "qbox" then
            exports['ak47_qb_vehiclekeys']:RemoveKey(plate, false)
        end
    end
end
