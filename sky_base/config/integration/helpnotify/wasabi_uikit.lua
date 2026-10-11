if Sky.Config.helpnotify ~= "wasabi_uikit" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            if lastMessage == nil then
                exports.wasabi_uikit:OpenTextUI(self.msg, self.key)
            else
                exports.wasabi_uikit:ChangeTextUI(self.msg, self.key)
            end
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports.wasabi_uikit:CloseTextUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
