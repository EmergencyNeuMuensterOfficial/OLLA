if Sky.Config.voice ~= "pma" then return end

local RESOURCE = "pma-voice"
local volume = 1.0

local function channelNumber(channel_id)
    local numeric_channel = tonumber(channel_id)
    if numeric_channel and numeric_channel > 0 then
        return math.floor(numeric_channel)
    end
    return (math.abs(joaat(tostring(channel_id))) % 999999) + 1
end

if IsDuplicityVersion() then
    function Sky.Voice.SetRadio(source, channel_id)
        exports[RESOURCE]:setPlayerRadio(source, channelNumber(channel_id))
        return true
    end

    function Sky.Voice.RemoveRadio(source)
        exports[RESOURCE]:setPlayerRadio(source, 0)
        return true
    end

    function Sky.Voice.GetPlayersInChannel(channel_id)
        local channel = channelNumber(channel_id)
        local players = {}
        for _, source in ipairs(GetPlayers()) do
            source = tonumber(source)
            if Player(source).state.radioChannel == channel then
                players[#players + 1] = source
            end
        end
        return players
    end
else
    local function providerReady()
        return GetResourceState(RESOURCE) == "started"
    end

    function Sky.Voice._ApplyProximityOverride(range, options)
        if not providerReady() then
            return false, "provider_unavailable"
        end
        local apply_attempted = false
        local ok, provider_error = pcall(function()
            apply_attempted = true
            exports[RESOURCE]:overrideProximityRange(
                range,
                options.lockUserControl ~= false
            )
        end)
        if not ok then
            local rollback_ok = false
            local rollback_error = nil
            if apply_attempted and providerReady() then
                rollback_ok, rollback_error = pcall(function()
                    exports[RESOURCE]:clearProximityOverride()
                end)
            end
            Sky.Debug("error", "[sky_base][voice] pma proximity override failed: " .. tostring(provider_error))
            if apply_attempted and not rollback_ok then
                Sky.Debug(
                    "error",
                    "[sky_base][voice] pma proximity rollback failed: "
                        .. tostring(rollback_error or "provider unavailable")
                )
            end
            return false, "provider_error"
        end
        return true
    end

    function Sky.Voice._ClearProximityOverride()
        if not providerReady() then
            return false, "provider_unavailable"
        end
        local ok, provider_error = pcall(function()
            exports[RESOURCE]:clearProximityOverride()
        end)
        if not ok then
            Sky.Debug("error", "[sky_base][voice] pma proximity reset failed: " .. tostring(provider_error))
            return false, "provider_error"
        end
        return true
    end

    AddEventHandler("onClientResourceStop", function(resource_name)
        if resource_name == RESOURCE then
            Sky.Voice._InvalidateProximityOverride("provider_unavailable")
        end
    end)

    AddEventHandler("pma-voice:radioActive", function(active)
        TriggerEvent("sky_base:voice:radioActive", active == true)
    end)

    RegisterNetEvent("pma-voice:setTalkingOnRadio", function(source, active)
        source = tonumber(source)
        if source == GetPlayerServerId(PlayerId()) then return end
        TriggerEvent("sky_base:voice:radioPeerActive", source, active == true)
    end)

    function Sky.Voice.SetRadioChannel(channel_id)
        exports[RESOURCE]:setVoiceProperty("micClicks", Sky.Config.voiceRadioSounds.enabled)
        exports[RESOURCE]:setMicClickOnVolume(Sky.Config.voiceRadioSounds.transmitStartVolume)
        exports[RESOURCE]:setMicClickOffVolume(Sky.Config.voiceRadioSounds.transmitEndVolume)
        exports[RESOURCE]:setRadioChannel(channelNumber(channel_id))
        return true
    end

    function Sky.Voice.GetRadioVolume()
        return volume
    end

    function Sky.Voice.SetRadioVolume(value)
        volume = math.max(0.0, math.min(1.0, tonumber(value) or 1.0))
        exports[RESOURCE]:setRadioVolume(math.floor(volume * 100 + 0.5))
        return true
    end
end

function Sky.Voice.GetCapabilities()
    return {
        provider = "pma",
        volume = true,
        multiChannel = false,
        radioActivity = true,
        proximityOverride = true,
        playerProximityOverride = false,
    }
end
