if Sky.Config.helpnotify ~= "custom" then return end

-- Implement both callbacks below, then set Config.helpnotify = "custom".
local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            -- Replace with your persistent UI's show/update export.
            -- self.msg is the description; self.key is the displayed key.
            error("Custom help notification integration: show is not implemented")
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            -- Replace with your UI's hide export.
            error("Custom help notification integration: hide is not implemented")
            lastMessage, lastKey = nil, nil
        end
    })
end
