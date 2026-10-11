local Inventory = require 'modules.inventory.server'

server.accounts = { money = 0 }

AddEventHandler('drp_characters:server:characterLoaded', function(source, character)
    character.source = source
    character.identifier = character.id
    character.groups = character.groups or { unemployed = 0 }
    character.name = character.name or ('%s %s'):format(character.first_name, character.last_name)

    server.setPlayerInventory(character)
    Inventory.SetItem(source, 'money', tonumber(character.cash) or 0)
end)

AddEventHandler('drp_characters:server:characterUnloaded', function(source)
    server.playerDropped(source)
end)

function server.setPlayerData(player)
    return {
        source = player.source,
        identifier = player.id,
        name = player.name,
        groups = player.groups or { unemployed = 0 },
        sex = player.gender,
        dateofbirth = player.date_of_birth,
    }
end

function server.syncInventory(inv)
    local accounts = Inventory.GetAccountItemCounts(inv)
    if accounts then
        TriggerEvent('drp_characters:server:syncCash', tonumber(inv.owner), accounts.money or 0)
    end
end
