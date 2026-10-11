if Sky.Config.notification ~= "aty_uikitv2" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    title, message = title or "", message or ""
    if type == "warn" then type = "warning" end
    if type == "inform" then type = "info" end
    type = type or "info"
    exports["aty_uikitv2"]:AddNotify({ title = title, message = message, type = type, duration = time or 5000 })
end
