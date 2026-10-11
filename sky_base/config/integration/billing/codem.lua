if Sky.Config.billing == "codem" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        if request.target == nil then 
            request.target = request.source
        end
    
        exports['codem-billing']:createBilling(
            request.source,
            request.target,
            request.amount,
            request.reason,
            request.type == "society" and request.account or nil
        )
    end
end
