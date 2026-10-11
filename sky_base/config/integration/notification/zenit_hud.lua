if Sky.Config.notification ~= "zenit_hud" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    exports["zenit_hud"]:showNotify(title, message, type, time)
end
