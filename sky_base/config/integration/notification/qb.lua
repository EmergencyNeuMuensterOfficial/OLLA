if Sky.Config.notification ~= "qb" then return end

local notificationTypes = { info = "primary", inform = "primary", warn = "warning" }

function Sky.Functions.ShowNotification(title, message, type, time)
    local framework = QBCore or exports["qb-core"]:GetCoreObject()
    framework.Functions.Notify({
        text = title or "",
        caption = message or "",
    }, notificationTypes[type] or type or "primary", time or 5000)
end
