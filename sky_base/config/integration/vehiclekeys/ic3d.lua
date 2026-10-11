if Sky.Config.vehiclekeys == "ic3d" then
    function Sky.Functions.GiveVehicleKeys(vehicle, plate, model)
        exports.ic3d_vehiclekeys:ClientInventoryKeys('add', plate)
    end

    function Sky.Functions.RemoveVehicleKeys(vehicle, plate, model)
        exports.ic3d_vehiclekeys:ClientInventoryKeys('remove', plate)
    end
end