-- Server-authorized grants. Providers with server exports override the client bridge below.
Sky.VehicleKeys = {}

function Sky.VehicleKeys.Give(player_id, plate, model)
    if Sky.Config.vehiclekeys == "auto" or Sky.Config.vehiclekeys == "none" then return end
    TriggerClientEvent("sky_base:client:giveVehicleKeys", player_id, plate, model)
end

function Sky.VehicleKeys.Remove(player_id, plate, model)
    if Sky.Config.vehiclekeys == "auto" or Sky.Config.vehiclekeys == "none" then return end
    TriggerClientEvent("sky_base:client:removeVehicleKeys", player_id, plate, model)
end
