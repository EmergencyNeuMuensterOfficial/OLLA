if Sky.Config.progressbar ~= "lation_ui" then return end

local helpers = Sky._ProgressAdapter

function Sky.Functions.Progress(label_or_data, duration, options, callback)
    local data, cb = helpers.Normalize(label_or_data, duration, options, callback)
    data.disable = helpers.Disable(data, "ox")
    data.anim = helpers.Animation(data, "ox")
    data.animation = nil
    data.prop = helpers.Prop(data.prop, "ox")
    local finished = exports.lation_ui:progressBar(data)
    if cb then cb(not finished) end
    return finished
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    if exports.lation_ui:progressActive() then
        exports.lation_ui:cancelProgress()
    end
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
