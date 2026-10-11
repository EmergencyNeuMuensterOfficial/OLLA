if Sky.Config.progressbar ~= "risk-notify" then return end

local Helpers = Sky._ProgressAdapter

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    local finish = Helpers.Completion(cb)
    local disable = Helpers.Disable(data, "ox")
    local prop = data.prop
    if type(prop) == "table" then prop = prop.model end
    local freeze = data.freeze
    if freeze == nil then freeze = disable and disable.move or false end
    exports["risk-notify"]:startProgress(data.duration, data.label, {
        prop = prop, freeze = freeze, anim = Helpers.Animation(data, "risk"),
        onFinish = function() finish(false) end,
        onCancel = function() finish(true) end,
    })
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    exports["risk-notify"]:cancelProgress()
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
