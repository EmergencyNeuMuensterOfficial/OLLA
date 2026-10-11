if Sky.Config.banking == "crm" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    local RESOURCE = "crm-banking"

    local function normalizeAccountName(name)
        return tostring(name):gsub("^society_", "")
    end

    function Sky.FW.GetSharedAccountBalance(name, options)
        local account_name = normalizeAccountName(name)
        local balance = exports[RESOURCE]:getSocietyMoney(account_name)
        if type(balance) == "number" then return balance end
        if type(options) == "table" and options.strict then
            error("[banking/crm] Society balance unavailable: " .. account_name)
        end
        return 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        return exports[RESOURCE]:addSocietyMoney(normalizeAccountName(name), amount)
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        return exports[RESOURCE]:removeSocietyMoney(normalizeAccountName(name), amount)
    end

    Sky.FW.SharedAccountCreationSupported = true
    function Sky.FW.EnsureSharedAccount(name, label)
        local account_name = normalizeAccountName(name)
        if type(exports[RESOURCE]:getSocietyMoney(account_name)) == "number" then
            return true
        end

        exports[RESOURCE]:createSocietyAccount(account_name, label or account_name, 0)
        if type(exports[RESOURCE]:getSocietyMoney(account_name)) ~= "number" then
            return false, "account_creation_failed"
        end
        return true
    end

    Sky.FW.BankInvestigationCapabilities = { accounts = true, statements = false, freeze = false }
    function Sky.FW.GetBankAccounts(identifier)
        local rows = exports[RESOURCE]:getPlayerAccounts(identifier)
        if type(rows) ~= "table" then error("[banking/crm] Invalid player account response") end

        local accounts = {}
        for _, row in ipairs(rows) do
            if type(row) ~= "table" or type(row.crm_iban) ~= "string" or row.crm_iban == "" then
                error("[banking/crm] Player account has no documented IBAN")
            end
            local balance = tonumber(row.crm_balance)
            if balance == nil then
                error("[banking/crm] Player account has no numeric balance: " .. row.crm_iban)
            end
            accounts[#accounts + 1] = {
                id = row.crm_iban,
                number = row.crm_iban,
                label = tostring(row.crm_type or row.crm_iban),
                balance = balance,
                frozen = false,
                primary = false,
            }
        end
        return accounts
    end
end
