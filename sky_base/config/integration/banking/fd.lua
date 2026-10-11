if Sky.Config.banking == "fd" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    local RESOURCE = "fd_banking"

    local function normalizeAccountName(name)
        return tostring(name):gsub("^society_", "")
    end

    local function readBalance(account)
        if type(account) == "number" then
            return account
        elseif account and type(account) == "table" and account.balance then
            return tonumber(account.balance)
        end
        return nil
    end

    function Sky.FW.GetSharedAccountBalance(name, options)
        local account_name = normalizeAccountName(name)
        local balance = readBalance(exports[RESOURCE]:GetAccount(account_name))
        if type(options) == "table" and options.strict and type(balance) ~= "number" then
            error("[banking/fd] Society balance unavailable: " .. account_name)
        end
        return balance or 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        return exports[RESOURCE]:AddMoney(normalizeAccountName(name), amount, "sky_base")
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        return exports[RESOURCE]:RemoveMoney(normalizeAccountName(name), amount, "sky_base")
    end
end
