local activeDuty = {}
local staffCache = {}

local function getLicense(source)
    return GetPlayerIdentifierByType(source, 'license')
end

local function getAceGroup(source)
    local bestGroup

    for roleId, role in pairs(ADuty.Roles) do
        if IsPlayerAceAllowed(source, ('drp.aduty.%s'):format(roleId)) then
            local group = ADuty.Groups[role.minimumGroup]
            if group and (not bestGroup or group.level > bestGroup.level) then
                bestGroup = { name = role.minimumGroup, label = group.label, level = group.level, rank = nil }
            end
        end
    end

    return bestGroup
end

local function loadStaff(source)
    local license = getLicense(source)
    if not license then return getAceGroup(source) end

    local cached = staffCache[source]
    if cached and cached.license == license then return cached end

    local row = MySQL.single.await('SELECT group_name, rank_name FROM drp_staff_groups WHERE license = ?', { license })
    local group = row and ADuty.Groups[row.group_name]
    local staff

    if group then
        staff = { license = license, name = row.group_name, label = group.label, level = group.level, rank = row.rank_name }
    else
        staff = getAceGroup(source)
        if staff then staff.license = license end
    end

    staffCache[source] = staff
    return staff
end

local function canUseRole(source, roleId)
    local role = ADuty.Roles[roleId]
    local staff = loadStaff(source)
    local required = role and ADuty.Groups[role.minimumGroup]
    return staff and required and staff.level >= required.level
end

local function allowedRoles(source)
    local roles = {}
    for roleId, data in pairs(ADuty.Roles) do
        if canUseRole(source, roleId) then
            roles[#roles + 1] = { id = roleId, label = data.label, description = data.description }
        end
    end

    table.sort(roles, function(a, b) return a.label < b.label end)
    return roles
end

local function notify(source, description, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Staff-Verwaltung', description = description, type = type or 'inform',
    })
end

local function canAssignGroup(source, targetGroupName)
    local staff = loadStaff(source)
    local target = ADuty.Groups[targetGroupName]
    if not staff or not target or staff.level < ADuty.Groups.heads.level then return false end

    -- Project owners are the only role allowed to appoint the Head-Team itself.
    if target.level == ADuty.Groups.headteam.level then
        return IsPlayerAceAllowed(source, 'drp.aduty.projektinhaber')
    end

    return target.level < staff.level
end

local function saveGroup(manager, target, groupName, rankName)
    local license = getLicense(target)
    if not license then
        notify(manager, 'Die Zielperson hat keine FiveM-Lizenz.', 'error')
        return
    end

    MySQL.prepare.await([[INSERT INTO drp_staff_groups (license, group_name, rank_name, assigned_by)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE group_name = VALUES(group_name), rank_name = VALUES(rank_name), assigned_by = VALUES(assigned_by)]], {
        license, groupName, rankName, getLicense(manager) or 'console',
    })

    staffCache[target] = nil
    local targetName = GetPlayerName(target) or ('ID %s'):format(target)
    local groupLabel = ADuty.Groups[groupName].label
    local rankLabel = rankName and ADuty.Ranks[rankName] and ADuty.Ranks[rankName].label
    notify(manager, ('%s erhielt %s%s.'):format(targetName, rankLabel or groupLabel, rankLabel and (' (%s)'):format(groupLabel) or ''), 'success')
    notify(target, ('Dir wurde die Staff-Gruppe %s zugewiesen.'):format(groupLabel), 'success')
    print(('[drp_aduty] %s assigned %s to %s'):format(GetPlayerName(manager) or manager, groupName, targetName))
end

RegisterCommand('aduty', function(source)
    if source == 0 then
        print('[drp_aduty] /aduty can only be used in game.')
        return
    end

    local roles = allowedRoles(source)
    if #roles == 0 then
        notify(source, 'Du hast keine Staff-Berechtigung.', 'error')
        return
    end

    TriggerClientEvent('drp_aduty:client:openMenu', source, roles, activeDuty[source])
end, false)

-- Assign one of the five permission groups: /staffgroup <server-id> <group>
RegisterCommand('staffgroup', function(source, args)
    if source == 0 then
        print('Usage: staffgroup <server-id> <supporter|moderation|administration|heads|headteam>')
        return
    end

    local target = tonumber(args[1])
    local groupName = args[2] and args[2]:lower()
    if not target or not GetPlayerName(target) or not ADuty.Groups[groupName] then
        notify(source, 'Nutzung: /staffgroup [ID] [supporter|moderation|administration|heads|headteam]', 'error')
        return
    end
    if not canAssignGroup(source, groupName) then
        notify(source, 'Du darfst nur Berechtigungsgruppen unter deiner eigenen Gruppe vergeben.', 'error')
        return
    end

    saveGroup(source, target, groupName, nil)
end, false)

-- Optional precise Discord rank: /staffrank <server-id> <rank-key>
RegisterCommand('staffrank', function(source, args)
    if source == 0 then
        print('Usage: staffrank <server-id> <rank-key>')
        return
    end

    local target = tonumber(args[1])
    local rankName = args[2] and args[2]:lower()
    local rank = rankName and ADuty.Ranks[rankName]
    if not target or not GetPlayerName(target) or not rank then
        notify(source, 'Ungültiger Rang. Nutze /staffgroups für die Rang-Keys.', 'error')
        return
    end
    if not canAssignGroup(source, rank.group) then
        notify(source, 'Du darfst nur Ränge aus Berechtigungsgruppen unter deiner eigenen Gruppe vergeben.', 'error')
        return
    end

    saveGroup(source, target, rank.group, rankName)
end, false)

RegisterCommand('staffgroups', function(source)
    if source == 0 then
        print('Groups: supporter, moderation, administration, heads, headteam')
        return
    end

    notify(source, 'Gruppen: supporter, moderation, administration, heads, headteam. Rang-Keys stehen in drp_aduty/config.lua.', 'inform')
end, false)

RegisterNetEvent('drp_aduty:server:setDuty', function(roleId)
    local source = source
    if type(roleId) ~= 'string' or not canUseRole(source, roleId) then
        print(('[drp_aduty] blocked unauthorised duty request from %s'):format(source))
        return
    end

    activeDuty[source] = roleId
    TriggerClientEvent('drp_aduty:client:applyOutfit', source, roleId)
end)

RegisterNetEvent('drp_aduty:server:endDuty', function()
    local source = source
    if not activeDuty[source] then return end
    activeDuty[source] = nil
    TriggerClientEvent('drp_aduty:client:restoreOutfit', source)
end)

AddEventHandler('playerDropped', function()
    activeDuty[source] = nil
    staffCache[source] = nil
end)

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS drp_staff_groups (
        license VARCHAR(80) NOT NULL,
        group_name VARCHAR(32) NOT NULL,
        rank_name VARCHAR(64) NULL,
        assigned_by VARCHAR(80) NULL,
        assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (license)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    print('[drp_aduty] Staff group storage is ready.')
end)

exports('IsOnDuty', function(source) return activeDuty[tonumber(source)] ~= nil end)
exports('GetStaffGroup', function(source)
    local staff = loadStaff(tonumber(source))
    return staff and staff.name or nil
end)
