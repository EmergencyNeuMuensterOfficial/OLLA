if Sky.Config.progressbar == "ox" then
    local function convertDisable(disable)
        if not disable then return nil end

        return {
            move = disable.move or disable.disableMovement or false,
            car = disable.car or disable.disableCarMovement or false,
            mouse = disable.mouse or disable.disableMouse or false,
            combat = disable.combat or disable.disableCombat or false,
            sprint = disable.sprint or false,
        }
    end

    local function normalizeAnimationString(value)
        if type(value) ~= "string" then return nil end
        value = value:match("^%s*(.-)%s*$")
        return value ~= "" and value or nil
    end

    local function convertAnimation(animation)
        if not animation then return nil end

        local scenario = normalizeAnimationString(animation.scenario) or normalizeAnimationString(animation.task)
        if scenario then
            return {
                scenario = scenario,
                duration = animation.duration,
                playEnter = animation.playEnter,
            }
        end

        local dict = normalizeAnimationString(animation.dict) or normalizeAnimationString(animation.animDict)
        local clip = normalizeAnimationString(animation.clip)
            or normalizeAnimationString(animation.anim)
            or normalizeAnimationString(animation.lib)

        if not dict or not clip then return nil end

        return {
            dict = dict,
            clip = clip,
            flag = animation.flag or animation.flags,
            blendIn = animation.blendIn,
            blendOut = animation.blendOut,
            duration = animation.duration,
            playbackRate = animation.playbackRate,
            lockX = animation.lockX,
            lockY = animation.lockY,
            lockZ = animation.lockZ,
            playEnter = animation.playEnter,
        }
    end

    local function normalizeProgressData(labelOrData, duration, options, cb)
        if type(labelOrData) == "table" then
            local data = labelOrData
            data.label = data.label or data.text or "Progress"
            data.duration = data.duration or data.length or 5000
            data.canCancel = data.canCancel ~= false
            data.disable = convertDisable(data.disable or data.controlDisables)
            data.anim = convertAnimation(data.anim or data.animation)
            return data, duration
        end

        if type(options) == "function"
            or (type(options) == "table" and rawget(options, "__cfx_functionReference") ~= nil) then
            cb = options
            options = {}
        end

        local data = options or {}
        data.label = data.label or labelOrData or "Progress"
        data.duration = data.duration or duration or 5000
        data.canCancel = data.canCancel ~= false
        data.disable = convertDisable(data.disable or data.controlDisables)
        data.anim = convertAnimation(data.anim or data.animation)

        return data, cb
    end

    function Sky.Functions.Progress(labelOrData, duration, options, cb)
        local data, callback = normalizeProgressData(labelOrData, duration, options, cb)
        local finished = exports.ox_lib:progressBar(data)

        if callback then callback(not finished) end
        return finished
    end

    function Sky.Functions.Bar(...)
        return Sky.Functions.Progress(...)
    end

    Sky.Functions.ProgressBar = Sky.Functions.Progress

    function Sky.Functions.CancelProgress()
        if exports.ox_lib:progressActive() then
            exports.ox_lib:cancelProgress()
        end
    end

    Sky.Functions.CancelBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
end
