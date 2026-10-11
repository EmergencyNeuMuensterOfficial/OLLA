if Sky.Config.banking == "rx" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    function Sky.FW.GetSharedAccountBalance(name)
        local account = exports["RxBanking"]:GetSocietyAccount(name)
        if account then
            return account.balance or 0
        end
        return 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        exports["RxBanking"]:AddSocietyMoney(name, amount, "deposit", "sky_base")
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        exports["RxBanking"]:RemoveSocietyMoney(name, amount, "withdraw", "sky_base")
    end
end
