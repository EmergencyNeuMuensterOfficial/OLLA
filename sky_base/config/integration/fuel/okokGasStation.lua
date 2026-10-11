if Sky.Config.fuel == "okokGasStation" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports['okokGasStation']:GetFuel(vehicle)
    end

    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports['okokGasStation']:SetFuel(vehicle, fuel)
    end
end