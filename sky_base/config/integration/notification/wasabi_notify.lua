if Sky.Config.notification ~= "wasabi_notify" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    if type == "warn" then type = "warning" end
    exports.wasabi_notify:notify(title or "", message or "", time or 5000, type or "info")
end
