if Sky.Config.progressbar == "jaksam" then
    local jaksamProgressbarEvents = {
        ["robberies_creator"] = "robberies_creator:startProgressBar",
        ["jobs_creator"] = "jobs_creator:startProgressBar",
        ["drugs_creator"] = "drugs_creator:startProgressBar",
    }

    local function getJaksamProgressbarEvent()
        for resource, event in pairs(jaksamProgressbarEvents) do
            if GetResourceState(resource) == "started" then
                return event
            end
        end
    end

    local function normalizeProgressData(labelOrData, duration, options, cb)
        if type(labelOrData) == "table" then
            local data = labelOrData
            return data.duration or data.length or 5000,
                data.label or data.text or data.name or "Progress",
                data.hexColor or data.color,
                duration
        end

        if type(options) == "function"
            or (type(options) == "table" and rawget(options, "__cfx_functionReference") ~= nil) then
            cb = options
            options = {}
        end

        options = options or {}

        return duration or 5000, labelOrData or "Progress", options.hexColor or options.color, cb
    end

    function Sky.Functions.Progress(labelOrData, duration, options, cb)
        local ms, text, hexColor, callback = normalizeProgressData(labelOrData, duration, options, cb)
        local event = getJaksamProgressbarEvent()

        if not event then
            Sky.Debug("error", "Sky.Config.progressbar is set to jaksam but no supported Jaksam Creator resource is started.")
            if callback then callback(true) end
            return false
        end

        TriggerEvent(event, ms, text, hexColor)

        if callback then
            CreateThread(function()
                Wait(ms)
                callback(false)
            end)
        end

        return true
    end

    function Sky.Functions.Bar(...)
        return Sky.Functions.Progress(...)
    end

    Sky.Functions.ProgressBar = Sky.Functions.Progress

    function Sky.Functions.CancelProgress()
        Sky.Debug("warn", "Jaksam Creator progressbar does not provide a documented cancel event.")
    end

    Sky.Functions.CancelBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
end
