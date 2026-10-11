if Sky.Config.banking ~= "qb" then return end
if not IsDuplicityVersion() then return end

local RESOURCE = "qb-banking"
local _ensured = {}

local function ensureAccount(name)
    if Sky.ManagedJobs.OwnsAccount(name) then return end
    if _ensured[name] then return end
    if GetResourceState(RESOURCE) ~= "started" then return end

    if exports[RESOURCE]:GetAccount(name) then
        _ensured[name] = true
        return
    end

    local ok, err = pcall(function()
        exports[RESOURCE]:CreateJobAccount(name, 0)
    end)
    if ok then
        _ensured[name] = true
        Sky.Debug("info", ("[banking/qb] account '%s' created"):format(name))
    else
        Sky.Debug("warn", ("[banking/qb] CreateJobAccount('%s') failed: %s"):format(name, tostring(err)))
    end
end

Sky.FW.SharedAccountCreationSupported = true
Sky.FW.SharedAccountCreationAwaited = true
Sky.FW.SharedAccountProvisioner = {
    resource = RESOURCE,
    -- Installed Create*Account overwrites its loaded cache before the awaited INSERT.
    -- A late foreign SQL account can therefore not be protected by this API.
    freshCreationSupported = false,
    probe = function(name, kind)
        local result = { accountType = kind, canCreate = true }
        if #name > 50 then
            result.status, result.error = "blocked", "invalid_society_account"
            return result
        end
        local saved = Sky.DB.Select("SELECT id, account_name, account_type FROM bank_accounts WHERE account_name = ?", { name })
        if not saved then
            result.status, result.error = "blocked", "account_storage_unavailable"
            return result
        end
        local loaded = exports[RESOURCE]:GetAccount(name)
        result.persisted, result.loaded = saved[1] ~= nil, loaded ~= nil
        result.id = saved[1] and saved[1].id
        local other_group = kind == "gang" and Sky.FW.GetJobs()[name]
            or Sky.Config.framework ~= "esx" and kind == "job" and Sky.FW.GetGangs()[name]
        if #saved > 1 or saved[1] and saved[1].account_type ~= kind
            or loaded and (loaded.account_name ~= name or loaded.account_type ~= kind) or other_group then
            result.status, result.error = "blocked", "account_type_collision"
        elseif saved[1] and not loaded then
            result.status, result.error = "blocked", "account_not_loaded"
        elseif loaded and not saved[1] then
            result.status, result.error = "blocked", "account_persistence_pending"
        else
            result.status = saved[1] and "existing" or "missing"
        end
        return result
    end,
    create = function(name, label, kind)
        if kind == "gang" then return exports[RESOURCE]:CreateGangAccount(name, 0) end
        return exports[RESOURCE]:CreateJobAccount(name, 0)
    end
}

function Sky.FW.GetSharedAccountBalance(name)
    ensureAccount(name)
    if Sky.ManagedJobs.OwnsAccount(name) and not exports[RESOURCE]:GetAccount(name) then
        error("[banking/qb] Managed account is not loaded: " .. name)
    end
    return exports[RESOURCE]:GetAccountBalance(name) or 0
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    ensureAccount(name)
    return exports[RESOURCE]:AddMoney(name, amount)
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    ensureAccount(name)
    return exports[RESOURCE]:RemoveMoney(name, amount)
end
