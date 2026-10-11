if Sky.Config.vehiclekeys == "msk" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        local vehicle_data = vehicle or {
            plate = plate,
            model = type(model) == "string" and joaat(model) or model
        }
        exports["msk_vehiclekeys"]:AddKey(vehicle_data, "temporary")
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        local vehicle_data = vehicle or {
            plate = plate,
            model = type(model) == "string" and joaat(model) or model
        }
        exports["msk_vehiclekeys"]:RemoveKey(vehicle_data, "temporary")
    end
end
