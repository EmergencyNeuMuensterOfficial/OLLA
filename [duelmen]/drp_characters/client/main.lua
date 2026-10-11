local menuOpen = false

local function sendMenu(characters, error)
    SendNUIMessage({ action = 'open', characters = characters or {}, maxCharacters = DRPCharacters.MaxCharacters, error = error })
end

local function openMenu(error)
    local characters = lib.callback.await('drp_characters:getCharacters', false) or {}
    menuOpen = true
    FreezeEntityPosition(PlayerPedId(), true)
    SetNuiFocus(true, true)
    sendMenu(characters, error)
end

local function closeMenu()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    FreezeEntityPosition(PlayerPedId(), false)
end

RegisterNetEvent('drp_characters:client:openMenu', function()
    if not menuOpen then openMenu() end
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    CreateThread(function()
        local ok, message = lib.callback.await('drp_characters:selectCharacter', false, data.id)
        if ok then closeMenu() else openMenu(message or 'Unable to select character.') end
        cb({ ok = ok, error = message })
    end)
end)

RegisterNUICallback('createCharacter', function(data, cb)
    CreateThread(function()
        local ok, message = lib.callback.await('drp_characters:createCharacter', false, data)
        if ok then closeMenu() else openMenu(message or 'Unable to create character.') end
        cb({ ok = ok, error = message })
    end)
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    CreateThread(function()
        local ok, message = lib.callback.await('drp_characters:deleteCharacter', false, data.id)
        if ok then openMenu() else openMenu(message or 'Unable to delete character.') end
        cb({ ok = ok, error = message })
    end)
end)

RegisterNetEvent('drp_characters:client:characterSelected', function(character)
    closeMenu()

    local model = joaat(character.gender == 'female' and 'mp_f_freemode_01' or 'mp_m_freemode_01')
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    ResetEntityAlpha(ped)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(ped)

    local position = character.position and json.decode(character.position) or nil
    if position then
        RequestCollisionAtCoord(position.x + 0.0, position.y + 0.0, position.z + 0.0)
        SetEntityCoordsNoOffset(ped, position.x + 0.0, position.y + 0.0, position.z + 0.0, false, false, false)
        SetEntityHeading(ped, position.w + 0.0)
    end

    lib.notify({ type = 'success', description = ('Welcome, %s %s.'):format(character.first_name, character.last_name) })
end)
