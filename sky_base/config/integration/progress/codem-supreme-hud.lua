if Sky.Config.progressbar ~= "codem-supreme-hud" then return end

local Helpers = Sky._ProgressAdapter

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    local finish = Helpers.Completion(cb)
    if exports["codem-supreme-hud"]:isDoingSomething() then
        finish(true)
        return false
    end
    exports["codem-supreme-hud"]:Progress({
        label = data.label, duration = data.duration,
        icon = data.icon, color = data.color, canCancel = data.canCancel,
    }, function() finish(false) end, function() finish(true) end)
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    exports["codem-supreme-hud"]:CancelProgress()
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
