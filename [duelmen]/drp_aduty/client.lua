local originalAppearance
local currentDuty

-- These component variants are the streamed staff suits used by this server.
local maleModel = joaat('mp_m_freemode_01')
local femaleModel = joaat('mp_f_freemode_01')

local function requestModel(model)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    return HasModelLoaded(model)
end

local componentIds = {
    tshirt = 8, torso = 11, decals = 10, arms = 3, pants = 4,
    shoes = 6, mask = 1, chain = 7, bags = 5, bproof = 9,
    hair = 2,
}

local function applyUniform(ped, uniform)
    for name, componentId in pairs(componentIds) do
        local value = uniform[name]
        if value then
            SetPedComponentVariation(ped, componentId, value[1], value[2], 0)
        end
    end

    ClearAllPedProps(ped)
    for propId, name in pairs({ [0] = 'helmet', [2] = 'ears' }) do
        local value = uniform[name]
        if value and value[1] >= 0 then
            SetPedPropIndex(ped, propId, value[1], value[2], true)
        else
            ClearPedProp(ped, propId)
        end
    end
end

local function captureAppearance(ped)
    local appearance = {
        model = GetEntityModel(ped),
        health = GetEntityHealth(ped),
        armour = GetPedArmour(ped),
        components = {},
        props = {},
    }

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

local function restoreAppearance()
    if not originalAppearance then return end

    local saved = originalAppearance
    if requestModel(saved.model) then
        SetPlayerModel(PlayerId(), saved.model)
        Wait(0)
        local ped = PlayerPedId()
        for component, data in pairs(saved.components) do
            SetPedComponentVariation(ped, component, data.drawable, data.texture, data.palette)
        end
        for prop, data in pairs(saved.props) do
            if data.drawable and data.drawable >= 0 then
                SetPedPropIndex(ped, prop, data.drawable, data.texture, true)
            else
                ClearPedProp(ped, prop)
            end
        end
        SetEntityHealth(ped, math.max(100, saved.health))
        SetPedArmour(ped, saved.armour)
        SetModelAsNoLongerNeeded(saved.model)
    end

    originalAppearance = nil
    currentDuty = nil
    lib.notify({ title = 'Admin-Dienst', description = 'Dein vorheriges Outfit wurde wiederhergestellt.', type = 'success' })
end

local function applyOutfit(roleId)
    local role = ADuty.Roles[roleId]
    if not role then return end

    local ped = PlayerPedId()
    if not originalAppearance then originalAppearance = captureAppearance(ped) end

    local useFemale = GetEntityModel(ped) == femaleModel
    local model = useFemale and femaleModel or maleModel
    -- Do not recreate a freemode player ped: doing so resets its saved face,
    -- hair and overlays. Only use a fallback freemode model for non-freemode
    -- peds.
    if GetEntityModel(ped) ~= maleModel and GetEntityModel(ped) ~= femaleModel then
        if not requestModel(model) then
            lib.notify({ title = 'Admin-Dienst', description = 'Staff-Modell konnte nicht geladen werden.', type = 'error' })
            return
        end

        SetPlayerModel(PlayerId(), model)
        Wait(0)
        ped = PlayerPedId()
    end

    local outfit = ADuty.Outfits[role.outfit]
    local uniform = outfit and (useFemale and outfit.female or outfit.male)
    if not uniform then
        lib.notify({ title = 'Admin-Dienst', description = 'Das Uniform-Setup fehlt.', type = 'error' })
        return
    end

    applyUniform(ped, uniform)

    currentDuty = roleId
    SetModelAsNoLongerNeeded(model)
    lib.notify({ title = 'Admin-Dienst', description = ('Du bist jetzt als %s im Dienst.'):format(role.label), type = 'success' })
end

RegisterNetEvent('drp_aduty:client:openMenu', function(roles, activeRole)
    local options = {}
    for _, role in ipairs(roles) do
        options[#options + 1] = {
            title = role.label,
            description = role.description,
            icon = 'user-tie',
            iconColor = ADuty.Roles[role.id].colour,
            onSelect = function()
                TriggerServerEvent('drp_aduty:server:setDuty', role.id)
            end,
        }
    end

    if activeRole then
        options[#options + 1] = {
            title = 'Dienst beenden',
            description = 'Vorheriges Outfit wiederherstellen',
            icon = 'user-slash',
            iconColor = 'red',
            onSelect = function()
                TriggerServerEvent('drp_aduty:server:endDuty')
            end,
        }
    end

    lib.registerContext({ id = 'drp_aduty_menu', title = 'Admin-Dienst', options = options })
    lib.showContext('drp_aduty_menu')
end)

RegisterNetEvent('drp_aduty:client:applyOutfit', applyOutfit)
RegisterNetEvent('drp_aduty:client:restoreOutfit', restoreAppearance)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then restoreAppearance() end
end)
