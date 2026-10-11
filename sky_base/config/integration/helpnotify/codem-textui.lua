if Sky.Config.helpnotify ~= "codem-textui" then return end

local theme = "thema-1" -- Change this to the desired installed mTextUI theme.
local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["codem-textui"]:OpenTextUI(self.msg, self.key, theme)
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["codem-textui"]:CloseTextUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
