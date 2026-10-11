if Sky.Config.notification ~= "brutal_notify" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    title, message = title or "", message or ""
    if type == "warn" then type = "warning" end
    if type == "inform" then type = "info" end
    type = type or "info"
    exports["brutal_notify"]:SendAlert(title, message, time or 5000, type, true)
end
