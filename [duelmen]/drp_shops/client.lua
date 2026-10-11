local spawnedClerks = {}
local shopZones, shopBlips = {}, {}

local function loadModel(modelName)
    local model = joaat(modelName)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    return HasModelLoaded(model) and model or nil
end

local function openShop(shopType, locationId)
    exports.ox_inventory:openInventory('shop', { type = shopType, id = locationId })
end

local function spawnClerk(modelName, coords, shopType, locationId, label, scenario)
    local model = loadModel(modelName)
    if not model then
        print(('[drp_shops] Could not load ped model %s'):format(modelName))
        return
    end

    local ped = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, coords.w or 0.0, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, scenario, 0, true)

    spawnedClerks[#spawnedClerks + 1] = ped
    exports.ox_target:addLocalEntity(ped, {
        {
            name = ('drp_shop_%s_%s'):format(shopType, locationId),
            icon = 'fa-solid fa-basket-shopping',
            label = label,
            distance = 2.0,
            onSelect = function()
                openShop(shopType, locationId)
            end,
        },
    })
    SetModelAsNoLongerNeeded(model)
end

local function addShopLocation(coords, shopType, locationId, label, sprite, colour)
    -- The zone remains available even if an NPC is delayed by client streaming.
    shopZones[#shopZones + 1] = exports.ox_target:addSphereZone({
        coords = vector3(coords.x, coords.y, coords.z),
        radius = 1.75,
        options = {
            {
                name = ('drp_shop_zone_%s_%s'):format(shopType, locationId),
                icon = 'fa-solid fa-basket-shopping',
                label = label,
                distance = 2.0,
                onSelect = function() openShop(shopType, locationId) end,
            },
        },
    })

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, 0.72)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    shopBlips[#shopBlips + 1] = blip
end

CreateThread(function()
    for index, location in ipairs(DRPShops.GasLocations) do
        local coords = vector4(location.x, location.y, location.z, 0.0)
        addShopLocation(coords, 'drp_gas', index, 'Dülmen Tankstellenshop', 52, 2)
        spawnClerk(DRPShops.GasClerkModel, coords, 'drp_gas', index, 'Tankstellenshop öffnen', 'WORLD_HUMAN_STAND_IMPATIENT')
    end
    for index, location in ipairs(DRPShops.PhoneLocations) do
        local coords = vector4(location.x, location.y, location.z, (DRPShops.PhoneHeadings or {})[index] or 0.0)
        addShopLocation(coords, 'drp_phone', index, 'Dülmen Phone-Shop', 521, 3)
        spawnClerk(DRPShops.PhoneClerkModel, coords, 'drp_phone', index, 'Phone-Shop öffnen', 'WORLD_HUMAN_STAND_MOBILE')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, ped in ipairs(spawnedClerks) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for _, zone in ipairs(shopZones) do exports.ox_target:removeZone(zone) end
    for _, blip in ipairs(shopBlips) do RemoveBlip(blip) end
end)
