if Sky.Config.banking ~= "apex" then return end
if not IsDuplicityVersion() then return end

local function normalize_amount(amount)
    local numeric_amount = tonumber(amount)
    assert(numeric_amount and numeric_amount > 0 and numeric_amount < math.huge,
        "Apex banking amount must be a positive finite number")
    return numeric_amount
end

function Sky.FW.GetSharedAccountBalance(name)
    local job_name = name:gsub("^society_", "")
    local balance = tonumber(exports["apex_banking"]:GetBusinessBalance(job_name))
    assert(balance, ("Apex banking returned an invalid balance for '%s'"):format(job_name))
    return balance
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    local job_name = name:gsub("^society_", "")
    local numeric_amount = normalize_amount(amount)
    return exports["apex_banking"]:AddBusinessMoney(job_name, numeric_amount, "sky_base")
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    local numeric_amount = normalize_amount(amount)
    local balance = Sky.FW.GetSharedAccountBalance(name)
    if balance < numeric_amount then
        Sky.Debug("warn", "apex_banking: insufficient funds in '%s' (balance=%s, requested=%s)",
            name, balance, numeric_amount)
        return false
    end

    local job_name = name:gsub("^society_", "")
    return exports["apex_banking"]:RemoveBusinessMoney(job_name, numeric_amount, "sky_base")
end
