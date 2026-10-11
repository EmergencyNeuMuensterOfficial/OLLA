if Sky.Config.billing == "jacksam" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        local senderIdentifier = request.source and Sky.FW.GetIdentifier(request.source) or nil
        local targetIdentifier = Sky.FW.GetIdentifier(request.target)
        local billAccount = request.type == "society" and request.account or (senderIdentifier or "system")

        exports["billing_ui"]:createBill(
            senderIdentifier or targetIdentifier,
            targetIdentifier,
            request.reason,
            request.amount,
            billAccount,
            request.type == "society" and "society" or "player"
        )
    end
end
