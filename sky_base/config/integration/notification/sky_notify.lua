if Sky.Config.notification ~= "sky_notify" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    exports["sky_notify"]:show(title, message, type, time)
end
