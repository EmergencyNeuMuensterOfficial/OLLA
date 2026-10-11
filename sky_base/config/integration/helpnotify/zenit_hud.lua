if Sky.Config.helpnotify ~= "zenit_hud" then return end

function Sky.Functions.ShowHelpNotification(msg, key)
    exports["zenit_hud"]:showInteractionThisFrame(key, msg)
end
