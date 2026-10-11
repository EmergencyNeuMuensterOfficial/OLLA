local function getCorePlayer(source)
    return exports.drp_core:GetPlayer(source)
end

local function trim(value)
    return type(value) == 'string' and value:match('^%s*(.-)%s*$') or ''
end

local function validName(value)
    return #value > 0 and #value <= 24
end

local function getCharacters(source)
    local player = getCorePlayer(source)
    if not player then return {} end

    return MySQL.query.await([[SELECT id, first_name, last_name, date_of_birth, gender, cash, bank
        FROM drp_characters WHERE license = ? ORDER BY id ASC]], { player.license }) or {}
end

local function getCharacter(source, characterId)
    local player = getCorePlayer(source)
    if not player then return nil end

    return MySQL.single.await([[SELECT id, license, first_name, last_name, date_of_birth, gender, cash, bank,
        job_name, job_grade, position, metadata FROM drp_characters WHERE id = ? AND license = ?]], {
        characterId, player.license
    })
end

local function selectCharacter(source, characterId)
    local character = getCharacter(source, characterId)
    if not character then return false, 'Character not found.' end

    character.groups = { [character.job_name or 'unemployed'] = tonumber(character.job_grade) or 0 }
    character.name = ('%s %s'):format(character.first_name, character.last_name)
    character.identifier = character.id
    character.metadata = character.metadata and json.decode(character.metadata) or {}

    if not exports.drp_core:SetActiveCharacter(source, character) then
        return false, 'Core player data is not loaded yet.'
    end

    TriggerEvent('drp_characters:server:characterLoaded', source, character)
    TriggerClientEvent('drp_characters:client:characterSelected', source, character)
    return true
end

lib.callback.register('drp_characters:getCharacters', function(source)
    return getCharacters(source)
end)

lib.callback.register('drp_characters:createCharacter', function(source, data)
    if type(data) ~= 'table' then return false, 'Invalid character data.' end

    local firstName = trim(data.firstName)
    local lastName = trim(data.lastName)
    local birthDate = trim(data.birthDate)
    local gender = data.gender == 'female' and 'female' or 'male'
    local player = getCorePlayer(source)

    if not player then return false, 'Core player data is not ready.' end
    if not validName(firstName) or not validName(lastName) then
        return false, 'First and last names must be 1–24 characters.'
    end
    if not birthDate:match('^%d%d%d%d%-%d%d%-%d%d$') then
        return false, 'Use the date format YYYY-MM-DD.'
    end
    if #getCharacters(source) >= DRPCharacters.MaxCharacters then
        return false, ('You can create a maximum of %d characters.'):format(DRPCharacters.MaxCharacters)
    end

    local id = MySQL.insert.await([[INSERT INTO drp_characters
        (license, first_name, last_name, date_of_birth, gender, cash, bank, job_name, job_grade, position, metadata)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'unemployed', 0, ?, '{}')]], {
        player.license, firstName, lastName, birthDate, gender,
        DRPCharacters.StartingCash, DRPCharacters.StartingBank,
        json.encode({ x = DRPCharacters.Spawn.x, y = DRPCharacters.Spawn.y, z = DRPCharacters.Spawn.z, w = DRPCharacters.Spawn.w })
    })

    return selectCharacter(source, id)
end)

lib.callback.register('drp_characters:selectCharacter', function(source, characterId)
    return selectCharacter(source, tonumber(characterId))
end)

lib.callback.register('drp_characters:deleteCharacter', function(source, characterId)
    local player = getCorePlayer(source)
    if not player then return false, 'Core player data is not ready.' end

    local changed = MySQL.update.await('DELETE FROM drp_characters WHERE id = ? AND license = ?', {
        tonumber(characterId), player.license
    })
    if not changed or changed < 1 then return false, 'Character not found.' end
    return true
end)

AddEventHandler('drp_core:server:playerLoaded', function(source)
    SetTimeout(750, function()
        TriggerClientEvent('drp_characters:client:openMenu', source)
    end)
end)

CreateThread(function()
    Wait(1000)
    for _, playerId in ipairs(GetPlayers()) do
        local source = tonumber(playerId)
        if exports.drp_core:GetPlayer(source) and not exports.drp_core:GetActiveCharacter(source) then
            TriggerClientEvent('drp_characters:client:openMenu', source)
        end
    end
end)

AddEventHandler('drp_characters:server:syncCash', function(characterId, cash)
    MySQL.update.await('UPDATE drp_characters SET cash = ? WHERE id = ?', { math.floor(tonumber(cash) or 0), characterId })
end)

AddEventHandler('playerDropped', function()
    local source = source
    local character = exports.drp_core:GetActiveCharacter(source)
    if character then TriggerEvent('drp_characters:server:characterUnloaded', source, character) end
end)
