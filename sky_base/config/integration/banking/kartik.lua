if Sky.Config.banking == "kartik" then
    if not IsDuplicityVersion() then return end

    local RESOURCE = "kartik-banking"

    local function resolveJobLabel(name)
        if Sky.FW.GetJobs then
            local ok, jobs = pcall(Sky.FW.GetJobs)
            if ok and type(jobs) == "table" and jobs[name] and jobs[name].label then
                return jobs[name].label
            end
        end

        return name
    end

    local function ensureAccount(name)
        if GetResourceState(RESOURCE) ~= "started" then
            Sky.Debug("warn", "[banking/kartik] kartik-banking is not started.")
            return false
        end

        local ok, balance = pcall(function()
            return exports[RESOURCE]:GetAccountMoney(name)
        end)
        if not ok then
            Sky.Debug("warn", ("[banking/kartik] GetAccountMoney('%s') failed: %s"):format(name, tostring(balance)))
            return false
        end
        if balance ~= nil then
            return true, balance
        end

        local created = false
        local createOk, err = pcall(function()
            created = exports[RESOURCE]:CreateJobAccount({
                name = name,
                label = resolveJobLabel(name),
                bankType = "fleeca"
            }, 0)
        end)

        if createOk and created then
            Sky.Debug("info", ("[banking/kartik] account '%s' created"):format(name))
            return true, 0
        elseif createOk then
            Sky.Debug("warn", ("[banking/kartik] CreateJobAccount('%s') returned false"):format(name))
        else
            Sky.Debug("warn", ("[banking/kartik] CreateJobAccount('%s') failed: %s"):format(name, tostring(err)))
        end
        return false
    end

    function Sky.FW.GetSharedAccountBalance(name)
        local ok, balance = ensureAccount(name)
        if not ok then
            error(("[banking/kartik] Could not read job account '%s'."):format(name))
        end
        return balance
    end

    function Sky.FW.AddSharedAccountBalance(name, amount)
        if not ensureAccount(name) then return false end
        return exports[RESOURCE]:AddAccountMoney(name, amount, "sky_base")
    end

    function Sky.FW.RemoveSharedAccountBalance(name, amount)
        if not ensureAccount(name) then return false end
        return exports[RESOURCE]:RemoveAccountMoney(name, amount, "sky_base")
    end
end
