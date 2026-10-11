local isVisible = false
local needs = { hunger = 100, thirst = 100 }

local function percentage(value)
    return math.max(0, math.min(100, math.floor(tonumber(value) or 0)))
end

local function updateEconomy()
    local data = lib.callback.await('drp_hud:getPlayerData', false)
    if not data then return end

    SendNUIMessage({ action = 'economy', data = data })
end

local function setVisible(value)
    if isVisible == value then return end
    isVisible = value
    SendNUIMessage({ action = 'visibility', visible = value })
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local health = math.max(0, GetEntityHealth(ped) - 100)
        local armour = GetPedArmour(ped)
        local stamina = GetPlayerSprintStaminaRemaining(PlayerId())
        local inVehicle = IsPedInAnyVehicle(ped, false)
        local speed = 0

        if inVehicle then
            speed = math.floor(GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * 3.6)
        end

        local coords = GetEntityCoords(ped)
        local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street = GetStreetNameFromHashKey(streetHash)
        local crossing = crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or ''

        SendNUIMessage({
            action = 'status',
            health = percentage(health),
            armour = percentage(armour),
            hunger = percentage(needs.hunger),
            thirst = percentage(needs.thirst),
            stamina = percentage(stamina),
            talking = NetworkIsPlayerTalking(PlayerId()),
            inVehicle = inVehicle,
            speed = speed,
            street = crossing ~= '' and (street .. ' / ' .. crossing) or street,
            time = GetClockHours() .. ':' .. string.format('%02d', GetClockMinutes()),
        })

        Wait(250)
    end
end)

-- Other Dülmen scripts can update the survival values with this event.
RegisterNetEvent('drp_hud:client:setNeeds', function(hunger, thirst)
    if type(hunger) == 'table' then
        thirst = hunger.thirst
        hunger = hunger.hunger
    end
    if hunger ~= nil then needs.hunger = percentage(hunger) end
    if thirst ~= nil then needs.thirst = percentage(thirst) end
end)

-- Temporary standalone survival drain until a dedicated needs resource owns it.
CreateThread(function()
    while true do
        Wait(60000)
        if isVisible then
            needs.hunger = math.max(0, needs.hunger - 1)
            needs.thirst = math.max(0, needs.thirst - 1)
        end
    end
end)

CreateThread(function()
    while true do
        if isVisible then updateEconomy() end
        Wait(3000)
    end
end)

RegisterNetEvent('drp_core:client:characterSelected', function()
    setVisible(true)
    updateEconomy()
end)

RegisterCommand('togglehud', function()
    setVisible(not isVisible)
end, false)

RegisterKeyMapping('togglehud', 'Toggle Dülmen Roleplay HUD', 'keyboard', 'F10')

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SendNUIMessage({ action = 'visibility', visible = false })
end)
