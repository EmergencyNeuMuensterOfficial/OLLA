if Sky.Config.progressbar ~= "aty_uikitv2" then return end

local Helpers = Sky._ProgressAdapter

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    local finish = Helpers.Completion(cb)
    exports["aty_uikitv2"]:StartProgress({
        name = data.name, label = data.label, message = data.message or "",
        duration = data.duration, icon = data.icon,
        canCancel = data.canCancel, useWhileDead = data.useWhileDead,
        controlDisables = Helpers.Disable(data, "qb"),
        anim = Helpers.Animation(data, "aty"), prop = Helpers.Prop(data.prop, "ox"),
    }, function(success) finish(not success) end)
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    Sky.Debug("warn", "ATY UI Kit v2 does not document a progress cancellation export.")
    return false
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
