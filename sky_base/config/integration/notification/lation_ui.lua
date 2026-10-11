if Sky.Config.notification ~= "lation_ui" then return end

function Sky.Functions.ShowNotification(title, message, type, time)
    if type == "warn" then type = "warning" end
    exports.lation_ui:notify({
        title = title or "",
        message = message or "",
        type = type or "info",
        duration = time or 5000,
    })
end
