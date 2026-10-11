if Sky.Config.vehiclekeys == "quasar" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        if not model then return end
        exports["qs-vehiclekeys"]:GiveKeys(plate, model, true)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        if not model then return end
        exports["qs-vehiclekeys"]:RemoveKeys(plate, model)
    end
end
