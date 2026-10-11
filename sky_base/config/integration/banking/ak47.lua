if Sky.Config.banking == "ak47" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    local RESOURCE = "ak47_banking"
    local REASON   = "Sky Systems"

    function Sky.FW.GetSharedAccountBalance(name)
        return exports[RESOURCE]:GetAccountBalance(name) or 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        exports[RESOURCE]:AddMoney(name, amount, REASON)
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        exports[RESOURCE]:RemoveMoney(name, amount, REASON)
    end
end
