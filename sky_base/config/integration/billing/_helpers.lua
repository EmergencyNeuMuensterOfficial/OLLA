Sky.Billing = Sky.Billing or {}

function Sky.Functions.CanIssueBill(source)
    local player_source = tonumber(source)
    if not player_source or player_source <= 0 or player_source >= math.huge or player_source % 1 ~= 0 then
        Sky.Debug("debug", "Billing issuer must be a positive player source (received %s)", tostring(source))
        return false
    end

    return true
end

local function normalizeBillingText(value)
    if value == nil then
        return nil
    end

    local text = tostring(value):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        return nil
    end

    return text
end

function Sky.Billing.NormalizeRequest(source, target, billType, account, reason, amount, infos)
    local normalizedType = normalizeBillingText(billType)
    normalizedType = normalizedType and normalizedType:lower() or nil
    if normalizedType ~= "society" and normalizedType ~= "player" then
        -- ponytail: old 5-arg SendBill(src, target, account, reason, amount) back-compat for customer scripts
        account, reason, amount, infos = billType, account, reason, amount
        normalizedType = nil
    end

    local normalizedAccount = normalizeBillingText(account)
    if not normalizedType then
        normalizedType = normalizedAccount and "society" or "player"
    end

    if normalizedType == "society" and normalizedAccount and not normalizedAccount:match("^society_") then
        normalizedAccount = "society_" .. normalizedAccount
    end

    return {
        source = tonumber(source) or source,
        target = tonumber(target) or target,
        account = normalizedAccount,
        jobName = normalizedAccount and normalizedAccount:gsub("^society_", "") or nil,
        reason = normalizeBillingText(reason),
        amount = tonumber(amount),
        infos = normalizeBillingText(infos),
        type = normalizedType
    }
end
