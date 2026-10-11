if Sky.Config.vehiclekeys == "zyke_garages" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        if not DoesEntityExist(vehicle) then return end

        exports["zyke_garages"]:GiveKey(vehicle)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        if not DoesEntityExist(vehicle) then return end

        exports["zyke_garages"]:RemoveKey(vehicle)
    end
end
