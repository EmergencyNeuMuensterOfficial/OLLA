if Sky.Config.progressbar ~= "17mov_Hud" then return end

local Helpers = Sky._ProgressAdapter
local active

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    local finish = Helpers.Completion(cb)
    if active then
        finish(true)
        return false
    end
    local request = { cancelled = false }
    active = request
    exports["17mov_Hud"]:StartProgress({
        label = data.label, duration = data.duration,
        canCancel = data.canCancel, useWhileDead = data.useWhileDead,
        controlDisables = Helpers.Disable(data, "qb"),
        animation = Helpers.Animation(data, "qb"),
        prop = Helpers.Prop(data.prop, "qb"), propTwo = Helpers.Prop(data.propTwo, "qb"),
    }, data.onStart, data.onTick, function(cancelled)
        if active == request then active = nil end
        finish(request.cancelled or cancelled)
    end)
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    if active then
        -- The StopProgress documentation reports false to onFinish; retain our cancel intent.
        active.cancelled = true
        exports["17mov_Hud"]:StopProgress()
    end
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
