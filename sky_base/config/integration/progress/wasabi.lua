if Sky.Config.progressbar == "wasabi" then
    local function convertDisable(disable)
        if not disable then return nil end

        return {
            move = disable.move or disable.disableMovement or false,
            car = disable.car or disable.disableCarMovement or false,
            combat = disable.combat or disable.disableCombat or false,
            mouse = disable.mouse or disable.disableMouse or false,
        }
    end

    local function convertAnimation(animation)
        if not animation then return nil end
        if animation.dict and animation.clip then return animation end

        return {
            dict = animation.dict or animation.animDict,
            clip = animation.clip or animation.anim or animation.lib,
        }
    end

    local function normalizeProgressData(labelOrData, duration, options, cb)
        if type(labelOrData) == "table" then
            local data = labelOrData
            data.label = data.label or data.text or "Progress"
            data.duration = data.duration or data.length or 5000
            data.disable = convertDisable(data.disable or data.controlDisables)
            data.anim = convertAnimation(data.anim or data.animation)

            return data, data.type or "bar", duration
        end

        if type(options) == "function"
            or (type(options) == "table" and rawget(options, "__cfx_functionReference") ~= nil) then
            cb = options
            options = {}
        end

        local data = options or {}
        data.label = data.label or labelOrData or "Progress"
        data.duration = data.duration or duration or 5000
        data.disable = convertDisable(data.disable or data.controlDisables)
        data.anim = convertAnimation(data.anim or data.animation)

        return data, data.type or "bar", cb
    end

    function Sky.Functions.Progress(labelOrData, duration, options, cb)
        local data, progressType, callback = normalizeProgressData(labelOrData, duration, options, cb)
        local finished = exports.wasabi_uikit:ProgressBar(data, progressType)

        if callback then callback(not finished) end
        return finished
    end

    function Sky.Functions.Bar(labelOrData, duration, options, cb)
        local data, _, callback = normalizeProgressData(labelOrData, duration, options, cb)
        data.type = "bar"

        return Sky.Functions.Progress(data, callback)
    end

    function Sky.Functions.Circle(labelOrData, duration, options, cb)
        local data, _, callback = normalizeProgressData(labelOrData, duration, options, cb)
        data.type = "circle"

        return Sky.Functions.Progress(data, callback)
    end

    Sky.Functions.ProgressBar = Sky.Functions.Progress

    function Sky.Functions.CancelProgress()
        Sky.Debug("warn", "Wasabi UI Kit progressbar does not provide a documented cancel export.")
    end

    Sky.Functions.CancelBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
end
