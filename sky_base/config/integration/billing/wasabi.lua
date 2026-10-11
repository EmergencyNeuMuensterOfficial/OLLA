if Sky.Config.billing == "wasabi" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        if type(request.source) ~= "number" or request.source <= 0 then
            Sky.Debug("error", "wasabi_billing requires a player source as invoice author")
            return false
        end

        local targetIdentifier = Sky.FW.GetIdentifier(request.target)
        if not targetIdentifier then
            Sky.Debug("error", "wasabi_billing could not resolve the invoice recipient identifier")
            return false
        end

        if not request.amount or request.amount <= 0 then
            Sky.Debug("error", "wasabi_billing invoice amount is invalid")
            return false
        end

        if not request.reason then
            Sky.Debug("error", "wasabi_billing invoice reason is missing")
            return false
        end

        -- Wasabi derives the sending society from the author's current framework job.
        -- Its CreateInvoice export has no argument for request.account.
        local createdReferenceId = exports.wasabi_billing:CreateInvoice(
            request.source,
            targetIdentifier,
            request.amount,
            request.reason,
            request.type == "society" and "society" or "personal",
            "personal"
        )

        if not createdReferenceId then
            Sky.Debug("error", "failed to create invoice with wasabi_billing")
            return false
        end

        return createdReferenceId
    end
end
