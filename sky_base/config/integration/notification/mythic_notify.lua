if Sky.Config.notification ~= "mythic_notify" then return end

-- Mythic's documented styles are inform, success and error.
local notificationTypes = { info = "inform", warning = "inform", warn = "inform" }

function Sky.Functions.ShowNotification(title, message, type, time)
    local text = message or ""
    if title and title ~= "" then
        text = title .. (text ~= "" and (": " .. text) or "")
    end
    exports["mythic_notify"]:DoCustomHudText(notificationTypes[type] or type or "inform", text, time or 5000)
end
