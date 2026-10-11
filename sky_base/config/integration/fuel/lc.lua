if Sky.Config.fuel == "lc" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["lc_fuel"]:GetFuel(vehicle)
    end
    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["lc_fuel"]:SetFuel(vehicle, fuel)
    end
    function Sky.Functions.SetVehicleFuelType(vehicle, fuelType)
        exports["lc_fuel"]:SetFuelType(vehicle, fuelType) -- nil resets to default
    end
end
