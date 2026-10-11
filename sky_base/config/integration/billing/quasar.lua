if Sky.Config.billing == "quasar" then
    function Sky.Functions.SendBill(source, target, bill_type, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(source, target, bill_type, account, reason, amount, infos)

        if not request.target then
            Sky.Debug("error", "qs-billing: invoice target is missing")
            return
        end

        if not request.amount or request.amount <= 0 then
            Sky.Debug("error", "qs-billing: invoice amount is invalid")
            return
        end

        if not request.reason then
            Sky.Debug("error", "qs-billing: invoice reason is missing")
            return
        end

        exports["qs-billing"]:ServerCreateInvoice(
            request.target,
            request.infos or request.jobName or Sky.FW.GetName(request.source) or "Invoice",
            request.reason,
            request.amount,
            true,
            false,
            true,
            true,
            request.type == "society" and request.jobName or nil
        )
    end
end
