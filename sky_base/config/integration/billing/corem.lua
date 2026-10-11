if Sky.Config.billing == "corem" then

    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        local senderId = request.source
        local targetId = request.target
        if targetId == nil then
            targetId = senderId
        end

        if request.type == "society" and request.jobName then
            exports["crm-billing"]:addSocietyInvoice({
                crm_id       = request.jobName,
                crm_label    = request.jobName,
                crm_receiver = targetId,
                crm_amount   = request.amount,
                crm_reason   = request.reason,
            })
        else
            exports["crm-billing"]:addPersonalInvoice(senderId, targetId, request.amount, request.reason)
        end
    end
end
