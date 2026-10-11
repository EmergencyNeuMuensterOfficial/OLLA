if Sky.Config.banking ~= "jaksam" then return end
if not IsDuplicityVersion() then return end

local RESOURCE = "jobs_creator"

local function isStarted()
    return GetResourceState(RESOURCE) == "started"
end

local function normalizeAmount(amount)
    local numericAmount = math.floor(tonumber(amount) or 0)
    if numericAmount <= 0 then
        return nil
    end
    return numericAmount
end

function Sky.FW.GetSharedAccountBalance(name)
    local job_name = name:gsub("^society_", "")
    if not isStarted() then
        Sky.Debug("warn", "[banking/jaksam] jobs_creator is not started.")
        return 0
    end

    local ok, result = pcall(function()
        return exports[RESOURCE]:getJobAccountMoney(job_name)
    end)

    if not ok then
        Sky.Debug("warn", ("[banking/jaksam] getJobAccountMoney('%s') failed: %s"):format(job_name, tostring(result)))
        return 0
    end

    return tonumber(result) or 0
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    local job_name = name:gsub("^society_", "")
    local numericAmount = normalizeAmount(amount)
    if not numericAmount or not isStarted() then
        return false
    end

    local ok, result = pcall(function()
        return exports[RESOURCE]:addSocietyMoney(job_name, numericAmount)
    end)

    if not ok then
        Sky.Debug("warn", ("[banking/jaksam] addSocietyMoney('%s', %s) failed: %s"):format(job_name, tostring(numericAmount), tostring(result)))
        return false
    end

    return result ~= false
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    local job_name = name:gsub("^society_", "")
    local numericAmount = normalizeAmount(amount)
    if not numericAmount or not isStarted() then
        return false
    end

    local ok, result = pcall(function()
        return exports[RESOURCE]:removeSocietyMoney(job_name, numericAmount)
    end)

    if not ok then
        Sky.Debug("warn", ("[banking/jaksam] removeSocietyMoney('%s', %s) failed: %s"):format(job_name, tostring(numericAmount), tostring(result)))
        return false
    end

    return result ~= false
end
