if Sky.Config.progressbar == "mythic" then
    local function normalizeProgressData(labelOrData, duration, options, cb)
        if type(labelOrData) == "table" then
            local data = labelOrData
            data.name = data.name or "sky_progress"
            data.label = data.label or data.text or "Progress"
            data.duration = data.duration or data.length or 5000
            data.canCancel = data.canCancel ~= false
            data.useWhileDead = data.useWhileDead or false
            data.controlDisables = data.controlDisables or data.disable or {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }
            return data, duration
        end

        if type(options) == "function"
            or (type(options) == "table" and rawget(options, "__cfx_functionReference") ~= nil) then
            cb = options
            options = {}
        end

        local data = options or {}
        data.name = data.name or "sky_progress"
        data.label = data.label or labelOrData or "Progress"
        data.duration = data.duration or duration or 5000
        data.canCancel = data.canCancel ~= false
        data.useWhileDead = data.useWhileDead or false
        data.controlDisables = data.controlDisables or data.disable or {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }

        return data, cb
    end

    function Sky.Functions.Progress(labelOrData, duration, options, cb)
        local data, callback = normalizeProgressData(labelOrData, duration, options, cb)

        exports["mythic_progbar"]:Progress(data, function(cancelled)
            if callback then callback(cancelled) end
        end)
    end

    function Sky.Functions.Bar(...)
        return Sky.Functions.Progress(...)
    end

    Sky.Functions.ProgressBar = Sky.Functions.Progress

    function Sky.Functions.CancelProgress()
        TriggerEvent("mythic_progbar:client:cancel")
    end

    Sky.Functions.CancelBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
end
