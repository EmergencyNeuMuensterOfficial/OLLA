local function log(message)
    print(('[drp_multichar] %s'):format(message))
end

CreateThread(function()
    local added, addError = pcall(function()
        MySQL.query.await('ALTER TABLE drp_characters ADD COLUMN slot TINYINT UNSIGNED NULL AFTER license')
    end)
    if not added and not tostring(addError):find('Duplicate column', 1, true) then
        log(('Could not add the character slot column: %s'):format(tostring(addError)))
    end

    local indexed, indexError = pcall(function()
        MySQL.query.await('CREATE UNIQUE INDEX uq_drp_characters_license_slot ON drp_characters (license, slot)')
    end)
    if not indexed and not tostring(indexError):find('Duplicate key name', 1, true) then
        log(('Could not add the character slot index: %s'):format(tostring(indexError)))
    end
end)

local function getLicense(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:sub(1, 8) == 'license:' then return identifier end
    end
end

GermanCharacters.GetLicense = getLicense

function GermanCharacters.LoadCharacters(license)
    return MySQL.query.await([[SELECT id, slot, first_name, last_name, date_of_birth AS birth_date, gender, job_name AS job
        FROM drp_characters WHERE license = ? AND slot IS NOT NULL ORDER BY slot ASC]], { license }) or {}
end

function GermanCharacters.GetCharacter(license, slot)
    return MySQL.single.await([[SELECT id, slot, license, first_name, last_name, date_of_birth, gender, cash, bank,
        job_name, job_grade, position, metadata FROM drp_characters WHERE license = ? AND slot = ?]], { license, slot })
end

function GermanCharacters.CreateCharacter(license, data)
    local success, result = pcall(function()
        return MySQL.insert.await([[INSERT INTO drp_characters
            (license, slot, first_name, last_name, date_of_birth, gender, cash, bank, job_name, job_grade, position, metadata)
            VALUES (?, ?, ?, ?, ?, ?, 500, 2500, ?, 0, ?, '{}')]], {
            license, data.slot, data.firstName, data.lastName, data.birthDate, data.gender, data.job,
            json.encode({ x = Config.Spawn.coords.x, y = Config.Spawn.coords.y, z = Config.Spawn.coords.z, w = Config.Spawn.coords.w })
        })
    end)
    if not success or not result then
        log(('Could not create character: %s'):format(tostring(result)))
        return false, 'Der Slot ist bereits belegt oder die Datenbank ist nicht erreichbar.'
    end
    return true
end

-- ox_inventory stores cash as its `money` account. Keep the selected
-- character's cash column and in-memory data aligned with that account.
AddEventHandler('drp_characters:server:syncCash', function(characterId, cash)
    characterId = tonumber(characterId)
    cash = math.floor(tonumber(cash) or 0)
    if not characterId then return end

    MySQL.update.await('UPDATE drp_characters SET cash = ? WHERE id = ?', { cash, characterId })
    for _, playerId in ipairs(GetPlayers()) do
        local source = tonumber(playerId)
        local character = exports.drp_core:GetActiveCharacter(source)
        if character and tonumber(character.id) == characterId then
            character.cash = cash
            TriggerClientEvent('drp_core:client:moneyUpdated', source, 'cash', cash, 'inventory')
            break
        end
    end
end)
