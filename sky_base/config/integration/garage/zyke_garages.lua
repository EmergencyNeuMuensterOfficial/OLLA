if Sky.Config.garage == "zyke_garages" then
    function Sky.Functions.IsPlateUsed(plate)
        local vin = exports["zyke_garages"]:ResolveVehicleVin(plate)
        return vin ~= nil
    end

    function Sky.Functions.GeneratePlate()
        -- Zyke handles plate generation internally.
        -- This only exists for compatibility with scripts expecting it.
        math.randomseed(GetGameTimer())

        local plate = string.upper(
            Sky.Math.GetRandomLetters(3) ..
            Sky.Math.GetRandomNumbers(3)
        )

        if Sky.Functions.IsPlateUsed(plate) then
            return Sky.Functions.GeneratePlate()
        end

        return plate
    end

    function Sky.Functions.GiveVehicle(source, model)
        local success, vehicleData = exports["zyke_garages"]:GiveVehicle(model, source)

        if not success then
            print(("Sky Base: Failed to give vehicle (%s)"):format(vehicleData))
            return false
        end

        return vehicleData
    end

    function Sky.Functions.ChangePlate(oldPlate, newPlate)
        local vin = exports["zyke_garages"]:ResolveVehicleVin(oldPlate)

        if not vin then
            return false
        end

        exports["zyke_garages"]:SetFakePlate(
            vin,
            newPlate,
            true,
            false
        )

        return true
    end
end
