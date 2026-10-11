if Sky.Config.vehiclekeys == "jota" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        exports['jc_vehiclekeys']:GiveKeys(plate)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        exports['jc_vehiclekeys']:RemoveKeys(plate)
    end
end
