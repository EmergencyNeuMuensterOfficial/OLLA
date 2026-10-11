if Sky.Config.vehiclekeys == "qb" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        TriggerEvent("qb-vehiclekeys:client:RemoveKeys", plate)
    end
end
