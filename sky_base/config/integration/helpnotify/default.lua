if Sky.Config.helpnotify ~= "default" then return end

local last_msg, last_key

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if last_msg == self.msg and last_key == self.key then return end
            last_msg, last_key = self.msg, self.key
            SendNUIMessage({
                sort = "showE",
                title = self.msg,
                letter = self.key,
            })
        end,
        hide = function()
            last_msg, last_key = nil, nil
            SendNUIMessage({
                sort = "hideE",
            })
        end
    })
end
