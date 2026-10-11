if Sky.Config.billing == "sky" then
    function Sky.Functions.CanIssueBill(source)
        local issuer = tonumber(source)
        if issuer and issuer >= 0 and issuer < math.huge and issuer % 1 == 0 then return true end
        Sky.Debug("warn", "Sky Billing issuer must be a player source or 0 for a system invoice")
        return false
    end

    function Sky.Functions.SendBill(source, target, bill_type, account, reason, amount, infos, options)
        local request = Sky.Billing.NormalizeRequest(source, target, bill_type, account, reason, amount, infos)
        if options then request.paymentMode = options.paymentMode end
        local result = exports["sky_jobs_base"]:SendBill(request)
        if not result.success then
            Sky.Debug("warn", "Sky Billing rejected invoice: %s", tostring(result.error))
            return false
        end
        return result.data.id
    end
end
