if Sky.Config.banking == "synz" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    function Sky.FW.GetSharedAccountBalance(name)
        local account = exports["synz_banking"]:GetSocietyBalance(name)
        return account or 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        exports["synz_banking"]:AddSocietyMoney(name, amount, "sky_base")
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        exports["synz_banking"]:RemoveSocietyMoney(name, amount, "sky_base")
    end
end
