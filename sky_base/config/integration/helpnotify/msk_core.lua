if Sky.Config.helpnotify ~= "msk_core" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports.msk_core:ShowTextUI({ key = self.key, text = self.msg })
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports.msk_core:HideTextUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
