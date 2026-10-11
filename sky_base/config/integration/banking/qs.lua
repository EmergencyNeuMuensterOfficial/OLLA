if Sky.Config.banking == "qs" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    local function getResource()
        if GetResourceState("qs-banking") == "started" then return "qs-banking" end
        if GetResourceState("qs_banking") == "started" then return "qs_banking" end
        return nil
    end

    function Sky.FW.GetSharedAccountBalance(name)
        local resource = getResource()
        if not resource then return 0 end
        local accountNames = { name, "society_" .. name }
        for _, accountName in ipairs(accountNames) do
            local ok, result = pcall(function()
                return exports[resource]:GetAccountBalance(accountName)
            end)
            if ok and result ~= nil then
                return result
            end
        end
        return 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        local resource = getResource()
        if not resource then return end
        local accountNames = { name, "society_" .. name }
        for _, accountName in ipairs(accountNames) do
            local ok
            ok = pcall(function() exports[resource]:AddMoney(accountName, amount, "sky_base") end)
            if ok then return end
            ok = pcall(function() exports[resource]:AddMoney(accountName, amount) end)
            if ok then return end
            ok = pcall(function() exports[resource]:AddAccountMoney(accountName, amount, "sky_base") end)
            if ok then return end
            ok = pcall(function() exports[resource]:AddBalance(accountName, amount, "sky_base") end)
            if ok then return end
        end
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        local resource = getResource()
        if not resource then return end
        local accountNames = { name, "society_" .. name }
        for _, accountName in ipairs(accountNames) do
            local ok
            ok = pcall(function() exports[resource]:RemoveMoney(accountName, amount, "sky_base") end)
            if ok then return end
            ok = pcall(function() exports[resource]:RemoveMoney(accountName, amount) end)
            if ok then return end
            ok = pcall(function() exports[resource]:RemoveAccountMoney(accountName, amount, "sky_base") end)
            if ok then return end
            ok = pcall(function() exports[resource]:RemoveBalance(accountName, amount, "sky_base") end)
            if ok then return end
        end
    end
end
