if Sky.Config.banking ~= "retro" then return end
if not IsDuplicityVersion() then return end

local RESOURCE = "rs_bank"

local function resolveBusinessName(name)
    assert(type(name) == "string", "Retro banking account name must be a string")

    local business_name = name:gsub("^society_", "")
    assert(business_name ~= "", "Retro banking account name must not be empty")
    return business_name
end

local function resolveAmount(amount)
    local numeric_amount = tonumber(amount)
    assert(numeric_amount and numeric_amount > 0, "Retro banking amount must be greater than zero")
    return numeric_amount
end

function Sky.FW.GetSharedAccountBalance(name)
    local balance = exports[RESOURCE]:GetBusinessMoney(resolveBusinessName(name))
    return tonumber(balance) or 0
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    local result = exports[RESOURCE]:AddBusinessMoney(
        resolveBusinessName(name),
        resolveAmount(amount),
        "Sky business deposit"
    )
    return result ~= false
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    local business_name = resolveBusinessName(name)
    local numeric_amount = resolveAmount(amount)
    if (tonumber(exports[RESOURCE]:GetBusinessMoney(business_name)) or 0) < numeric_amount then
        return false
    end

    local result = exports[RESOURCE]:RemoveBusinessMoney(
        business_name,
        numeric_amount,
        "Sky business withdrawal"
    )
    return result ~= false
end
