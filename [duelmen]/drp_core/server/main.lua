AddEventHandler('playerJoining', function()
    local source = source
    SetTimeout(0, function()
        DRP.LoadPlayer(source)
    end)
end)

AddEventHandler('playerDropped', function()
    DRP.UnloadPlayer(source)
end)

CreateThread(function()
    Wait(1000)
    for _, playerId in ipairs(GetPlayers()) do
        DRP.LoadPlayer(tonumber(playerId))
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for source in pairs(DRP.Players) do
        DRP.UnloadPlayer(source)
    end
end)

DRP.RegisterCallback('drp_core:getPlayerData', function(source, reply)
    reply(DRP.GetPlayer(source))
end)

exports('GetPlayer', DRP.GetPlayer)
exports('GetActiveCharacter', DRP.GetActiveCharacter)
exports('SetActiveCharacter', DRP.SetActiveCharacter)
exports('ClearActiveCharacter', DRP.ClearActiveCharacter)
exports('AddMoney', DRP.AddMoney)
exports('RemoveMoney', DRP.RemoveMoney)

print('[drp_core] Dülmen Roleplay core loaded.')
