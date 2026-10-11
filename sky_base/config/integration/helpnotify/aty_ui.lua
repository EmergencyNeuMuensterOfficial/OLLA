if Sky.Config.helpnotify ~= "aty_ui" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports["aty_ui"]:GetAtyUI().openTextUi(self.key, "", self.msg, "blue")
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports["aty_ui"]:GetAtyUI().closeTextUi()
            lastMessage, lastKey = nil, nil
        end
    })
end
