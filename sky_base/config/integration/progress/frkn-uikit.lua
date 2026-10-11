if Sky.Config.progressbar ~= "frkn-uikit" then return end

local Helpers = Sky._ProgressAdapter

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    local finish = Helpers.Completion(cb)
    exports["frkn-uikit"]:Progressbar(
        data.style or "progressbar-1", data.label, data.duration,
        data.useWhileDead, data.canCancel,
        Helpers.Disable(data, "qb") or {}, Helpers.Animation(data, "qb") or {},
        Helpers.Prop(data.prop, "qb") or {}, Helpers.Prop(data.propTwo, "qb") or {},
        function() finish(false) end, function() finish(true) end
    )
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    Sky.Debug("warn", "FRKN UI Kit does not document a progress cancellation export.")
    return false
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
