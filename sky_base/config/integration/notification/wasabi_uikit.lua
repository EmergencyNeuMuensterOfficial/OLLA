if Sky.Config.notification ~= "wasabi_uikit" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    if type == "warn" then type = "warning" end
    exports.wasabi_uikit:Notification(title or "", message or "", type or "info", time or 5000)
end
