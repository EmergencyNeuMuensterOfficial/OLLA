if Sky.Config.fuel == "qs-fuelstation" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["qs-fuelstations"]:GetFuel(vehicle)
    end

    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["qs-fuelstations"]:SetFuel(vehicle, fuel)
    end
end
