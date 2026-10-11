if Sky.Config.helpnotify ~= "codem-supreme-hud" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["codem-supreme-hud"]:ShowTextUI(self.msg, { key = self.key })
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["codem-supreme-hud"]:HideTextUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
