if Sky.Config.banking ~= "companymanager" then return end
if not IsDuplicityVersion() then return end

local RESOURCE = "bcs_companymanager"
local ACCOUNT = "money"
local IDENTIFIER = "sky_base"
local REASON = "sky_base"

function Sky.FW.GetSharedAccountBalance(name)
    return exports[RESOURCE]:GetCompanyMoney(name:gsub("^society_", ""), ACCOUNT) or 0
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    exports[RESOURCE]:AddCompanyMoney(name:gsub("^society_", ""), ACCOUNT, amount, IDENTIFIER, REASON, false)
    return true
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    local company_name = name:gsub("^society_", "")

    if (exports[RESOURCE]:GetCompanyMoney(company_name, ACCOUNT) or 0) < amount then
        return false
    end

    exports[RESOURCE]:RemoveCompanyMoney(company_name, ACCOUNT, amount, IDENTIFIER, REASON, false)
    return true
end
