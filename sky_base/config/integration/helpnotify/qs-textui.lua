if Sky.Config.helpnotify ~= "qs-textui" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            local text = "[" .. self.key .. "] " .. self.msg
            if lastMessage == nil then
                exports["qs-textui"]:displayTextUI(text, "left")
            else
                exports["qs-textui"]:changeText(text, "left")
            end
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["qs-textui"]:hideTextUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
