if Sky.Config.vehiclekeys == "brutal" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        exports["brutal_keys"]:addVehicleKey(plate, "Vehicle Keys")
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        exports["brutal_keys"]:removeKey(plate, false)
    end
end
