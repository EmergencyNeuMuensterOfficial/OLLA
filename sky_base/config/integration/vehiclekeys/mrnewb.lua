if Sky.Config.vehiclekeys == "mrnewb" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        if not vehicle then return end
        exports["MrNewbVehicleKeys"]:GiveKeys(vehicle)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        if not vehicle then return end
        exports["MrNewbVehicleKeys"]:RemoveKeys(vehicle)
    end
end
