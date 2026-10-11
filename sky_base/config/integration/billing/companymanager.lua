if Sky.Config.billing == "companymanager" then
    function Sky.Functions.SendBill(src, target, billType, account, description, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, description, amount, infos)
        if not request.target then
            return
        end
        if not request.amount or request.amount <= 0 then
            return
        end
        if not request.reason then
            return
        end
        local from = {
            label = request.type == "society" and (request.jobName or request.account or "unknown") or (Sky.FW.GetName(request.source) or "unknown"),
            job = request.type == "society" and (request.jobName or request.account or "unknown") or "personal",
            identifier = request.type == "society"
                and tostring(request.account or request.source or "unknown")
                or tostring((request.source and Sky.FW.GetIdentifier(request.source)) or request.source or "unknown"),
        }
        pcall(function()
            exports['bcs_companymanager']:CreateBill(
                request.source,
                request.target,
                request.amount,
                request.reason,
                nil,
                from
            )
        end)
    end
end
