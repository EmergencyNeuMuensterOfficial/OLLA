if Sky.Config.banking == "bablo" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    local RESOURCE = "bablo-banking"
    local _ensured = {}

    local function normalizeAccountName(name)
        return tostring(name):gsub("^society_", "")
    end

    local function mutationSucceeded(result)
        if type(result) == "table" then return result.success == true end
        return result == true
    end

    function Sky.FW.GetSharedAccountBalance(name, options)
        local accountBalance = exports[RESOURCE]:GetSocietyBalance(normalizeAccountName(name))
        if type(accountBalance) == "number" then return accountBalance end
        if type(options) == "table" and options.strict then
            error("[banking/bablo] Society balance unavailable: " .. normalizeAccountName(name))
        end
        return 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        return mutationSucceeded(exports[RESOURCE]:AddSocietyMoney(
            normalizeAccountName(name), amount, "sky_base"
        ))
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        return mutationSucceeded(exports[RESOURCE]:RemoveSocietyMoney(
            normalizeAccountName(name), amount, {
            description = "sky_base",
        }))
    end

    Sky.FW.SharedAccountCreationSupported = true
    function Sky.FW.EnsureSharedAccount(name, label)
        local account_name = normalizeAccountName(name)
        if _ensured[account_name] then return true end

        if type(exports[RESOURCE]:GetSocietyBalance(account_name)) ~= "number" then
            local result = exports[RESOURCE]:RegisterSociety(account_name, {
                label = label or account_name,
            })
            if type(result) == "table" and result.success ~= true then
                return false, result.message or "account_creation_failed"
            end
            if result == false then return false, "account_creation_failed" end
        end

        if type(exports[RESOURCE]:GetSocietyBalance(account_name)) ~= "number" then
            return false, "account_creation_failed"
        end

        _ensured[account_name] = true
        return true
    end
end
