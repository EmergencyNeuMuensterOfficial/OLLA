if Sky.Config.vehiclekeys == "kiminaze" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        TriggerServerEvent("sky_base:kiminaze:giveKeys", plate)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        TriggerServerEvent("sky_base:kiminaze:removeKeys", plate)
    end
end
