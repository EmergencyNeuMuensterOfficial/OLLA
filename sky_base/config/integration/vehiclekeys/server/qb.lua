if Sky.Config.vehiclekeys == "qb" and GetResourceState("qb-vehiclekeys") == "started" then
    function Sky.VehicleKeys.Give(player_id, plate, model)
        exports["qb-vehiclekeys"]:GiveKeys(player_id, plate)
    end

    function Sky.VehicleKeys.Remove(player_id, plate, model)
        exports["qb-vehiclekeys"]:RemoveKeys(player_id, plate)
    end

    AddEventHandler("onResourceStart", function(resource_name)
        if resource_name == "qb-vehiclekeys" then
            TriggerEvent("sky_base:vehicleKeysReady")
        end
    end)
end
