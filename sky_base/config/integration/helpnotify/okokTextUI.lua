if Sky.Config.helpnotify ~= "okokTextUI" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["okokTextUI"]:Open("[" .. self.key .. "] " .. self.msg, "darkblue", "left", false)
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["okokTextUI"]:Close()
            lastMessage, lastKey = nil, nil
        end
    })
end
