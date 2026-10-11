if Sky.Config.billing == "fd" then
    function Sky.Functions.SendBill(src, target, billType, account, reason, amount, infos)
        local request = Sky.Billing.NormalizeRequest(src, target, billType, account, reason, amount, infos)
        if request.type ~= "society" or not request.jobName then
            Sky.Debug("error", "fd_banking: personal invoices are not supported by this adapter")
            return
        end

        local targetIdentifier = Sky.FW.GetIdentifier(request.target)

        if not targetIdentifier then
            Sky.Debug("error", "fd_banking: could not resolve target identifier for source " .. tostring(request.target))
            return
        end

        local businessAccount = exports.fd_banking:getBusinessAccount(request.jobName)
        if type(businessAccount) ~= "table" or not businessAccount.id or not businessAccount.name then
            Sky.Debug("error", "fd_banking: getBusinessAccount returned no account for job '" .. tostring(request.jobName) .. "'")
            return
        end

        exports.fd_banking:addInvoice(targetIdentifier, businessAccount.name, 1, request.amount, request.reason, businessAccount.id, false)
    end
end
