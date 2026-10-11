-- Set Config.framework = "custom" to enable this shared framework template.
if Sky.Config.framework ~= "custom" then return end

Sky.FW = {}

-- Dülmen Roleplay adapter. Each multi-character slot owns separate cash and
-- bank balances in drp_characters.
local function activeCharacter(source)
    source = tonumber(source)
    return source and exports.drp_core:GetActiveCharacter(source) or nil
end

local function characterId(value)
    if type(value) == 'string' then return tonumber(value:match('^drp:(%d+)$')) end
end

local function onlineSource(value)
    if type(value) == 'number' then return activeCharacter(value) and value or nil end
    local wantedId = characterId(value)
    if not wantedId then return nil end
    for _, playerId in ipairs(GetPlayers()) do
        local source = tonumber(playerId)
        local character = activeCharacter(source)
        if character and tonumber(character.id) == wantedId then return source end
    end
end

local function characterRecord(value)
    local source = onlineSource(value)
    if source then return activeCharacter(source), source end
    local id = characterId(value)
    if id then return MySQL.single.await('SELECT * FROM drp_characters WHERE id = ?', { id }) end
end

local function accountName(account)
    return account == 'bank' and 'bank' or 'cash'
end

local function updateBalance(source, account, balance)
    local character = activeCharacter(source)
    if not character then return false end
    balance = math.floor(math.max(0, tonumber(balance) or 0))
    character[account] = balance
    MySQL.update.await(('UPDATE drp_characters SET %s = ? WHERE id = ?'):format(account), { balance, character.id })
    if account == 'cash' then exports.ox_inventory:SetItem(source, 'money', balance) end
    TriggerClientEvent('drp_core:client:moneyUpdated', source, account, balance, 'sky_banking')
    return true
end

-- Client integration:
-- Map your framework's client events to the normalized sky_base events below.
-- TriggerEvent("sky_base:playerLoaded")
-- TriggerEvent("sky_base:updateAccountMoney", account_name, amount)
-- TriggerEvent("sky_base:enteredVehicle", vehicle, plate, seat)
-- TriggerEvent("sky_base:exitedVehicle", vehicle, plate, seat)
-- TriggerEvent("sky_base:inventoryUpdated")
-- TriggerEvent("sky_base:updateJob", job)

if not IsDuplicityVersion() then
    function Sky.FW.GetPlayerState(key, server_id)
        if server_id then
            return Player(server_id).state[key]
        end
        return LocalPlayer.state[key]
    end

    function Sky.FW.GetOwnedVehicleCount()
        return nil, "server_only"
    end

    return
end

-- Server integration:
-- TriggerEvent("sky_base:playerLoaded", source) from the framework's login event.
-- Keep every return shape compatible with SKY_BASE_DOCS_AI.md.

function Sky.FW.IsPlayerOnline(source_or_identifier)
    -- Return false when offline, otherwise true or the matching server id.
    return onlineSource(source_or_identifier) or false
end

function Sky.FW.GetIdentifier(source)
    local character = activeCharacter(source)
    return character and ('drp:%s'):format(character.id) or nil
end

function Sky.FW.GetName(source_or_identifier)
    local character = characterRecord(source_or_identifier)
    return character and (character.name or ('%s %s'):format(character.first_name or '', character.last_name or '')) or ''
end

function Sky.FW.GetFirstname(source_or_identifier)
    local character = characterRecord(source_or_identifier)
    return character and character.first_name or ''
end

function Sky.FW.GetLastname(source_or_identifier)
    local character = characterRecord(source_or_identifier)
    return character and character.last_name or ''
end

function Sky.FW.GetGender(source_or_identifier)
    local character = characterRecord(source_or_identifier)
    return character and character.gender or nil
end

function Sky.FW.GetBirthdate(source_or_identifier)
    local character = characterRecord(source_or_identifier)
    return character and character.date_of_birth or nil
end

function Sky.FW.GetHeight(source)
    -- Optional character height in centimeters; return nil when not stored.
    return nil
end

function Sky.FW.GetPlayerDirectoryQueryConfig()
    -- Return the SQL shape used by the player directory.
    return { query = 'SELECT id, first_name, last_name FROM drp_characters WHERE first_name LIKE ? OR last_name LIKE ? LIMIT 20', identifier = 'id', firstname = 'first_name', lastname = 'last_name' }
end

function Sky.FW.GetAccountMoney(source, account)
    -- Normalize money/cash, bank and black_money/black account names.
    local character = activeCharacter(source)
    return character and math.floor(tonumber(character[accountName(account)]) or 0) or 0
end

function Sky.FW.AddAccountMoney(source, account, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    local name = accountName(account)
    return updateBalance(source, name, Sky.FW.GetAccountMoney(source, name) + amount)
end

function Sky.FW.RemoveAccountMoney(source, account, amount, options)
    -- Return false without removing money when the balance is insufficient. When
    -- options.allowOverdraft is true, only the bank account may become negative.
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end
    local name, current = accountName(account), Sky.FW.GetAccountMoney(source, account)
    if current < amount and not (name == 'bank' and options and options.allowOverdraft) then return false end
    return updateBalance(source, name, current - amount)
end

function Sky.FW.GetJobUsers(job_name)
    -- Return { identifier, job_grade, name? } entries.
    local rows = MySQL.query.await('SELECT id, job_grade, first_name, last_name FROM drp_characters WHERE job_name = ?', { job_name }) or {}
    local users = {}
    for _, row in ipairs(rows) do users[#users + 1] = { identifier = 'drp:' .. row.id, job_grade = tonumber(row.job_grade) or 0, name = (row.first_name or '') .. ' ' .. (row.last_name or '') } end
    return users
end

function Sky.FW.GetJob(source_or_identifier)
    -- Return the job name or an empty string.
    local character = characterRecord(source_or_identifier)
    return character and character.job_name or 'unemployed'
end

function Sky.FW.GetGang(source_or_identifier)
    return nil
end

function Sky.FW.GetGangData(source_or_identifier, action)
    return nil
end

function Sky.FW.GetGangUsers(gang_name)
    -- Return { identifier, job_grade, name? } entries.
    error("Custom framework integration: GetGangUsers is not implemented")
end

function Sky.FW.SetGang(source_or_identifier, gang_name, gang_grade)
    error("Custom framework integration: SetGang is not implemented")
end

function Sky.FW.DoesGangExist(gang_name, grade)
    error("Custom framework integration: DoesGangExist is not implemented")
end

function Sky.FW.GetGangs()
    -- Return { name, label, grades = { { grade, name, label, payment } } } entries.
    error("Custom framework integration: GetGangs is not implemented")
end

function Sky.FW.PrepareEmptyGroupMembership(name, kind, authorize)
    Sky.Debug("error", "[Sky.FW.PrepareEmptyGroupMembership] Group creation vacancy is unsupported on the custom framework: %s", tostring(name))
    return nil, "unsupported_framework"
end

function Sky.FW.ReadGangMemberSnapshot(gang_name, authorize)
    Sky.Debug("error", "[Sky.FW.ReadGangMemberSnapshot] Raw gang membership snapshots are unsupported on the custom framework: %s", tostring(gang_name))
    return nil, "unsupported_framework"
end

function Sky.FW.ReadJobMemberSnapshot(job_name, authorize)
    Sky.Debug("error", "[Sky.FW.ReadJobMemberSnapshot] Raw Core membership snapshots are unsupported on the custom framework: %s", tostring(job_name))
    return nil, "unsupported_framework"
end

function Sky.FW.ReadJobAdoptionSnapshot(job_name, aliases)
    Sky.Debug("error", "[Sky.FW.ReadJobAdoptionSnapshot] Persisted adoption snapshots are unsupported on the custom framework: %s", tostring(job_name))
    return nil, "unsupported_framework"
end

function Sky.FW.SetJob(source_or_identifier, job_name, job_grade)
    error("Custom framework integration: SetJob is not implemented")
end

function Sky.FW.RefreshJobs()
    error("Custom framework integration: RefreshJobs is not implemented")
end

function Sky.FW.UpdateJob(job_name, data, skip_check)
    error("Custom framework integration: UpdateJob is not implemented")
end

function Sky.FW.AddJobGrade(job_name, grade_data, skip_check)
    error("Custom framework integration: AddJobGrade is not implemented")
end

function Sky.FW.RemoveJobGrade(job_name, grade, skip_check)
    error("Custom framework integration: RemoveJobGrade is not implemented")
end

function Sky.FW.DoesJobExist(job_name, grade)
    error("Custom framework integration: DoesJobExist is not implemented")
end

function Sky.FW.GetJobs()
    -- Return { name, label, grades = { { grade, name, label, payment } } } entries.
    error("Custom framework integration: GetJobs is not implemented")
end

function Sky.FW.GetPlayers()
    -- Return an array of online server ids.
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do players[#players + 1] = tonumber(playerId) end
    return players
end

function Sky.FW.IsVehicleOwnedByPlayer(source, plate)
    error("Custom framework integration: IsVehicleOwnedByPlayer is not implemented")
end

function Sky.FW.GetOwnedVehicleCount(source)
    if not IsDuplicityVersion() then
        return nil, "server_only"
    end

    -- Return a non-negative integer for an online character. Keep nil, "unsupported"
    -- until the custom framework has a persistent vehicle ownership lookup.
    return nil, "unsupported"
end

function Sky.FW.GetJobData(source_or_identifier, action)
    -- `action` may be one field name or an array of field names.
    error("Custom framework integration: GetJobData is not implemented")
end

function Sky.FW.GetStatus(source, name)
    -- Return a normalized value from 0 to 100.
    error("Custom framework integration: GetStatus is not implemented")
end

function Sky.FW.ChangePlayerName(source_or_identifier, firstname, lastname)
    error("Custom framework integration: ChangePlayerName is not implemented")
end

function Sky.FW.SetStatus(source, name, value)
    error("Custom framework integration: SetStatus is not implemented")
end

function Sky.FW.RemoveStatus(source, name, amount)
    error("Custom framework integration: RemoveStatus is not implemented")
end

function Sky.FW.IsDead(source)
    error("Custom framework integration: IsDead is not implemented")
end

function Sky.FW.SetPlayerState(source, key, value)
    Player(source).state:set(key, value, true)
end

function Sky.FW.GetPlayerState(source, key)
    return Player(source).state[key]
end

function Sky.FW.GetPlaytime(source)
    -- Return playtime in minutes.
    error("Custom framework integration: GetPlaytime is not implemented")
end

function Sky.FW.HasCommandPermission(source, ace_permission)
    -- Console source 0 must be allowed.
    return source == 0 or IsPlayerAceAllowed(source, ace_permission)
end

function Sky.FW.IsPlayerVisibleOnCamera(source)
    error("Custom framework integration: IsPlayerVisibleOnCamera is not implemented")
end

function Sky.FW.SetDuty(source, on_duty)
    error("Custom framework integration: SetDuty is not implemented")
end

function Sky.FW.ToggleDuty(source)
    error("Custom framework integration: ToggleDuty is not implemented")
end

function Sky.FW.GetOnDutyCount(job_name)
    -- Return the count followed by an array of matching server ids.
    error("Custom framework integration: GetOnDutyCount is not implemented")
end

-- Sky Banking should initialise only once a multi-character slot is selected.
AddEventHandler('drp_core:server:characterSelected', function(source)
    TriggerEvent('sky_base:playerLoaded', source)
end)
