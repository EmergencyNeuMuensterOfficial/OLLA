if Sky.Config.banking ~= "devmosaic" then return end
if not IsDuplicityVersion() then return end

local RESOURCE = "dm-banking"

function Sky.FW.GetSharedAccountBalance(name)
    local account_name = "job:" .. name:gsub("^society_", "")
    return exports[RESOURCE]:getAccountMoney(account_name) or 0
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    local account_name = "job:" .. name:gsub("^society_", "")
    return exports[RESOURCE]:addAccountMoney(account_name, amount) ~= false
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    local account_name = "job:" .. name:gsub("^society_", "")
    if (exports[RESOURCE]:getAccountMoney(account_name) or 0) < amount then
        return false
    end

    return exports[RESOURCE]:removeAccountMoney(account_name, amount) ~= false
end
