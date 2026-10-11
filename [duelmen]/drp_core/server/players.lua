DRP = DRP or {}
DRP.Players = {}

local function findLicense(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:sub(1, 8) == 'license:' then
            return identifier
        end
    end
end

function DRP.GetPlayer(source)
    return DRP.Players[source]
end

function DRP.GetActiveCharacter(source)
    local player = DRP.GetPlayer(source)
    return player and player.character or nil
end

function DRP.SetActiveCharacter(source, character)
    local player = DRP.GetPlayer(source)
    if not player then return false end

    player.character = character
    TriggerClientEvent('drp_core:client:characterSelected', source, character)
    TriggerEvent('drp_core:server:characterSelected', source, character)
    return true
end

function DRP.ClearActiveCharacter(source)
    local player = DRP.GetPlayer(source)
    if not player or not player.character then return end

    local character = player.character
    player.character = nil
    TriggerEvent('drp_core:server:characterUnselected', source, character)
end

function DRP.LoadPlayer(source)
    local license = findLicense(source)
    if not license then
        DropPlayer(source, 'Dülmen Roleplay: no Rockstar license identifier was found.')
        return
    end

    local record = DRP.FetchOrCreatePlayer(license, GetPlayerName(source) or 'Unknown')
    if not record then
        DropPlayer(source, 'Dülmen Roleplay: your player data could not be loaded.')
        return
    end

    local player = {
        source = source,
        id = record.id,
        license = record.license,
        name = record.name,
        cash = record.cash,
        bank = record.bank,
        metadata = record.metadata and json.decode(record.metadata) or {},
    }

    DRP.Players[source] = player
    TriggerClientEvent('drp_core:client:playerLoaded', source, player)
    TriggerEvent('drp_core:server:playerLoaded', source, player)
    return player
end

function DRP.UnloadPlayer(source)
    local player = DRP.Players[source]
    if not player then return end
    DRP.ClearActiveCharacter(source)
    DRP.SavePlayer(player)
    DRP.Players[source] = nil
    TriggerEvent('drp_core:server:playerUnloaded', source, player)
end

function DRP.AddMoney(source, account, amount, reason)
    local player = DRP.GetPlayer(source)
    amount = math.floor(tonumber(amount) or 0)
    if not player or amount <= 0 or (account ~= 'cash' and account ~= 'bank') then return false end

    player[account] = player[account] + amount
    DRP.SavePlayer(player)
    TriggerClientEvent('drp_core:client:moneyUpdated', source, account, player[account], reason or 'unknown')
    return true
end

function DRP.RemoveMoney(source, account, amount, reason)
    local player = DRP.GetPlayer(source)
    amount = math.floor(tonumber(amount) or 0)
    if not player or amount <= 0 or (account ~= 'cash' and account ~= 'bank') or player[account] < amount then return false end

    player[account] = player[account] - amount
    DRP.SavePlayer(player)
    TriggerClientEvent('drp_core:client:moneyUpdated', source, account, player[account], reason or 'unknown')
    return true
end
