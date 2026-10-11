if Sky.Config.banking ~= "hex" then return end
if not IsDuplicityVersion() then return end

function Sky.FW.GetSharedAccountBalance(name)
    local job_name = name:gsub("^society_", "")
    local balance, reason = exports["hex_jobscreator"]:getSocietyMoney(job_name, "legal")
    if type(balance) ~= "number" then
        error(("hex_jobscreator: society balance unavailable for '%s' (%s)"):format(job_name, tostring(reason)))
    end
    return balance
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    local job_name = name:gsub("^society_", "")
    local success, reason = exports["hex_jobscreator"]:addSocietyMoney(job_name, amount, "legal")
    if not success then
        Sky.Debug("error", "hex_jobscreator: society deposit failed for '%s' (%s)", job_name, tostring(reason))
        return false, reason
    end
    return true
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    local job_name = name:gsub("^society_", "")
    local success, reason = exports["hex_jobscreator"]:removeSocietyMoney(job_name, amount, "legal")
    if not success then
        Sky.Debug("error", "hex_jobscreator: society withdrawal failed for '%s' (%s)", job_name, tostring(reason))
        return false, reason
    end
    return true
end
