if Sky.Config.billing == "esx" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        local xPlayer = ESX.GetPlayerFromId(request.source)
        local societyName = request.jobName
        local senderIdentifier = request.type == "society" and (request.account or societyName)
            or (xPlayer and xPlayer.identifier or societyName)
        local billingTarget = request.type == "society" and request.account or (senderIdentifier or "system")
        exports['esx_billing']:BillPlayer(request.target, senderIdentifier, billingTarget, request.reason, request.amount)
    end
end
