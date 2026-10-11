if Sky.Config.progressbar ~= "prism_uipack" then return end

local Helpers = Sky._ProgressAdapter

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    data.disable = Helpers.Disable(data, "ox")
    data.anim = Helpers.Animation(data, "ox")
    data.animation = nil
    data.prop = Helpers.Prop(data.prop, "ox")
    local finished = exports["prism_uipack"]:ProgressBar(data)
    if cb then cb(not finished) end
    return finished
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    if exports["prism_uipack"]:ProgressActive() then
        exports["prism_uipack"]:CancelProgress()
    end
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
