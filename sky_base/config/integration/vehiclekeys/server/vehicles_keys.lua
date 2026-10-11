if Sky.Config.vehiclekeys == "vehicles_keys" then
    function Sky.VehicleKeys.Give(player_id, plate, model)
        -- Crime owns persistence; session keys must be restored from its current authorization.
        exports["vehicles_keys"]:giveVehicleKeysToPlayerId(player_id, plate, "temporary")
    end

    function Sky.VehicleKeys.Remove(player_id, plate, model)
        exports["vehicles_keys"]:removeKeysFromPlayerId(player_id, plate)
    end

    AddEventHandler("onResourceStart", function(resource_name)
        if resource_name == "vehicles_keys" then
            TriggerEvent("sky_base:vehicleKeysReady")
        end
    end)
end
