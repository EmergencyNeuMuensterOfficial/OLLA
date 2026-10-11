---@diagnostic disable: duplicate-set-field
if IsDuplicityVersion() then return end
if Sky.Config.target ~= "ox" then return end

Sky.Target = Sky.Target or {}

function Sky.Target.AddLocalEntity(entity, options)
    exports.ox_target:addLocalEntity(entity, options)
end

function Sky.Target.RemoveLocalEntity(entity, optionNames)
    exports.ox_target:removeLocalEntity(entity, optionNames)
end

function Sky.Target.AddSphereZone(params)
    return exports.ox_target:addSphereZone({
        coords = params.coords,
        radius = params.radius,
        debug = params.debug == true,
        drawSprite = params.drawSprite == true,
        options = params.options,
    })
end

function Sky.Target.RemoveZone(handle)
    exports.ox_target:removeZone(handle)
end

function Sky.Target.AddGlobalPlayer(options)
    exports.ox_target:addGlobalPlayer(options)
end

function Sky.Target.RemoveGlobalPlayer(optionNames)
    exports.ox_target:removeGlobalPlayer(optionNames)
end

function Sky.Target.AddGlobalVehicle(options)
    exports.ox_target:addGlobalVehicle(options)
end

function Sky.Target.RemoveGlobalVehicle(optionNames)
    exports.ox_target:removeGlobalVehicle(optionNames)
end

function Sky.Target.AddModel(models, options)
    exports.ox_target:addModel(models, options)
end

function Sky.Target.RemoveModel(models, option_names)
    exports.ox_target:removeModel(models, option_names)
end

Sky.Target.AddVehicleModel = Sky.Target.AddModel
Sky.Target.RemoveVehicleModel = Sky.Target.RemoveModel

function Sky.Target.AddGlobalOption(options)
    exports.ox_target:addGlobalOption(options)
end

function Sky.Target.RemoveGlobalOption(optionNames)
    exports.ox_target:removeGlobalOption(optionNames)
end
