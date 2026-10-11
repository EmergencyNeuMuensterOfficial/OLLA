if Sky.Config.banking ~= "oxlyn" then return end
if not IsDuplicityVersion() then return end

-- Oxlyn must use Config.Business.accountSource = "society".
-- Its standalone business ledger has no documented shared-account exports.
local is_esx = Sky.Config.framework == "esx"
assert(is_esx or Sky.Config.framework == "qb" or Sky.Config.framework == "qbox",
    "Oxlyn banking requires ESX, QBCore or Qbox")

local function get_shared_account(name)
    local job_name = name:gsub("^society_", "")
    local account
    if is_esx then
        account = exports["esx_addonaccount"]:GetSharedAccount("society_" .. job_name)
    else
        account = exports["qb-banking"]:GetAccount(job_name)
    end
    assert(account, ("Oxlyn society account '%s' is not loaded; register it in the framework banking provider first")
        :format(job_name))
    return account, job_name
end

local function normalize_amount(amount)
    local numeric_amount = tonumber(amount)
    assert(numeric_amount and numeric_amount > 0 and numeric_amount < math.huge,
        "Oxlyn banking amount must be a positive finite number")
    return numeric_amount
end

function Sky.FW.GetSharedAccountBalance(name)
    local account = get_shared_account(name)
    local balance = tonumber(is_esx and account.money or account.account_balance)
    assert(balance, ("Oxlyn society account '%s' returned an invalid balance"):format(name))
    return balance
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    local numeric_amount = normalize_amount(amount)
    local account, job_name = get_shared_account(name)
    if is_esx then
        account.addMoney(numeric_amount)
        return true
    end
    local result = exports["qb-banking"]:AddMoney(job_name, numeric_amount, "sky_base")
    return result == true or (type(result) == "number" and result > 0)
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    local numeric_amount = normalize_amount(amount)
    local balance = Sky.FW.GetSharedAccountBalance(name)
    if balance < numeric_amount then
        Sky.Debug("warn", "Oxlyn society account '%s' has insufficient funds (balance=%s, requested=%s)",
            name, balance, numeric_amount)
        return false
    end
    local account, job_name = get_shared_account(name)
    if is_esx then
        account.removeMoney(numeric_amount)
        return true
    end
    local result = exports["qb-banking"]:RemoveMoney(job_name, numeric_amount, "sky_base")
    return result == true or (type(result) == "number" and result > 0)
end
