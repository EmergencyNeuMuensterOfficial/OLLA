if Sky.Config.fuel == "cdn" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["cdn-fuel"]:GetFuel(vehicle)
    end

    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["cdn-fuel"]:SetFuel(vehicle, fuel)
    end
end
