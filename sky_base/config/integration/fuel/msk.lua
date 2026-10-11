if Sky.Config.fuel == "msk" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["msk_fuel"]:GetVehicleFuel(vehicle)
    end

    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["msk_fuel"]:SetVehicleFuel(vehicle, fuel)
    end

    function Sky.Functions.SetVehicleFuelType(vehicle, fuel_type)
        exports["msk_fuel"]:SetVehicleFuelType(vehicle, fuel_type)
    end
end
