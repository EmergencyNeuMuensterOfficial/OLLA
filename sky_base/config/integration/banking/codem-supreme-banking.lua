if Sky.Config.banking ~= "codem-supreme-banking" then return end
if not IsDuplicityVersion() then return end

function Sky.FW.GetSharedAccountBalance(name)
    local job_name = name:gsub("^society_", "")
    local balance = exports["codem-supreme-banking"]:GetSocietyBalance(job_name)
    if type(balance) ~= "number" then
        error(("codem-supreme-banking: society balance unavailable for '%s'"):format(job_name))
    end
    return balance
end

function Sky.FW.AddSharedAccountBalance(name, amount, options)
    local job_name = name:gsub("^society_", "")
    local reason = options and options.reason or "sky_base"
    return exports["codem-supreme-banking"]:AddSocietyMoney(job_name, amount, reason)
end

function Sky.FW.RemoveSharedAccountBalance(name, amount, options)
    local job_name = name:gsub("^society_", "")
    local reason = options and options.reason or "sky_base"
    return exports["codem-supreme-banking"]:RemoveSocietyMoney(job_name, amount, reason)
end
