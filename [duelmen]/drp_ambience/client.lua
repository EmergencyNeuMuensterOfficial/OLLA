-- Prevent ambient population from being created in the first place.
-- This avoids the spawn/despawn loop and the lag it caused.
CreateThread(function()
    SetAllVehicleGeneratorsActive(false)
    SetGarbageTrucks(false)
    SetRandomBoats(false)

    while true do
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetPedDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        SetPedPopulationBudget(0)
        SetVehiclePopulationBudget(0)

        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)

        Wait(0)
    end
end)

-- Remove only the initial local ambient peds that existed when the player joined.
-- No repeating entity-deletion loop: population budgets above prevent replacements.
CreateThread(function()
    Wait(2000)
    local coords = GetEntityCoords(PlayerPedId())
    ClearAreaOfPeds(coords.x, coords.y, coords.z, 500.0, 1)
end)
