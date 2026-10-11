if Sky.Config.billing == "codemv2" then
    if not IsDuplicityVersion() then return end

    local function isValidPlayerSource(src)
        local numericSource = tonumber(src)
        return numericSource and numericSource > 0
    end
    

    local function getSenderFromRequest(request)
        if request.type ~= "society" or type(request.account) ~= "string" or request.account == "" then
            if isValidPlayerSource(request.source) then
                return Sky.FW.GetIdentifier(request.source) or "system", Sky.FW.GetName(request.source) or "System"
            end

            return "system", "System"
        end

        if request.jobName and request.jobName ~= "" then
            return request.account, request.jobName
        end

        return request.account, request.account
    end

    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        if not request.amount or request.amount <= 0 then
            Sky.Debug("error", "codem-billingv2: invoice amount is invalid")
            return
        end

        if not request.reason then
            Sky.Debug("error", "codem-billingv2: invoice reason is missing")
            return
        end

        if request.target == nil then 
            request.target = request.source
        end

        local senderIdentifier, senderName = getSenderFromRequest(request)
        local creatorIdentifier = isValidPlayerSource(request.source) and Sky.FW.GetIdentifier(request.source) or nil

        local result = exports["codem-billingv2"]:CreateBillingCustom(
            request.target,
            request.amount,
            request.reason,
            true,
            senderIdentifier,
            senderName,
            creatorIdentifier
        )
        if not result then
            Sky.Debug("error", "codem-billingv2: failed to create invoice")
        end
    end
end
