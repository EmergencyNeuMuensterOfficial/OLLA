if Sky.Config.notification ~= "qbox" then return end

local notificationTypes = { info = "inform", warn = "warning" }

function Sky.Functions.ShowNotification(title, message, type, time)
    exports.qbx_core:Notify({
        text = title or "",
        caption = message or "",
    }, notificationTypes[type] or type or "inform", time or 5000)
end
