if Sky.Config.billing == "vms" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        local jobName = request.jobName
        local jobLabel = jobName or "Personal"
        for _, job in ipairs(Sky.FW.GetJobs() or {}) do
            if job.name == jobName then
                jobLabel = job.label or jobName
                break
            end
        end
        local firstName = request.source and Sky.FW.GetFirstname(request.source) or nil
        local lastName = request.source and Sky.FW.GetLastname(request.source) or nil
        local senderName = ((firstName or "") .. " " .. (lastName or "")):gsub("^%s+", ""):gsub("%s+$", "")
        if senderName == "" or tonumber(request.source) == tonumber(request.target) then
            senderName = jobLabel or jobName
        end

        exports['vms_cityhall']:giveBill(request.target, "invoice", {
            society = request.type == "society" and request.account or nil,
            job = jobName,
            jobLabel = jobLabel,
            issuerName = senderName,
            dateToPay = nil,
            percentageForSociety = request.type == "society" and 100 or 0,
            invoiceData = {
                {
                    qty = 1,
                    unitPrice = request.amount,
                    description = request.reason
                }
            },
            taxFromInvoice = nil
        }, false, function(fineId) end)
    end
end
