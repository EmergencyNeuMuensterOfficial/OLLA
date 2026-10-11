local requestCounter = 0
local pending = {}

RegisterNetEvent("german-multichar:client:response", function(requestId, result)
    -- A pending request is deliberately initialised as `false`, so checking its
    -- truthiness discarded every server response and caused the UI timeout.
    if pending[requestId] ~= nil then pending[requestId] = result end
end)

local function requestServer(eventName, payload)
    requestCounter = requestCounter + 1
    local requestId = requestCounter
    pending[requestId] = false
    TriggerServerEvent(eventName, requestId, payload)
    local timeout = GetGameTimer() + 10000
    while pending[requestId] == false and GetGameTimer() < timeout do Wait(25) end
    local result = pending[requestId]
    pending[requestId] = nil
    return result or { ok = false, error = "Server-Timeout." }
end

RegisterNUICallback("load", function(_, callback)
    callback(requestServer("german-multichar:server:list"))
end)

RegisterNUICallback("create", function(data, callback)
    callback(requestServer("german-multichar:server:create", data))
end)

RegisterNUICallback("select", function(data, callback)
    -- FiveM preserves client-to-server event ordering. Save the currently
    -- played identity before the server activates the selected slot.
    TriggerEvent('german-multichar:client:savePosition')
    Wait(0)
    callback(requestServer("german-multichar:server:select", data.slot))
end)

RegisterNUICallback("close", function(_, callback)
    SetNuiFocus(false, false)
    TriggerEvent("german-multichar:client:closed")
    callback({ ok = true })
end)
