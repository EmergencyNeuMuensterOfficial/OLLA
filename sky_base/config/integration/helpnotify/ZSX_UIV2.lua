local provider = Sky.Config.helpnotify
if provider ~= "ZSX_UIV2" and provider ~= "ZSX_UIV2_help" then return end

local last_message, last_key, serial

local function hide_hint()
    if provider == "ZSX_UIV2" then
        exports["ZSX_UIV2"]:TextUI_Remove(serial, false)
        serial = nil
    else
        exports["ZSX_UIV2"]:HelpNotification_Remove()
    end
    last_message, last_key = nil, nil
end

function Sky.Functions.ShowHelpNotification(msg, key)
    Sky.Show.RegisterToggle("helpNotify", {
        key = key or "E",
        msg = msg or "",
        show = function(self)
            if last_message == self.msg and last_key == self.key then return end
            if provider == "ZSX_UIV2" then
                if serial then exports["ZSX_UIV2"]:TextUI_Remove(serial, false) end
                serial = exports["ZSX_UIV2"]:TextUI(self.key, self.msg)
            else
                exports["ZSX_UIV2"]:HelpNotification({
                    icon = "fas fa-info-circle", header = "[" .. self.key .. "]", text = self.msg,
                })
            end
            last_message, last_key = self.msg, self.key
        end,
        hide = hide_hint,
    })
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() and last_message ~= nil then hide_hint() end
end)
