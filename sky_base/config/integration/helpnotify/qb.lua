if Sky.Config.helpnotify ~= "qb" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            local text = "[" .. self.key .. "] " .. self.msg
            if lastMessage == nil then
                exports["qb-core"]:DrawText(text, "left")
            else
                exports["qb-core"]:ChangeText(text, "left")
            end
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["qb-core"]:HideText()
            lastMessage, lastKey = nil, nil
        end
    })
end
