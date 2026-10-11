if Sky.Config.progressbar ~= "ZSX_UIV2" then return end

local Helpers = Sky._ProgressAdapter
local active

function Sky.Functions.Progress(labelOrData, duration, options, callback)
    local data, cb = Helpers.Normalize(labelOrData, duration, options, callback)
    local finish = Helpers.Completion(cb)
    if active then
        Sky.Debug("warn", "[ZSX UI V2] Progress rejected: a Sky progress request is still active.")
        finish(true)
        return false
    end
    local request = { cancelled = false }
    active = request
    local disable = Helpers.Disable(data, "ox")
    exports["ZSX_UIV2"]:ProgressBar(
        data.icon or "fas fa-wrench", data.label, data.duration,
        function()
            if active == request then active = nil end
            finish(request.cancelled)
        end,
        function()
            if active == request then active = nil end
            finish(true)
        end,
        data.canCancel,
        disable and { disable_walk = disable.move, disable_driving = disable.car,
            disable_mouse = disable.mouse, disable_combat = disable.combat },
        Helpers.Animation(data, "ox"), Helpers.Prop(data.prop, "ox"), Helpers.Prop(data.propTwo, "ox")
    )
end

Sky.Functions.Bar = Sky.Functions.Progress
Sky.Functions.ProgressBar = Sky.Functions.Progress

function Sky.Functions.CancelProgress()
    if not active then return false end
    active.cancelled = true
    Sky.Debug("warn", "[ZSX UI V2] Programmatic progress cancellation has no documented export; use the provider's player cancel control.")
    return false
end

Sky.Functions.CancelBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
