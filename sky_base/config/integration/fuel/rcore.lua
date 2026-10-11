if Sky.Config.fuel == "rcore" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["rcore_fuel"]:GetVehicleFuelPercentage(vehicle)
    end
    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["rcore_fuel"]:SetVehicleFuel(vehicle, fuel)
    end
end
