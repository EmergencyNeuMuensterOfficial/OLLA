if Sky.Config.fuel == "myFuel" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["myFuel"]:GetFuel(vehicle)
    end
    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["myFuel"]:SetFuel(vehicle, fuel)
    end
end
