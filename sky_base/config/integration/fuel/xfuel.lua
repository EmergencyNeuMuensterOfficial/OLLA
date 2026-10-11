if Sky.Config.fuel == "xfuel" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports['x-fuel']:GetFuel(vehicle)
    end
    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports['x-fuel']:SetFuel(vehicle, fuel)
    end
end
