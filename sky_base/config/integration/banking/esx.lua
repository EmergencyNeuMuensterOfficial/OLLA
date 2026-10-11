if Sky.Config.banking == "esx" then
    if not IsDuplicityVersion() then return end

    local function getSharedAccount(name)
        local account_name = "society_" .. name:gsub("^society_", "")
        local account
        TriggerEvent("esx_addonaccount:getSharedAccount", account_name, function(shared_account)
            account = shared_account
        end)
        if not account then
            error(("[banking/esx] Shared account '%s' is not loaded. Register it in addon_account with shared=1 and restart the server; existing balances must be preserved.")
                :format(account_name), 2)
        end
        return account
    end

    Sky.FW.SharedAccountCreationSupported = true
    Sky.FW.SharedAccountCreationAwaited = true
    Sky.FW.SharedAccountProvisioner = {
        resource = "esx_addonaccount",
        freshCreationSupported = true,
        probe = function(name, kind)
            local account_name = "society_" .. name
            local result = { accountName = account_name, accountType = "shared", canCreate = kind == "job" }
            if #account_name > 60 then
                result.status, result.error = "blocked", "invalid_society_account"
                return result
            end
            if kind ~= "job" then
                result.status, result.error = "blocked", "account_creation_unsupported"
                return result
            end
            local accounts = Sky.DB.Select("SELECT name, shared FROM addon_account WHERE name = ?", { account_name })
            local data = Sky.DB.Select("SELECT id, owner FROM addon_account_data WHERE account_name = ?", { account_name })
            if not accounts or not data then
                result.status, result.error = "blocked", "account_storage_unavailable"
                return result
            end
            local loaded = exports["esx_addonaccount"]:GetSharedAccount(account_name)
            result.persisted, result.loaded = #accounts > 0 and #data > 0, loaded ~= nil
            result.id = data[1] and data[1].id
            if #accounts > 1 or #data > 1 or accounts[1] and tonumber(accounts[1].shared) ~= 1
                or data[1] and data[1].owner ~= nil or not accounts[1] and data[1]
                or loaded and (loaded.name ~= account_name or loaded.owner ~= nil) then
                result.status, result.error = "blocked", "account_type_collision"
            elseif accounts[1] and (not data[1] or not loaded) then
                result.status, result.error = "blocked", "account_not_loaded"
            elseif loaded and not result.persisted then
                result.status, result.error = "blocked", "account_persistence_pending"
            else
                result.status = result.persisted and "existing" or "missing"
            end
            return result
        end,
        create = function(name, label, kind, options)
            if options and options.requireNew and exports["esx_addonaccount"]:GetSharedAccount("society_" .. name) then
                return false
            end
            local account = exports["esx_addonaccount"]:AddSharedAccount({ name = "society_" .. name, label = label }, 0)
            if options and options.requireNew then
                if not account then return false end
                local rows = Sky.DB.Select("SELECT id FROM addon_account_data WHERE account_name = ? AND owner IS NULL", { "society_" .. name })
                if not rows or #rows ~= 1 then return false end
                return true, tonumber(rows[1].id)
            end
            return account ~= nil
        end
    }

    function Sky.FW.GetSharedAccountBalance(name)
        local account = getSharedAccount(name)
        return account.money
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        local account = getSharedAccount(name)
        account.addMoney(amount)
        return true
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        local account = getSharedAccount(name)
        if account.money < amount then
            Sky.Debug("error", ("[banking/esx] Withdrawal rejected for '%s': amount=%s balance=%s")
                :format(name, tostring(amount), tostring(account.money)))
            return false
        end
        account.removeMoney(amount)
        return true
    end
end
