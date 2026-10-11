if Sky.Config.banking == "wasabi" then
    if not IsDuplicityVersion() then return end

    local ACCOUNT_TYPES = { bank = true, savings = true, shared = true }

    local function normalizeAccountType(account_type)
        if account_type == "personal" then return "bank" end
        if not ACCOUNT_TYPES[account_type] then
            error("[banking/wasabi] Unsupported account type: " .. tostring(account_type))
        end
        return account_type
    end

    local function providerAccountKey(account_type, account_id)
        if account_id == nil or tostring(account_id) == "" then
            error("[banking/wasabi] Account has no provider ID")
        end
        return normalizeAccountType(account_type) .. ":" .. tostring(account_id)
    end

    local function parseAccountKey(account_key)
        local account_type, account_id = tostring(account_key):match("^([^:]+):(.+)$")
        if not account_type or not account_id then
            error("[banking/wasabi] Invalid account key: " .. tostring(account_key))
        end
        return normalizeAccountType(account_type), account_id
    end

    function Sky.FW.GetSharedAccountBalance(name, options)
        local accountBalance = exports.wasabi_banking:GetAccountBalance(name, "society")
        if type(options) == "table" and options.strict and type(accountBalance) ~= "number" then
            error("[banking/wasabi] Society balance unavailable: " .. tostring(name))
        end
        return accountBalance or 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount, options)
        return exports.wasabi_banking:AddMoney("society", name, amount)
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount, options)
        return exports.wasabi_banking:RemoveMoney("society", name, amount)
    end

    Sky.FW.SharedAccountCreationSupported = true
    function Sky.FW.EnsureSharedAccount(name, label)
        local currentBalance = exports.wasabi_banking:GetAccountBalance(name, "society")
        if type(currentBalance) == "number" then return true end

        local created = exports.wasabi_banking:CreateJobAccount(name, 0)
        if created ~= true then return false, "account_creation_failed" end

        local balance = exports.wasabi_banking:GetAccountBalance(name, "society")
        if type(balance) ~= "number" then return false, "account_creation_failed" end
        return true
    end

    Sky.FW.BankInvestigationCapabilities = { accounts = true, statements = false, freeze = true }
    Sky.FW.BankPlayerPaymentsSupported = true

    function Sky.FW.DebitPlayerBank(source, amount, reason)
        if type(amount) ~= "number" or amount < 1 or amount % 1 ~= 0 then return false end
        return exports.wasabi_banking:RemoveMoney("bank", source, amount)
    end

    function Sky.FW.CreditPlayerBank(source, amount, reason)
        if type(amount) ~= "number" or amount < 1 or amount % 1 ~= 0 then return false end
        return exports.wasabi_banking:AddMoney("bank", source, amount)
    end

    function Sky.FW.GetBankAccounts(identifier)
        local rows = exports.wasabi_banking:GetAccountsByPlayer(identifier)
        if type(rows) ~= "table" then error("[banking/wasabi] Invalid account response") end

        local accounts = {}
        for _, row in ipairs(rows) do
            if type(row) ~= "table" then error("[banking/wasabi] Account row is invalid") end
            local account_type = normalizeAccountType(row.type)
            local account_id = row.id
            local account_key = providerAccountKey(account_type, account_id)
            local frozen = row.frozen
            if frozen ~= true and frozen ~= false then
                frozen = exports.wasabi_banking:IsAccountFrozen(account_type, account_id)
            end
            if frozen ~= true and frozen ~= false then
                error("[banking/wasabi] Account freeze state is invalid: " .. account_key)
            end

            accounts[#accounts + 1] = {
                id = account_key,
                number = tostring(row.iban or row.accountNumber or row.number or account_id),
                label = tostring(row.label or row.name or account_type),
                balance = tonumber(row.balance),
                frozen = frozen,
                primary = account_type == "bank",
            }
        end
        return accounts
    end

    function Sky.FW.SetBankAccountFrozen(account_key, frozen, actor, reason)
        local account_type, account_id = parseAccountKey(account_key)
        local accepted
        if frozen then
            accepted = exports.wasabi_banking:FreezeAccount(account_type, account_id, actor)
        else
            accepted = exports.wasabi_banking:UnfreezeAccount(account_type, account_id)
        end
        if accepted ~= true then return false end
        return exports.wasabi_banking:IsAccountFrozen(account_type, account_id) == frozen
    end
end
