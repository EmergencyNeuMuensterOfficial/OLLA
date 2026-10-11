if Sky.Config.fuel == "stg-van" then
    function Sky.Functions.GetVehicleFuel(vehicle)
        return exports["stg-vanaheimfuel"]:GetFuel(vehicle)
    end

    function Sky.Functions.SetVehicleFuel(vehicle, fuel)
        exports["stg-vanaheimfuel"]:SetFuel(vehicle, fuel)
    end
end
