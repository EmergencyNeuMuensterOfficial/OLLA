if Sky.Config.helpnotify ~= "jg-textui" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["jg-textui"]:DrawText("[" .. self.key .. "] " .. self.msg)
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["jg-textui"]:HideText()
            lastMessage, lastKey = nil, nil
        end
    })
end
