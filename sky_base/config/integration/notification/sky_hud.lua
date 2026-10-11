if Sky.Config.notification ~= "sky_hud" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    exports["sky_hud"]:notify(title, message, type, time)
end
