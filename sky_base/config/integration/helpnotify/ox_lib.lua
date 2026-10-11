if Sky.Config.helpnotify ~= "ox_lib" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports.ox_lib:showTextUI("[" .. self.key .. "] " .. self.msg)
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports.ox_lib:hideTextUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
