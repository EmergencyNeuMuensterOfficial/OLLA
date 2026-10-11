if Sky.Config.helpnotify ~= "esx_textui" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["esx_textui"]:TextUI("[" .. self.key .. "] " .. self.msg, "info")
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["esx_textui"]:HideUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
