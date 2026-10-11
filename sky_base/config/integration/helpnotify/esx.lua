if Sky.Config.helpnotify ~= "esx" then return end

-- Uses the framework TextUI hooks (normally backed by esx_textui).
local lastMessage, lastKey

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if lastMessage == self.msg and lastKey == self.key then return end
            local framework = ESX or exports["es_extended"]:getSharedObject()
            framework.TextUI("[" .. self.key .. "] " .. self.msg, "info")
            lastMessage, lastKey = self.msg, self.key
        end,
        hide = function()
            local framework = ESX or exports["es_extended"]:getSharedObject()
            framework.HideUI()
            lastMessage, lastKey = nil, nil
        end
    })
end
