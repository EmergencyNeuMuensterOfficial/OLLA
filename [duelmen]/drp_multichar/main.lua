local isOpen = false
local menuReady = false
local isRespawning = false

-- The database keeps a separate position for every character. This is sent
-- regularly, before switching characters, and while the client is still able
-- to communicate during a disconnect.
local function saveCurrentPosition()
    if isRespawning then return end

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end

    local coords = GetEntityCoords(ped)
    TriggerServerEvent('german-multichar:server:savePosition', {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = GetEntityHeading(ped)
    })
end

RegisterNetEvent('german-multichar:client:savePosition', saveCurrentPosition)

local function showNui()
    SendNUIMessage({
        action = 'open',
        data = {
            text = Config.Text,
            maxCharacters = Config.MaxCharacters,
            genders = Config.Genders,
            jobs = Config.Jobs
        }
    })
end

local function openCharacters()
    if isOpen then return end
    saveCurrentPosition()
    isOpen = true
    menuReady = false
    -- Creating NUI focus first makes sure the CEF page is initialized before its first message.
    SetNuiFocusKeepInput(false)
    SetNuiFocus(true, true)
    showNui()

    SetTimeout(750, function()
        if isOpen and not menuReady then showNui() end
    end)

end

RegisterCommand(Config.Command, openCharacters, false)

RegisterNetEvent('german-multichar:client:openCharacters', openCharacters)

RegisterNetEvent("german-multichar:client:closed", function()
    isOpen = false
    menuReady = false
end)

RegisterNUICallback('ready', function(_, callback)
    if isOpen then
        menuReady = true
        if Config.Spawn.freezeUntilLoaded then FreezeEntityPosition(PlayerPedId(), true) end
        SetNuiFocusKeepInput(false)
        SetNuiFocus(true, true)
    end
    callback({ ok = true })
end)

CreateThread(function()
    while true do
        if isOpen then
            SetNuiFocusKeepInput(false)
            SetNuiFocus(true, true)
            -- Prevent GTA movement, shooting, camera controls, and look input
            -- while the character browser owns the mouse and keyboard.
            DisableAllControlActions(0)
            Wait(0)
        else
            Wait(250)
        end
    end
end)

CreateThread(function()
    while true do
        saveCurrentPosition()
        Wait(5000)
    end
end)

-- spawnmanager otherwise respawns a dead player at one of its own default
-- spawn points, which also replaces the active character ped.
CreateThread(function()
    Wait(2500)
    if GetResourceState('spawnmanager') == 'started' then
        exports.spawnmanager:setAutoSpawn(false)
    end
end)

local function respawnAtHospital()
    if isRespawning or isOpen then return end
    isRespawning = true

    Wait(Config.DeathRespawnDelay)
    local ped = PlayerPedId()
    if not IsEntityDead(ped) then
        isRespawning = false
        return
    end

    local hospital = Config.HospitalSpawn
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(0) end

    -- Do not change the model here. The existing ped is the selected identity.
    NetworkResurrectLocalPlayer(hospital.x, hospital.y, hospital.z, hospital.w, true, true, false)
    ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    RequestCollisionAtCoord(hospital.x, hospital.y, hospital.z)
    SetEntityCoordsNoOffset(ped, hospital.x, hospital.y, hospital.z, false, false, false)
    SetEntityHeading(ped, hospital.w)

    local collisionTimeout = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < collisionTimeout do
        RequestCollisionAtCoord(hospital.x, hospital.y, hospital.z)
        Wait(0)
    end

    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    ClearPedTasksImmediately(ped)
    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    FreezeEntityPosition(ped, false)

    DoScreenFadeIn(700)
    TriggerEvent('chat:addMessage', { args = { 'Krankenhaus', 'Du wurdest im Krankenhaus von Los Santos behandelt.' } })
    isRespawning = false
end

CreateThread(function()
    while true do
        if not isOpen and not isRespawning and IsEntityDead(PlayerPedId()) then
            respawnAtHospital()
        end
        Wait(500)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    saveCurrentPosition()
    SetNuiFocus(false, false)
    FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNetEvent("german-multichar:client:spawn", function(character)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'close' })
    isOpen = false
    menuReady = false
    local gender = GermanCharacters.GetGender(character.gender)
    if not gender then return end
    local model = joaat(gender.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    -- Existing characters return to their own last saved position. A newly
    -- created character has the configured airport location as its default.
    local spawn = character.position
    if type(spawn) ~= 'table'
        or type(tonumber(spawn.x)) ~= 'number'
        or type(tonumber(spawn.y)) ~= 'number'
        or type(tonumber(spawn.z)) ~= 'number' then
        spawn = Config.Spawn.coords
    end
    spawn = {
        x = tonumber(spawn.x),
        y = tonumber(spawn.y),
        z = tonumber(spawn.z),
        w = tonumber(spawn.w) or tonumber(Config.Spawn.coords.w) or 0.0
    }
    local ped = PlayerPedId()
    NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.w, true, true, false)
    SetPedDefaultComponentVariation(ped)
    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetEntityVisible(ped, true, false)
    ResetEntityAlpha(ped)
    SetEntityCollision(ped, true, true)
    RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false)
    SetEntityHeading(ped, spawn.w)
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    TriggerEvent("chat:addMessage", {
        args = { "Charakter", ("Willkommen %s %s! Beruf: %s"):format(character.first_name, character.last_name, character.job_name or 'unemployed') }
    })
end)
