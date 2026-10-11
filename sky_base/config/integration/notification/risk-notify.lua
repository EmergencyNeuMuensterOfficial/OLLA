if Sky.Config.notification ~= "risk-notify" then return end

local types = { warn = "info", warning = "info", inform = "info" }

function Sky.Functions.ShowNotification(title, message, type, time)
    title, message = title or "", message or ""
    type = types[type] or type or "info"
    exports["risk-notify"]:Notify({ title = title, message = message, type = type, duration = time or 5000 })
end
