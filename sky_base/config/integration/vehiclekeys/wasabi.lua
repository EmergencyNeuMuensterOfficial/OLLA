if Sky.Config.vehiclekeys == "wasabi" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        exports["wasabi_carlock"]:GiveKey(plate)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        exports["wasabi_carlock"]:RemoveKey(plate)
    end
end
