local postals = {}
local postalBlips = {}
local mapVisible = true

local function nearestPostal(coords)
    local closest, closestDistance
    for _, postal in ipairs(postals) do
        local distance = #(coords - vec3(postal.x, postal.y, coords.z))
        if not closestDistance or distance < closestDistance then
            closest = postal
            closestDistance = distance
        end
    end
    return closest, closestDistance
end

local function setBlipsVisible(visible)
    mapVisible = visible
    for _, blip in ipairs(postalBlips) do
        SetBlipAlpha(blip, visible and 180 or 0)
    end
end

local function createPostalBlips()
    local rawPostals = LoadResourceFile('tuff-hud', 'client/postals.json')
    if not rawPostals then
        print('[drp_postals] Could not read tuff-hud/client/postals.json')
        return
    end

    postals = json.decode(rawPostals) or {}
    for _, postal in ipairs(postals) do
        local blip = AddBlipForCoord(postal.x, postal.y, 0.0)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 3)
        SetBlipScale(blip, 0.28)
        SetBlipAlpha(blip, 180)
        SetBlipDisplay(blip, 4) -- pause map only; do not clutter the minimap
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(('PLZ %s'):format(postal.code))
        EndTextCommandSetBlipName(blip)
        postalBlips[#postalBlips + 1] = blip
    end

    print(('[drp_postals] Loaded %s postal markers from tuff-hud.'):format(#postals))
end

CreateThread(function()
    Wait(1000)
    createPostalBlips()
end)

RegisterCommand('postals', function()
    setBlipsVisible(not mapVisible)
    local state = mapVisible and 'eingeblendet' or 'ausgeblendet'
    TriggerEvent('chat:addMessage', { args = { 'Postleitzahlen', ('Karten-Postleitzahlen wurden %s.'):format(state) } })
end, false)

RegisterCommand('postal', function()
    local postal, distance = nearestPostal(GetEntityCoords(PlayerPedId()))
    if not postal then return end
    TriggerEvent('chat:addMessage', {
        args = { 'Postleitzahl', ('Nächste PLZ: %s (%.0f m)'):format(postal.code, distance) }
    })
end, false)

exports('GetNearestPostal', function()
    local postal, distance = nearestPostal(GetEntityCoords(PlayerPedId()))
    return postal and postal.code or nil, distance
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, blip in ipairs(postalBlips) do
        RemoveBlip(blip)
    end
end)
