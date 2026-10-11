DRP = DRP or {}
DRP.Callbacks = {}

function DRP.RegisterCallback(name, handler)
    assert(type(name) == 'string', 'Callback name must be a string')
    assert(type(handler) == 'function', 'Callback handler must be a function')
    DRP.Callbacks[name] = handler
end

RegisterNetEvent('drp_core:server:callback', function(name, requestId, ...)
    local source = source
    local handler = DRP.Callbacks[name]
    if not handler then
        print(('[drp_core] Unknown callback requested: %s'):format(tostring(name)))
        return
    end

    handler(source, function(...)
        TriggerClientEvent('drp_core:client:callback', source, requestId, ...)
    end, ...)
end)
