if Sky.Config.helpnotify ~= "prims_hud" then return end

local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            exports.prims_hud:prims_keybind_show({ key = self.key, title = self.msg, description = "" })
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            exports.prims_hud:prims_keybind_hide()
            lastMessage, lastKey = nil, nil
        end
    })
end
