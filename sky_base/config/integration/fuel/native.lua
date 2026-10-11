if Sky.Config.fuel == "native" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return GetVehicleFuelLevel(vehicle)
    end
    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
    end
end
