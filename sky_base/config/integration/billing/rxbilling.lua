if Sky.Config.billing == "rxbilling" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        local senderId = request.source
        local targetId = request.target
        if senderId == nil or senderId == 0 then
            senderId = targetId
        end

        exports['RxBilling']:SendInvoice(
            senderId,
            targetId,
            request.amount,
            request.reason,
            request.type == "society"
        )
        return true
    end
end
