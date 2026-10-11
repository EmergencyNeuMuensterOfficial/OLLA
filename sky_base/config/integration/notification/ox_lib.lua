if Sky.Config.notification ~= "ox_lib" then return end

local notificationTypes = { info = "inform", warn = "warning" }

function Sky.Functions.ShowNotification(title, message, type, time)
    exports.ox_lib:notify({
        title = title or "",
        description = message or "",
        type = notificationTypes[type] or type or "inform",
        duration = time or 5000,
    })
end
