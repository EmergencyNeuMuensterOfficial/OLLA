if Sky.Config.helpnotify ~= "risk-notify" then return end

-- Risk's temporary prompt has no separate hide export.
function Sky.Functions.ShowHelpNotification(msg, key)
    exports["risk-notify"]:HelpNotify(key or "E", msg or "")
end
