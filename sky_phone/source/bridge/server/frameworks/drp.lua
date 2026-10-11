-- Dülmen Roleplay framework adapter for Sky Phone.
if Bridge.Framework.Name ~= "drp" then
    return
end

local function get_character(source)
    return exports.drp_core:GetActiveCharacter(tonumber(source))
end

local function account_column(account)
    if account == "cash" or account == "money" then return "cash" end
    if account == "bank" then return "bank" end
    return nil
end

local function update_money(source, account, amount, subtract)
    local column = account_column(account)
    amount = math.floor(tonumber(amount) or 0)
    local character = get_character(source)
    if not column or not character or amount <= 0 then return false end

    local current = tonumber(character[column]) or 0
    if subtract and current < amount then return false end
    local balance = subtract and current - amount or current + amount

    local changed = MySQL.update.await(("UPDATE drp_characters SET `%s` = ? WHERE id = ?"):format(column), {
        balance, character.id
    })
    if not changed or changed < 1 then return false end

    character[column] = balance
    if column == "cash" and GetResourceState("ox_inventory") == "started" then
        exports.ox_inventory:SetItem(tonumber(source), "money", balance)
    end
    TriggerClientEvent("drp_core:client:moneyUpdated", tonumber(source), column, balance, "sky_phone")
    return true
end

function Bridge.Framework.GetStatusData(source)
    return {}
end

function Bridge.Framework.GetPlayers()
    local players = {}
    for _, player_source in ipairs(GetPlayers()) do
        player_source = tonumber(player_source)
        if get_character(player_source) then players[#players + 1] = player_source end
    end
    return players
end

function Bridge.Framework.GetIdentifier(source)
    local character = get_character(source)
    return character and ("drp:%s"):format(character.id) or nil
end

function Bridge.Framework.GetMoney(source, account)
    local character = get_character(source)
    local column = account_column(account)
    return character and column and tonumber(character[column]) or nil
end

function Bridge.Framework.AddMoney(source, account, amount)
    return update_money(source, account, amount, false)
end

function Bridge.Framework.RemoveMoney(source, account, amount)
    return update_money(source, account, amount, true)
end

function Bridge.Framework.GetCharacterName(source)
    local character = get_character(source)
    return character and character.first_name or nil, character and character.last_name or nil
end

function Bridge.Framework.GetFirstname(source)
    local character = get_character(source)
    return character and character.first_name or nil
end

function Bridge.Framework.GetLastname(source)
    local character = get_character(source)
    return character and character.last_name or nil
end

function Bridge.Framework.GetBirthdate(source)
    local character = get_character(source)
    return character and character.date_of_birth or nil
end

function Bridge.Framework.GetJob(source)
    local character = get_character(source)
    local name = character and character.job_name or "unemployed"
    local grade = character and tonumber(character.job_grade) or 0
    local label = name == "unemployed" and "Arbeitslos" or name
    return { name = name, label = label, grade = grade, gradeLabel = tostring(grade), onDuty = true }
end

function Bridge.Framework.RegisterUsableItem()
    -- ox_inventory owns usable-item registration for this server.
    return true
end
