---@diagnostic disable: duplicate-set-field
if IsDuplicityVersion() then return end
if Sky.Config.target ~= "qb" then return end

Sky.Target = Sky.Target or {}

local zoneCounter = 0
local localEntityLabels = {}
local globalPlayerLabels = {}
local globalVehicleLabels = {}
local globalVehicleBones = {}
local model_labels = {}
local globalOptionLabels = {}

local function maxDistance(options, fallback)
    local m = 0
    for _, opt in ipairs(options) do
        local d = tonumber(opt.distance) or 0
        if d > m then m = d end
    end
    if m <= 0 then return fallback or 2.5 end
    return m
end

local function mapOptions(options, targetBone)
    local mapped = {}
    for i, opt in ipairs(options) do
        local onSelect = opt.onSelect
        local canInteract = opt.canInteract
        mapped[i] = {
            type = "client",
            icon = opt.icon,
            label = opt.label,
            action = onSelect and function(entity)
                onSelect({ entity = entity, name = opt.name, bone = targetBone })
            end or nil,
            canInteract = canInteract and function(entity, distance)
                return canInteract(entity, distance, nil, opt.name, targetBone) and true or false
            end or nil,
            job = opt.job,
            gang = opt.gang,
            item = opt.item,
        }
    end
    return mapped
end

local function rememberLabels(store, options)
    for _, opt in ipairs(options) do
        if opt.name and opt.label then
            store[opt.name] = opt.label
        end
    end
end

local function resolveLabels(store, names)
    local labels = {}
    if type(names) == "string" then
        local label = store[names]
        if label then labels[#labels + 1] = label end
        store[names] = nil
    elseif type(names) == "table" then
        for _, name in ipairs(names) do
            local label = store[name]
            if label then labels[#labels + 1] = label end
            store[name] = nil
        end
    end
    return labels
end

local function normalize_models(models)
    if type(models) == "table" then
        return models
    end
    return { models }
end

function Sky.Target.AddLocalEntity(entity, options)
    if not entity or not options or #options == 0 then return end
    localEntityLabels[entity] = localEntityLabels[entity] or {}
    rememberLabels(localEntityLabels[entity], options)
    exports['qb-target']:AddTargetEntity(entity, {
        options = mapOptions(options),
        distance = maxDistance(options),
    })
end

function Sky.Target.RemoveLocalEntity(entity, optionNames)
    if not entity then return end
    local store = localEntityLabels[entity]
    if not store then return end
    local labels = resolveLabels(store, optionNames)
    if #labels == 0 then return end
    exports['qb-target']:RemoveTargetEntity(entity, labels)
    if not next(store) then
        localEntityLabels[entity] = nil
    end
end

function Sky.Target.AddSphereZone(params)
    if not params or not params.coords or not params.options then return nil end
    zoneCounter = zoneCounter + 1
    local name = ("sky_zone_%d"):format(zoneCounter)
    exports['qb-target']:AddCircleZone(
        name,
        params.coords,
        params.radius or 1.5,
        { name = name, useZ = true, debugPoly = params.debug == true },
        { options = mapOptions(params.options), distance = maxDistance(params.options, params.radius or 1.5) }
    )
    return name
end

function Sky.Target.RemoveZone(handle)
    if not handle then return end
    exports['qb-target']:RemoveZone(handle)
end

function Sky.Target.AddGlobalPlayer(options)
    if not options or #options == 0 then return end
    rememberLabels(globalPlayerLabels, options)
    exports['qb-target']:AddGlobalPlayer({
        options = mapOptions(options),
        distance = maxDistance(options),
    })
end

function Sky.Target.RemoveGlobalPlayer(optionNames)
    local labels = resolveLabels(globalPlayerLabels, optionNames)
    if #labels == 0 then return end
    exports['qb-target']:RemoveGlobalPlayer(labels)
end

function Sky.Target.AddGlobalVehicle(options)
    if not options or #options == 0 then return end

    local globalOptions = {}
    for _, option in ipairs(options) do
        local bones = type(option.bones) == "string" and { option.bones } or option.bones
        if type(bones) == "table" and #bones > 0 then
            globalVehicleLabels[option.name] = option.label
            globalVehicleBones[option.name] = bones
            for _, boneName in ipairs(bones) do
                local targetBone = boneName
                exports['qb-target']:AddTargetBone(targetBone, {
                    options = mapOptions({ option }, targetBone),
                    distance = tonumber(option.distance) or 2.5,
                })
            end
        else
            globalOptions[#globalOptions + 1] = option
        end
    end

    if #globalOptions > 0 then
        rememberLabels(globalVehicleLabels, globalOptions)
        exports['qb-target']:AddGlobalVehicle({
            options = mapOptions(globalOptions),
            distance = maxDistance(globalOptions),
        })
    end
end

function Sky.Target.RemoveGlobalVehicle(optionNames)
    local names = type(optionNames) == "table" and optionNames or { optionNames }
    local globalLabels = {}

    for _, optionName in ipairs(names) do
        local label = globalVehicleLabels[optionName]
        local bones = globalVehicleBones[optionName]
        if label and bones then
            exports['qb-target']:RemoveTargetBone(bones, label)
        elseif label then
            globalLabels[#globalLabels + 1] = label
        end
        globalVehicleLabels[optionName] = nil
        globalVehicleBones[optionName] = nil
    end

    if #globalLabels > 0 then
        exports['qb-target']:RemoveGlobalVehicle(globalLabels)
    end
end

function Sky.Target.AddModel(models, options)
    if not models or not options or #options == 0 then return end

    local normalized_models = normalize_models(models)
    if #normalized_models == 0 then return end

    for _, model in ipairs(normalized_models) do
        model_labels[model] = model_labels[model] or {}
        rememberLabels(model_labels[model], options)
    end

    exports['qb-target']:AddTargetModel(models, {
        options = mapOptions(options),
        distance = maxDistance(options),
    })
end

function Sky.Target.RemoveModel(models, option_names)
    if not models then return end

    for _, model in ipairs(normalize_models(models)) do
        local labels = model_labels[model]
        if labels then
            local resolved_labels = resolveLabels(labels, option_names)
            if #resolved_labels > 0 then
                exports['qb-target']:RemoveTargetModel(model, resolved_labels)
            end
            if not next(labels) then
                model_labels[model] = nil
            end
        end
    end
end

Sky.Target.AddVehicleModel = Sky.Target.AddModel
Sky.Target.RemoveVehicleModel = Sky.Target.RemoveModel

function Sky.Target.AddGlobalOption(options)
    if not options or #options == 0 then return end
    rememberLabels(globalOptionLabels, options)
    local payload = { options = mapOptions(options), distance = maxDistance(options) }
    exports['qb-target']:AddGlobalPed(payload)
    exports['qb-target']:AddGlobalVehicle(payload)
    exports['qb-target']:AddGlobalObject(payload)
    exports['qb-target']:AddGlobalPlayer(payload)
end

function Sky.Target.RemoveGlobalOption(optionNames)
    local labels = resolveLabels(globalOptionLabels, optionNames)
    if #labels == 0 then return end
    exports['qb-target']:RemoveGlobalPed(labels)
    exports['qb-target']:RemoveGlobalVehicle(labels)
    exports['qb-target']:RemoveGlobalObject(labels)
    exports['qb-target']:RemoveGlobalPlayer(labels)
end
