if Sky.Config.helpnotify ~= "lation_ui" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports.lation_ui:showText({
                description = self.msg,
                keybind = self.key,
            })
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports.lation_ui:hideText()
            lastMessage, lastKey = nil, nil
        end
    })
end
