if Sky.Config.fuel == "legacy" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["LegacyFuel"]:GetFuel(vehicle)
    end
    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["LegacyFuel"]:SetFuel(vehicle, fuel)
    end
    function Sky.Functions.SetVehicleFuelType(_vehicle, _fuel_type)
        -- LegacyFuel does not support per-vehicle fuel types.
    end
end

