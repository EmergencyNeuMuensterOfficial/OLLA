---@diagnostic disable: duplicate-set-field
if IsDuplicityVersion() then return end
if Sky.Config.target ~= "tgiann" then return end

Sky.Target = Sky.Target or {}

local TARGET_RESOURCE = "tgiann-target"

function Sky.Target.AddLocalEntity(entity, options)
    exports[TARGET_RESOURCE]:addLocalEntity(entity, options)
end

function Sky.Target.RemoveLocalEntity(entity, optionNames)
    exports[TARGET_RESOURCE]:removeLocalEntity(entity, optionNames)
end

function Sky.Target.AddSphereZone(params)
    return exports[TARGET_RESOURCE]:addSphereZone({
        coords = params.coords,
        radius = params.radius,
        debug = params.debug == true,
        drawSprite = params.drawSprite == true,
        options = params.options,
    })
end

function Sky.Target.RemoveZone(handle)
    exports[TARGET_RESOURCE]:removeZone(handle)
end

function Sky.Target.AddGlobalPlayer(options)
    exports[TARGET_RESOURCE]:addGlobalPlayer(options)
end

function Sky.Target.RemoveGlobalPlayer(optionNames)
    exports[TARGET_RESOURCE]:removeGlobalPlayer(optionNames)
end

function Sky.Target.AddModel(models, options)
    exports[TARGET_RESOURCE]:addModel(models, options)
end

function Sky.Target.RemoveModel(models, option_names)
    exports[TARGET_RESOURCE]:removeModel(models, option_names)
end

Sky.Target.AddVehicleModel = Sky.Target.AddModel
Sky.Target.RemoveVehicleModel = Sky.Target.RemoveModel

function Sky.Target.AddGlobalOption(options)
    exports[TARGET_RESOURCE]:addGlobalOption(options)
end

function Sky.Target.RemoveGlobalOption(optionNames)
    exports[TARGET_RESOURCE]:removeGlobalOption(optionNames)
end
