if Sky.Config.helpnotify ~= "sky_hud" then return end

function Sky.Functions.ShowHelpNotification(msg, key)
    exports["sky_hud"]:pressE(msg, key)
end
