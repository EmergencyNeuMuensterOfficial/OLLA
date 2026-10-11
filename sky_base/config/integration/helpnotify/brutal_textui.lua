if Sky.Config.helpnotify ~= "brutal_textui" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["brutal_textui"]:Open("[" .. self.key .. "] " .. self.msg, "blue", 1, "left")
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["brutal_textui"]:Close()
            lastMessage, lastKey = nil, nil
        end
    })
end
