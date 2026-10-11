if Sky.Config.banking == "groot" then
    if not IsDuplicityVersion() then return end
    if not Sky or not Sky.FW then return end

    local RESOURCE = "g-banking"

    local function normalize(name)
        if type(name) ~= "string" then return name end
        return (name:gsub("^society_", ""))
    end

    function Sky.FW.GetSharedAccountBalance(name)
        if GetResourceState(RESOURCE) ~= "started" then return 0 end
        local ok, balance = pcall(function()
            return exports[RESOURCE]:GetAccountBalance(normalize(name))
        end)
        if ok and type(balance) == "number" then return balance end
        return 0
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        if GetResourceState(RESOURCE) ~= "started" then return end
        if not amount or amount < 1 then return end
        pcall(function()
            exports[RESOURCE]:AddMoney(normalize(name), amount)
        end)
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        if GetResourceState(RESOURCE) ~= "started" then return end
        if not amount or amount < 1 then return end
        pcall(function()
            exports[RESOURCE]:RemoveMoney(normalize(name), amount)
        end)
    end
end
