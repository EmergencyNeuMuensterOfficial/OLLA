local function isCreator(source)
    if IsPlayerAceAllowed(source, 'drp.jobs.manage') then return true end
    if GetResourceState('drp_aduty') == 'started' then
        return exports.drp_aduty:GetStaffGroup(source) == 'headteam'
    end
    return false
end

local function getCharacter(source)
    return exports.drp_core:GetActiveCharacter(source)
end

local function isBoss(source, jobName)
    local character = getCharacter(source)
    if not character or character.job_name ~= jobName then return false end
    -- Head-Team is allowed to administrate every job. Regular employees still
    -- require the explicit boss flag of their own job grade.
    if isCreator(source) then return true end
    -- `TINYINT(1)` can be returned by database drivers as a string, number or
    -- boolean. Cast it in SQL so this permission check is deterministic.
    local bossFlag = MySQL.scalar.await('SELECT CAST(is_boss AS UNSIGNED) FROM drp_job_grades WHERE job_name = ? AND grade = ?', {
        jobName, tonumber(character.job_grade) or 0
    })
    return tonumber(bossFlag) == 1
end

local function validJobName(value)
    return type(value) == 'string' and value:match('^[a-z0-9_]+$') and #value >= 3 and #value <= 32
end

local function refreshLocations()
    TriggerClientEvent('drp_jobs:client:refreshLocations', -1)
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS drp_jobs (
        name VARCHAR(32) NOT NULL, label VARCHAR(64) NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (name)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS drp_job_grades (
        job_name VARCHAR(32) NOT NULL, grade INT NOT NULL, label VARCHAR(64) NOT NULL,
        salary INT NOT NULL DEFAULT 0, is_boss TINYINT(1) NOT NULL DEFAULT 0,
        PRIMARY KEY (job_name, grade)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS drp_job_locations (
        id INT UNSIGNED NOT NULL AUTO_INCREMENT, job_name VARCHAR(32) NOT NULL,
        location_type ENUM('boss','wardrobe') NOT NULL, x DOUBLE NOT NULL, y DOUBLE NOT NULL,
        z DOUBLE NOT NULL, heading FLOAT NOT NULL DEFAULT 0,
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS drp_job_outfits (
        job_name VARCHAR(32) NOT NULL, grade INT NOT NULL, gender VARCHAR(12) NOT NULL,
        components LONGTEXT NOT NULL, props LONGTEXT NOT NULL,
        PRIMARY KEY (job_name, grade, gender)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    print('[drp_jobs] Database schema is ready.')
end)

lib.callback.register('drp_jobs:server:getLocations', function()
    return MySQL.query.await('SELECT * FROM drp_job_locations') or {}
end)

lib.callback.register('drp_jobs:server:getJobs', function(source)
    if not isCreator(source) then return nil end
    local jobs = MySQL.query.await('SELECT * FROM drp_jobs ORDER BY label') or {}
    for _, job in ipairs(jobs) do
        job.grades = MySQL.query.await('SELECT * FROM drp_job_grades WHERE job_name = ? ORDER BY grade', { job.name }) or {}
        job.locations = MySQL.query.await('SELECT * FROM drp_job_locations WHERE job_name = ? ORDER BY id', { job.name }) or {}
    end
    return jobs
end)

lib.callback.register('drp_jobs:server:createJob', function(source, name, label)
    if not isCreator(source) or not validJobName(name) or type(label) ~= 'string' or #label < 2 or #label > 64 then return false, 'Ungültige Eingabe.' end
    local ok = pcall(function()
        MySQL.insert.await('INSERT INTO drp_jobs (name, label) VALUES (?, ?)', { name, label })
        MySQL.insert.await('INSERT INTO drp_job_grades (job_name, grade, label, salary, is_boss) VALUES (?, 0, ?, 0, 0)', { name, 'Mitarbeiter' })
    end)
    return ok, ok and 'Job wurde erstellt.' or 'Dieser Jobname ist bereits vergeben.'
end)

lib.callback.register('drp_jobs:server:addGrade', function(source, jobName, grade, label, salary, isBoss)
    if not isCreator(source) or not validJobName(jobName) then return false, 'Keine Berechtigung oder ungültiger Job.' end
    grade, salary = math.floor(tonumber(grade) or -1), math.max(0, math.floor(tonumber(salary) or 0))
    if grade < 0 or grade > 99 or type(label) ~= 'string' or #label < 2 or #label > 64 then return false, 'Ungültige Rangdaten.' end
    local ok = pcall(function()
        MySQL.insert.await('INSERT INTO drp_job_grades (job_name, grade, label, salary, is_boss) VALUES (?, ?, ?, ?, ?)', { jobName, grade, label, salary, isBoss and 1 or 0 })
    end)
    return ok, ok and 'Rang wurde hinzugefügt.' or 'Diese Rangnummer ist bereits vergeben.'
end)

lib.callback.register('drp_jobs:server:updateGrade', function(source, jobName, grade, label, salary, isBoss)
    if not isCreator(source) or not validJobName(jobName) then return false, 'Keine Berechtigung.' end
    grade, salary = math.floor(tonumber(grade) or -1), math.max(0, math.floor(tonumber(salary) or 0))
    if grade < 0 or type(label) ~= 'string' or #label < 2 or #label > 64 then return false, 'Ungültige Rangdaten.' end
    local changed = MySQL.update.await('UPDATE drp_job_grades SET label = ?, salary = ?, is_boss = ? WHERE job_name = ? AND grade = ?', {
        label, salary, isBoss and 1 or 0, jobName, grade
    })
    return changed > 0, changed > 0 and 'Rang wurde gespeichert.' or 'Rang nicht gefunden.'
end)

lib.callback.register('drp_jobs:server:deleteGrade', function(source, jobName, grade)
    if not isCreator(source) or not validJobName(jobName) then return false, 'Keine Berechtigung.' end
    grade = math.floor(tonumber(grade) or -1)
    if grade <= 0 then return false, 'Der Grundrang 0 kann nicht gelöscht werden.' end
    MySQL.update.await('UPDATE drp_characters SET job_grade = 0 WHERE job_name = ? AND job_grade = ?', { jobName, grade })
    local changed = MySQL.update.await('DELETE FROM drp_job_grades WHERE job_name = ? AND grade = ?', { jobName, grade })
    return changed > 0, changed > 0 and 'Rang wurde gelöscht. Betroffene Mitarbeiter sind jetzt Rang 0.' or 'Rang nicht gefunden.'
end)

RegisterNetEvent('drp_jobs:server:addLocation', function(jobName, locationType, coords)
    local source = source
    if not isCreator(source) or not validJobName(jobName) or (locationType ~= 'boss' and locationType ~= 'wardrobe') or type(coords) ~= 'table' then return end
    local job = MySQL.single.await('SELECT name FROM drp_jobs WHERE name = ?', { jobName })
    if not job then return end
    MySQL.insert.await('INSERT INTO drp_job_locations (job_name, location_type, x, y, z, heading) VALUES (?, ?, ?, ?, ?, ?)', {
        jobName, locationType, tonumber(coords.x), tonumber(coords.y), tonumber(coords.z), tonumber(coords.w) or 0,
    })
    refreshLocations()
    TriggerClientEvent('ox_lib:notify', source, { title = 'Job Creator', description = 'Punkt wurde platziert.', type = 'success' })
end)

RegisterNetEvent('drp_jobs:server:deleteLocation', function(id)
    local source = source
    if not isCreator(source) then return end
    MySQL.update.await('DELETE FROM drp_job_locations WHERE id = ?', { tonumber(id) })
    refreshLocations()
end)

lib.callback.register('drp_jobs:server:getBossData', function(source, jobName)
    if not isBoss(source, jobName) then
        local character = getCharacter(source)
        print(('[drp_jobs] Boss menu denied for %s: job=%s grade=%s requested=%s'):format(
            GetPlayerName(source) or source,
            character and character.job_name or 'none',
            character and tostring(character.job_grade) or 'none',
            tostring(jobName)
        ))
        return nil
    end
    local grades = MySQL.query.await('SELECT * FROM drp_job_grades WHERE job_name = ? ORDER BY grade', { jobName }) or {}
    local employees = MySQL.query.await([[SELECT id, first_name, last_name, job_grade FROM drp_characters
        WHERE job_name = ? ORDER BY job_grade DESC, last_name, first_name]], { jobName }) or {}
    local online = {}
    for _, playerId in ipairs(GetPlayers()) do
        local target = tonumber(playerId)
        local character = getCharacter(target)
        if character and target ~= source then
            online[#online + 1] = { source = target, name = character.name or GetPlayerName(target) }
        end
    end
    return { grades = grades, employees = employees, online = online }
end)

local function setEmployeeGrade(characterId, jobName, grade)
    grade = math.floor(tonumber(grade) or -1)
    local validGrade = MySQL.single.await('SELECT grade FROM drp_job_grades WHERE job_name = ? AND grade = ?', { jobName, grade })
    if not validGrade then return false end
    MySQL.update.await('UPDATE drp_characters SET job_name = ?, job_grade = ? WHERE id = ?', { jobName, grade, tonumber(characterId) })
    for _, playerId in ipairs(GetPlayers()) do
        local target = tonumber(playerId)
        local character = getCharacter(target)
        if character and tonumber(character.id) == tonumber(characterId) then
            character.job_name, character.job_grade, character.job = jobName, grade, jobName
            character.groups = { [jobName] = grade }
            TriggerClientEvent('drp_core:client:characterSelected', target, character)
            TriggerClientEvent('drp_jobs:client:jobUpdated', target)
            break
        end
    end
    return true
end

RegisterNetEvent('drp_jobs:server:setEmployeeGrade', function(characterId, jobName, grade)
    local source = source
    if not isBoss(source, jobName) then return end
    if not setEmployeeGrade(characterId, jobName, grade) then return end
    TriggerClientEvent('drp_jobs:client:openBossMenu', source, jobName)
end)

lib.callback.register('drp_jobs:server:creatorAssign', function(source, target, jobName, grade)
    target, grade = tonumber(target), math.floor(tonumber(grade) or -1)
    if not isCreator(source) or not target or not getCharacter(target) or not validJobName(jobName) then
        return false, 'Ungültige Zuweisung.'
    end
    if not setEmployeeGrade(getCharacter(target).id, jobName, grade) then
        return false, 'Job oder Rang existiert nicht.'
    end
    return true, 'Job wurde zugewiesen.'
end)

RegisterNetEvent('drp_jobs:server:hirePlayer', function(target, jobName)
    local source = source
    target = tonumber(target)
    if not target or not isBoss(source, jobName) or not getCharacter(target) then return end
    if setEmployeeGrade(getCharacter(target).id, jobName, 0) then
        TriggerClientEvent('drp_jobs:client:openBossMenu', source, jobName)
    end
end)

RegisterNetEvent('drp_jobs:server:fireEmployee', function(characterId, jobName)
    local source = source
    if not isBoss(source, jobName) then return end
    MySQL.update.await('UPDATE drp_characters SET job_name = ?, job_grade = 0 WHERE id = ?', { 'unemployed', tonumber(characterId) })
    for _, playerId in ipairs(GetPlayers()) do
        local target = tonumber(playerId)
        local character = getCharacter(target)
        if character and tonumber(character.id) == tonumber(characterId) then
            character.job_name, character.job_grade, character.job = 'unemployed', 0, 'unemployed'
            character.groups = { unemployed = 0 }
            TriggerClientEvent('drp_core:client:characterSelected', target, character)
            TriggerClientEvent('drp_jobs:client:jobUpdated', target)
            break
        end
    end
    TriggerClientEvent('drp_jobs:client:openBossMenu', source, jobName)
end)

lib.callback.register('drp_jobs:server:getWardrobe', function(source, jobName)
    local character = getCharacter(source)
    if not character or character.job_name ~= jobName then return nil end
    return MySQL.single.await('SELECT components, props FROM drp_job_outfits WHERE job_name = ? AND grade = ? AND gender = ?', {
        jobName, character.job_grade, character.gender or 'male'
    })
end)

RegisterNetEvent('drp_jobs:server:saveOutfit', function(jobName, outfit)
    local source = source
    local character = getCharacter(source)
    if not character or not isBoss(source, jobName) or type(outfit) ~= 'table' then return end
    MySQL.prepare.await([[INSERT INTO drp_job_outfits (job_name, grade, gender, components, props) VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE components = VALUES(components), props = VALUES(props)]], {
        jobName, character.job_grade, character.gender or 'male', json.encode(outfit.components), json.encode(outfit.props)
    })
    TriggerClientEvent('ox_lib:notify', source, { title = 'Garderobe', description = 'Uniform für deinen aktuellen Rang gespeichert.', type = 'success' })
end)

CreateThread(function()
    while true do
        Wait(DRPJobs.PaydayMinutes * 60000)
        for _, playerId in ipairs(GetPlayers()) do
            local source = tonumber(playerId)
            local character = getCharacter(source)
            if character and character.job_name ~= 'unemployed' then
                local grade = MySQL.single.await('SELECT salary FROM drp_job_grades WHERE job_name = ? AND grade = ?', { character.job_name, character.job_grade })
                local salary = grade and math.max(0, tonumber(grade.salary) or 0) or 0
                if salary > 0 then
                    MySQL.update.await('UPDATE drp_characters SET bank = bank + ? WHERE id = ?', { salary, character.id })
                    character.bank = (tonumber(character.bank) or 0) + salary
                    TriggerClientEvent('drp_core:client:moneyUpdated', source, 'bank', character.bank, 'payday')
                    TriggerClientEvent('ox_lib:notify', source, { title = 'Lohnzahlung', description = ('Du hast $%s erhalten.'):format(salary), type = 'success' })
                end
            end
        end
    end
end)
