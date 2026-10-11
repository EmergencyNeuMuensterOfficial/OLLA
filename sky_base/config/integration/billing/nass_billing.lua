if Sky.Config.billing == "nass_billing" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)

        exports["nass_billing"]:createInvoice(
            request.source,      -- source
            request.target,      -- target
            request.reason,      -- reason
            request.reason,      -- description
            request.amount,      -- amount
            request.type == "society", -- isBusiness
            nil                  -- customAdjustment
        )
    end
end
