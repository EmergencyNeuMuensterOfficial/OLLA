if Sky.Config.progressbar ~= "msk_core" then return end

local Helpers = Sky._ProgressAdapter

local function run(labelOrData, duration, options, callback, shape)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    data.disable = Helpers.Disable(data, "ox")
    data.animation = Helpers.Animation(data, "ox")
    data.anim = nil
    data.prop = Helpers.Prop(data.prop, "ox")
    if shape then data.type = shape end
    local finished
    if data.type == "circle" then
        finished = exports.msk_core:ProgressCircle(data)
    else
        finished = exports.msk_core:Progressbar(data)
    end
    if cb then cb(not finished) end
    return finished
end

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    return run(labelOrData, duration, options, callback)
end

function Sky.Functions.Circle(labelOrData, duration, options, callback)
    return run(labelOrData, duration, options, callback, "circle")
end

function Sky.Functions.Bar(labelOrData, duration, options, callback)
    return run(labelOrData, duration, options, callback, "bar")
end
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    exports.msk_core:ProgressStop()
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
