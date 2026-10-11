DRP = DRP or {}
DRP.PlayerData = nil

local callbacks = {}
local requestId = 0

function DRP.TriggerCallback(name, callback, ...)
    requestId = requestId + 1
    callbacks[requestId] = callback
    TriggerServerEvent('drp_core:server:callback', name, requestId, ...)
end

RegisterNetEvent('drp_core:client:callback', function(id, ...)
    local callback = callbacks[id]
    if not callback then return end
    callbacks[id] = nil
    callback(...)
end)

RegisterNetEvent('drp_core:client:playerLoaded', function(player)
    DRP.PlayerData = player
    print(('[drp_core] Player loaded: %s'):format(player.name))
end)

RegisterNetEvent('drp_core:client:characterSelected', function(character)
    if DRP.PlayerData then DRP.PlayerData.character = character end
end)

RegisterNetEvent('drp_core:client:moneyUpdated', function(account, balance)
    if DRP.PlayerData then
        DRP.PlayerData[account] = balance
        if DRP.PlayerData.character then DRP.PlayerData.character[account] = balance end
    end
end)

exports('GetPlayerData', function()
    return DRP.PlayerData
end)

CreateThread(function()
    Wait(1000)

    exports.ox_target:addBoxZone({
        coords = vec3(-1037.6, -2737.7, 20.2),
        size = vec3(2.2, 2.2, 2.0),
        rotation = 329.0,
        debug = false,
        options = {
            {
                name = 'drp_airport_welcome',
                icon = 'fa-solid fa-plane-arrival',
                label = 'Dülmen Roleplay - Airport information',
                distance = 2.0,
                onSelect = function()
                    BeginTextCommandThefeedPost('STRING')
                    AddTextComponentSubstringPlayerName('Welcome to Dülmen Roleplay. Your character has arrived at Los Santos International Airport.')
                    EndTextCommandThefeedPostTicker(false, false)
                end
            }
        }
    })
end)
