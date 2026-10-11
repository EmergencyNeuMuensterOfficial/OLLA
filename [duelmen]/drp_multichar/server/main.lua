local function reply(source, requestId, payload)
    TriggerClientEvent('german-multichar:client:response', source, requestId, payload)
end

local function validText(value)
    return type(value) == 'string' and #value >= 2 and #value <= 24
        and value:match('^[%aÄÖÜäöüß%s%-]+$') ~= nil
end

local function validDate(value)
    if type(value) ~= 'string' or not value:match('^%d%d%d%d%-%d%d%-%d%d$') then return false end
    local year, month, day = value:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    return year and month and day and year >= 1900 and year <= 2010 and month >= 1 and month <= 12 and day >= 1 and day <= 31
end

local function decodePosition(position)
    if type(position) == 'table' then return position end
    if type(position) ~= 'string' or position == '' then return nil end

    local ok, decoded = pcall(json.decode, position)
    return ok and type(decoded) == 'table' and decoded or nil
end

local function normalisePosition(position)
    if type(position) ~= 'table' then return nil end

    local x, y, z, w = tonumber(position.x), tonumber(position.y), tonumber(position.z), tonumber(position.w)
    -- Reject malformed values and implausible coordinates received from a
    -- client. This protects the saved position from accidental bad data.
    if not x or not y or not z or math.abs(x) > 10000 or math.abs(y) > 10000 or z < -200 or z > 2000 then
        return nil
    end

    return { x = x, y = y, z = z, w = w or 0.0 }
end

local function activateCharacter(source, character)
    -- ox_inventory indexes an active player inventory by server source. A
    -- character switch keeps the same source, so the previous character has
    -- to be unloaded before a new one is assigned. Without this teardown
    -- ox_inventory correctly refuses the second load and the new character
    -- sees the wrong or an empty inventory.
    local previousCharacter = exports.drp_core:GetActiveCharacter(source)
    if previousCharacter then
        TriggerEvent('drp_characters:server:characterUnloaded', source, previousCharacter)
        exports.drp_core:ClearActiveCharacter(source)
    end

    character.job_name = character.job_name or 'unemployed'
    character.job_grade = tonumber(character.job_grade) or 0
    character.job = character.job_name
    character.groups = { [character.job_name] = character.job_grade }
    character.name = ('%s %s'):format(character.first_name, character.last_name)
    character.identifier = character.id
    character.metadata = character.metadata and json.decode(character.metadata) or {}
    character.position = decodePosition(character.position)

    if not exports.drp_core:SetActiveCharacter(source, character) then
        return false, 'Core-Spielerdaten sind noch nicht geladen.'
    end

    -- Keep the existing ox_inventory DRP bridge working without changes.
    TriggerEvent('drp_characters:server:characterLoaded', source, character)
    TriggerClientEvent('german-multichar:client:spawn', source, character)
    return true
end

RegisterNetEvent('german-multichar:server:savePosition', function(position)
    local source = source
    local character = exports.drp_core:GetActiveCharacter(source)
    local savedPosition = normalisePosition(position)
    if not character or not savedPosition then return end

    local updated = MySQL.update.await('UPDATE drp_characters SET position = ? WHERE id = ?', {
        json.encode(savedPosition), character.id
    })

    if updated and updated > 0 then
        character.position = savedPosition
    end
end)

RegisterNetEvent('german-multichar:server:list', function(requestId)
    local source = source
    local license = GermanCharacters.GetLicense(source)
    if not license then return reply(source, requestId, { ok = false, error = 'Kein gültiger Lizenz-Identifier gefunden.' }) end
    reply(source, requestId, { ok = true, characters = GermanCharacters.LoadCharacters(license) })
end)

RegisterNetEvent('german-multichar:server:create', function(requestId, data)
    local source = source
    local license = GermanCharacters.GetLicense(source)
    if not license or type(data) ~= 'table' then return reply(source, requestId, { ok = false, error = 'Ungültige Anfrage.' }) end

    local slot = tonumber(data.slot)
    local gender = GermanCharacters.GetGender(data.gender)
    -- New citizens always begin unemployed. Jobs are assigned by future job systems.
    local job = GermanCharacters.GetJob('unemployed')
    if not slot or slot < 1 or slot > Config.MaxCharacters or not validText(data.firstName)
        or not validText(data.lastName) or not validDate(data.birthDate) or not gender or not job then
        return reply(source, requestId, { ok = false, error = 'Bitte prüfe deine Eingaben.' })
    end
    if GermanCharacters.GetCharacter(license, slot) then
        return reply(source, requestId, { ok = false, error = 'Dieser Charakter-Slot ist bereits belegt.' })
    end

    local success, errorMessage = GermanCharacters.CreateCharacter(license, {
        slot = slot,
        firstName = data.firstName:sub(1, 1):upper() .. data.firstName:sub(2),
        lastName = data.lastName:sub(1, 1):upper() .. data.lastName:sub(2),
        birthDate = data.birthDate, gender = gender.value, job = job.value
    })
    reply(source, requestId, { ok = success, error = errorMessage, characters = success and GermanCharacters.LoadCharacters(license) or nil })
end)

RegisterNetEvent('german-multichar:server:select', function(requestId, slot)
    local source = source
    local license = GermanCharacters.GetLicense(source)
    local character = license and GermanCharacters.GetCharacter(license, tonumber(slot))
    if not character then return reply(source, requestId, { ok = false, error = 'Charakter nicht gefunden.' }) end
    local success, errorMessage = activateCharacter(source, character)
    reply(source, requestId, { ok = success, error = errorMessage })
end)

AddEventHandler('drp_core:server:playerLoaded', function(source)
    SetTimeout(750, function()
        TriggerClientEvent('german-multichar:client:openCharacters', source)
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CreateThread(function()
        Wait(1000)
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            if exports.drp_core:GetPlayer(source) and not exports.drp_core:GetActiveCharacter(source) then
                TriggerClientEvent('german-multichar:client:openCharacters', source)
            end
        end
    end)
end)

AddEventHandler('playerDropped', function()
    local character = exports.drp_core:GetActiveCharacter(source)
    if character then TriggerEvent('drp_characters:server:characterUnloaded', source, character) end
end)
