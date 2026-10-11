if Sky.Config.progressbar == "hex" then
    local hexProgressbarResources = {
        "hex_4_hud",
        "hex_2_hud",
        "hex_final_hud",
        "hex_finalhud_v2",
        "hex_future_hud",
        "hex_genesis_hud",
        "hex_hud_prem",
    }

    local function getHexProgressbarResource()
        for _, resource in ipairs(hexProgressbarResources) do
            if GetResourceState(resource) == "started" then
                return resource
            end
        end
    end

    local function normalizeProgressData(labelOrData, duration, options, cb)
        if type(labelOrData) == "table" then
            local data = labelOrData
            return data.duration or data.length or 5000, data.label or data.text or data.name or "Progress", duration
        end

        if type(options) == "function"
            or (type(options) == "table" and rawget(options, "__cfx_functionReference") ~= nil) then
            cb = options
        end

        return duration or 5000, labelOrData or "Progress", cb
    end

    function Sky.Functions.Progress(labelOrData, duration, options, cb)
        local ms, name, callback = normalizeProgressData(labelOrData, duration, options, cb)
        local resource = getHexProgressbarResource()

        if not resource then
            Sky.Debug("error", "Sky.Config.progressbar is set to hex but no supported HEX HUD resource is started.")
            if callback then callback(true) end
            return false
        end

        exports[resource]:StartProgressbar(ms, name)

        if callback then
            CreateThread(function()
                Wait(ms)
                callback(false)
            end)
        end

        return true
    end

    function Sky.Functions.Bar(...)
        return Sky.Functions.Progress(...)
    end

    Sky.Functions.ProgressBar = Sky.Functions.Progress

    function Sky.Functions.CancelProgress()
        local resource = getHexProgressbarResource()

        if not resource then
            Sky.Debug("error", "Sky.Config.progressbar is set to hex but no supported HEX HUD resource is started.")
            return
        end

        exports[resource]:StopProgressbar()
    end

    Sky.Functions.CancelBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
end
