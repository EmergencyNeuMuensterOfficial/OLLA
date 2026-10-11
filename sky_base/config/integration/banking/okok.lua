if Sky.Config.banking == "okok" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    function Sky.FW.GetSharedAccountBalance(name)
        local accountBalance = exports["okokBanking"]:GetAccount(name)
        if accountBalance ~= nil then
            return accountBalance
        end
        return 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        exports["okokBanking"]:AddMoney(name, amount)
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        exports["okokBanking"]:RemoveMoney(name, amount)
    end
end
