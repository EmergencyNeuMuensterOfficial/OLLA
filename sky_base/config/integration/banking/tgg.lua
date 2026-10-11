if Sky.Config.banking == "tgg" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    local RESOURCE = "tgg-banking"
    local _ensured = {}

    local function ensureAccount(name)
        if _ensured[name] then return end

        local result = exports[RESOURCE]:CreateBusinessAccount(name, 0)
        if result.success then
            _ensured[name] = true
            return
        end

        Sky.Debug("warn", ("[banking/tgg] CreateBusinessAccount('%s') failed: %s"):format(name, result.error or result.message or "unknown error"))
    end

    function Sky.FW.GetSharedAccountBalance(name, options)
        ensureAccount(name)
        local balance = exports["tgg-banking"]:GetSocietyAccountMoney(name)
        if type(options) == "table" and options.strict and type(balance) ~= "number" then
            error("[banking/tgg] Society balance unavailable: " .. name)
        end
        if balance then
            return balance
        end
        return 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        ensureAccount(name)
        return exports["tgg-banking"]:AddSocietyMoney(name, amount)
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        ensureAccount(name)
        return exports["tgg-banking"]:RemoveSocietyMoney(name, amount)
    end

    Sky.FW.BankInvestigationCapabilities = { accounts = true, statements = false, freeze = true }
    Sky.FW.BankPlayerPaymentsSupported = false -- No documented personal debit/credit export.
    function Sky.FW.GetBankAccounts(identifier)
        local account = exports[RESOURCE]:GetPersonalAccountByPlayerIdentifier(identifier)
        if not account then return {} end
        if not tonumber(account.iban) then error("[banking/tgg] Personal account has no numeric IBAN") end
        return { { id = tostring(account.iban), number = tostring(account.iban), label = tostring(account.iban),
            balance = tonumber(account.balance), primary = true,
            frozen = exports[RESOURCE]:IsAccountFrozen(tonumber(account.iban)) } }
    end
    function Sky.FW.SetBankAccountFrozen(account_id, frozen, actor, reason)
        local accepted
        if frozen then accepted = exports[RESOURCE]:FreezeAccount(tonumber(account_id))
        else accepted = exports[RESOURCE]:UnfreezeAccount(tonumber(account_id)) end
        if accepted ~= true then return accepted end
        return exports[RESOURCE]:IsAccountFrozen(tonumber(account_id)) == frozen
    end
end
