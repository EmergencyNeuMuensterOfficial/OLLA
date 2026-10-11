if Sky.Config.helpnotify ~= "17mov_Hud" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["17mov_Hud"]:ShowHelpNotification("[" .. self.key .. "] " .. self.msg)
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["17mov_Hud"]:HideHelpNotification()
            lastMessage, lastKey = nil, nil
        end
    })
end
