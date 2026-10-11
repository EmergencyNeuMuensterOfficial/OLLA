if Sky.Config.vehiclekeys == "mk" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        if not vehicle then return end
        exports["mk_vehiclekeys"]:AddKey(vehicle)
    end
end
