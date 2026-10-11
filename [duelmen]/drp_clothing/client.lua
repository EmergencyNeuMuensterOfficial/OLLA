local clerks = {}
local shopZones, shopBlips = {}, {}
local beforeShopping
local previewCamera
local previewHeading
local previewPendingPurchase = false

local function notify(message, kind)
    lib.notify({ title = 'Dülmen Kleidung', description = message, type = kind or 'inform' })
end

local function captureAppearance()
    local ped = PlayerPedId()
    local appearance = { components = {}, props = {} }
    for component = 0, 11 do
        appearance.components[component] = {
            drawable = GetPedDrawableVariation(ped, component),
            texture = GetPedTextureVariation(ped, component),
            palette = GetPedPaletteVariation(ped, component),
        }
    end
    for prop = 0, 7 do
        appearance.props[prop] = {
            drawable = GetPedPropIndex(ped, prop),
            texture = GetPedPropTextureIndex(ped, prop),
        }
    end
    return appearance
end

local function applyAppearance(appearance)
    if type(appearance) ~= 'table' then return end
    local ped = PlayerPedId()
    for component, value in pairs(appearance.components or {}) do
        local id = tonumber(component)
        if id and type(value) == 'table' then
            SetPedComponentVariation(ped, id, tonumber(value.drawable) or 0, tonumber(value.texture) or 0, tonumber(value.palette) or 0)
        end
    end
    for prop, value in pairs(appearance.props or {}) do
        local id = tonumber(prop)
        if id and type(value) == 'table' then
            local drawable = tonumber(value.drawable) or -1
            if drawable < 0 then ClearPedProp(ped, id)
            else SetPedPropIndex(ped, id, drawable, tonumber(value.texture) or 0, true) end
        end
    end
end

local function stopPreview(restoreAppearance)
    local ped = PlayerPedId()
    if restoreAppearance and beforeShopping then applyAppearance(beforeShopping) end
    if previewHeading then SetEntityHeading(ped, previewHeading) end
    FreezeEntityPosition(ped, false)
    if previewCamera then
        RenderScriptCams(false, true, 350, true, true)
        DestroyCam(previewCamera, false)
        previewCamera = nil
    end
    SetNuiFocusKeepInput(false)
    previewHeading = nil
end

local function startPreview()
    local ped = PlayerPedId()
    previewHeading = GetEntityHeading(ped)
    FreezeEntityPosition(ped, true)
    previewCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    local position = GetEntityCoords(ped)
    local radians = math.rad(previewHeading)
    SetCamCoord(previewCamera, position.x + math.sin(radians) * 2.15, position.y - math.cos(radians) * 2.15, position.z + 0.72)
    PointCamAtEntity(previewCamera, ped, 0.0, 0.0, 0.58, true)
    SetCamFov(previewCamera, 40.0)
    SetCamActive(previewCamera, true)
    RenderScriptCams(true, true, 350, true, true)
    SetNuiFocusKeepInput(false)
    SetNuiFocus(true, true)
end

CreateThread(function()
    while true do
        if previewCamera then
            -- The clothing menu exclusively owns keyboard and mouse input.
            DisableAllControlActions(0)
            DisablePlayerFiring(PlayerId(), true)
            SetNuiFocusKeepInput(false)
            SetNuiFocus(true, true)
            Wait(0)
        else
            Wait(250)
        end
    end
end)

local function numberedValues(first, last)
    local values = {}
    for value = first, last do values[#values + 1] = ('Variante %s'):format(value) end
    return values
end

local function setComponent(id, value)
    local ped = PlayerPedId()
    local texture = GetPedTextureVariation(ped, id)
    local textureMaximum = math.max(GetNumberOfPedTextureVariations(ped, id, value) - 1, 0)
    SetPedComponentVariation(ped, id, value, math.min(texture, textureMaximum), 0)
end

local function setProp(id, value)
    local ped = PlayerPedId()
    if value < 0 then return ClearPedProp(ped, id) end
    local texture = math.max(GetPedPropTextureIndex(ped, id), 0)
    local textureMaximum = math.max(GetNumberOfPedPropTextureVariations(ped, id, value) - 1, 0)
    SetPedPropIndex(ped, id, value, math.min(texture, textureMaximum), true)
end

-- The archive replaces two drawables in the original Gunrunning female
-- collection. Collection-local indexes do not move when Rockstar releases a
-- title update, unlike the generic global clothing indexes.
local function getShelbyTextureCount(ped, localDrawable)
    return GetNumberOfPedCollectionTextureVariations(ped, 11, 'mp_f_gunrunning_01', localDrawable)
end

local function setShelbyDress(localDrawable, texture)
    SetPedCollectionComponentVariation(PlayerPedId(), 11, 'mp_f_gunrunning_01', localDrawable, texture, 0)
end

local function openShop()
    if previewCamera then return end
    -- Shelby's collection only contains mp_f_freemode_01 assets. Keep the
    -- standard shop available to everyone, but make the limitation clear so
    -- male characters do not mistake a vanilla drawable for the dress pack.
    if GetEntityModel(PlayerPedId()) ~= joaat('mp_f_freemode_01') then
        lib.notify({
            title = 'Dülmen Kleidung',
            description = 'Das Shelbys Dress Pack ist nur für weibliche Freemode-Charaktere verfügbar.',
            type = 'inform',
        })
    end
    beforeShopping = captureAppearance()
    previewPendingPurchase = false
    startPreview()

    local ped = PlayerPedId()
    local options = {
        {
            label = 'Ansicht drehen', icon = 'rotate', close = false,
            values = { 'Vorne', 'Rechte Seite', 'Hinten', 'Linke Seite' }, defaultIndex = 1,
            args = { action = 'rotate' },
        },
    }
    if GetEntityModel(ped) == joaat('mp_f_freemode_01') then
        for _, dress in ipairs({
            { label = 'Shelby Dress – Modell 1', drawable = 2 },
            { label = 'Shelby Dress – Modell 2', drawable = 8 },
        }) do
            local textures = getShelbyTextureCount(ped, dress.drawable)
            if textures > 0 then
                options[#options + 1] = {
                    label = dress.label,
                    description = ('Shelbys Dress Pack · %s Varianten'):format(textures),
                    icon = 'person-dress', close = false,
                    values = numberedValues(0, textures - 1), defaultIndex = 1,
                    args = { action = 'shelby_dress', drawable = dress.drawable },
                }
            end
        end
    end
    for _, item in ipairs(DRPClothing.Components) do
        local maximum = math.max(GetNumberOfPedDrawableVariations(ped, item.id) - 1, 0)
        options[#options + 1] = {
            label = item.label, icon = 'shirt', close = false,
            values = numberedValues(0, maximum), defaultIndex = GetPedDrawableVariation(ped, item.id) + 1,
            args = { action = 'component', id = item.id },
        }
    end
    for _, item in ipairs(DRPClothing.Props) do
        local maximum = math.max(GetNumberOfPedPropDrawableVariations(ped, item.id) - 1, -1)
        options[#options + 1] = {
            label = item.label, icon = 'glasses', close = false,
            values = numberedValues(-1, maximum), defaultIndex = GetPedPropIndex(ped, item.id) + 2,
            args = { action = 'prop', id = item.id },
        }
    end
    options[#options + 1] = { label = ('Outfit kaufen & speichern – $%s'):format(DRPClothing.PurchasePrice), icon = 'cash-register', iconColor = 'green', args = { action = 'buy' } }
    options[#options + 1] = { label = 'Änderungen verwerfen', icon = 'rotate-left', iconColor = 'red', args = { action = 'cancel' } }

    lib.registerMenu({
        id = 'drp_clothing_live', title = 'Dülmen Kleidung – Live Vorschau', position = 'top-right', canClose = true, options = options,
        onClose = function()
            if not previewPendingPurchase then stopPreview(true) end
        end,
        onSideScroll = function(_, scrollIndex, args)
            if not args then return end
            if args.action == 'rotate' then SetEntityHeading(PlayerPedId(), previewHeading + ((scrollIndex - 1) * 90.0))
            elseif args.action == 'component' then setComponent(args.id, scrollIndex - 1)
            elseif args.action == 'prop' then setProp(args.id, scrollIndex - 2)
            elseif args.action == 'shelby_dress' then setShelbyDress(args.drawable, scrollIndex - 1) end
        end,
    }, function(_, _, args)
        if not args then return end
        if args.action == 'buy' then
            previewPendingPurchase = true
            TriggerServerEvent('drp_clothing:server:purchase', captureAppearance())
        elseif args.action == 'cancel' then
            stopPreview(true)
            beforeShopping = nil
            notify('Dein vorheriges Outfit wurde wiederhergestellt.')
        end
    end)
    lib.showMenu('drp_clothing_live')
end

-- Useful for testing and as an accessibility fallback if a store ped has not
-- streamed yet. The normal way to open the menu remains the shop NPC.
RegisterCommand('clothes', openShop, false)

RegisterNetEvent('drp_clothing:client:purchaseResult', function(success, message)
    if success then
        stopPreview(false)
        beforeShopping = nil
    else
        stopPreview(true)
    end
    previewPendingPurchase = false
    notify(message, success and 'success' or 'error')
end)

RegisterNetEvent('drp_clothing:client:loadAppearance', function()
    local appearance = lib.callback.await('drp_clothing:server:getAppearance', false)
    if appearance then applyAppearance(appearance) end
end)

CreateThread(function()
    for index, location in ipairs(DRPClothing.Locations) do
        shopZones[#shopZones + 1] = exports.ox_target:addSphereZone({
            coords = vector3(location.x, location.y, location.z),
            radius = 1.75,
            options = {
                { name = ('drp_clothing_zone_%s'):format(index), icon = 'fa-solid fa-shirt', label = 'Kleidung kaufen', distance = 2.0, onSelect = openShop },
            },
        })
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, 73)
        SetBlipColour(blip, 47)
        SetBlipScale(blip, 0.72)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Dülmen Kleidung')
        EndTextCommandSetBlipName(blip)
        shopBlips[#shopBlips + 1] = blip
    end

    local model = joaat(DRPClothing.ClerkModel)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    if not HasModelLoaded(model) then return end

    for index, location in ipairs(DRPClothing.Locations) do
        local clerk = CreatePed(4, model, location.x, location.y, location.z - 1.0, location.w, false, true)
        SetEntityInvincible(clerk, true)
        FreezeEntityPosition(clerk, true)
        SetBlockingOfNonTemporaryEvents(clerk, true)
        TaskStartScenarioInPlace(clerk, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
        clerks[#clerks + 1] = clerk
        exports.ox_target:addLocalEntity(clerk, {
            { name = ('drp_clothing_shop_%s'):format(index), icon = 'fa-solid fa-shirt', label = 'Kleidung kaufen', distance = 2.0, onSelect = openShop },
        })
    end
    SetModelAsNoLongerNeeded(model)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    stopPreview(true)
    for _, clerk in ipairs(clerks) do if DoesEntityExist(clerk) then DeleteEntity(clerk) end end
    for _, zone in ipairs(shopZones) do exports.ox_target:removeZone(zone) end
    for _, blip in ipairs(shopBlips) do RemoveBlip(blip) end
end)
