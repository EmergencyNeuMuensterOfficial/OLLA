if Sky.Config.fuel ~= "qb" then return end

function Sky.Functions.GetVehicleFuel(vehicle)
    return exports["qb-fuel"]:GetFuel(vehicle)
end

function Sky.Functions.SetVehicleFuel(vehicle, fuel)
    exports["qb-fuel"]:SetFuel(vehicle, fuel)
end
