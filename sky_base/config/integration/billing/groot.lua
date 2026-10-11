if Sky.Config.billing == "groot" then
    if not IsDuplicityVersion() then return end

    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        local targetIdentifier = Sky.FW.GetIdentifier(request.target)
        local issuerIdentifier = request.source and Sky.FW.GetIdentifier(request.source) or nil

        if not targetIdentifier then
            Sky.Debug("error", "g-billing: could not resolve target identifier for source " .. tostring(request.target))
            return
        end

        local data = {
            amount             = request.amount,
            target_identifier  = targetIdentifier,
            target_name        = Sky.FW.GetName(request.target),
            issuer_identifier  = issuerIdentifier or request.jobName or "system",
            issuer_name        = (request.source and Sky.FW.GetName(request.source)) or request.jobName or "System",
            society            = request.type == "society" and request.jobName or nil,
            reason             = request.reason,
            status             = "unpaid",
            type               = request.type == "society" and "personal_to_society" or "personal",
            due_date           = os.date("%Y-%m-%d", os.time() + 7 * 24 * 60 * 60),
            items              = { { label = request.reason, price = request.amount, quantity = 1 } },
        }

        local ok, invoice, err = pcall(function()
            return exports["g-billing"]:CreateInvoice(data)
        end)

        if not ok then
            Sky.Debug("error", "g-billing: CreateInvoice threw an error: " .. tostring(invoice))
        elseif err then
            Sky.Debug("error", "g-billing: CreateInvoice returned errorCode " .. tostring(err))
        end
    end
end
