if Sky.Config.fuel == "hex" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["hex_3_fuel"]:GetFuel(vehicle)
    end
    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["hex_3_fuel"]:SetFuel(vehicle, fuel)
    end
end
