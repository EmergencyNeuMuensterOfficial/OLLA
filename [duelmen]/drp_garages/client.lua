local zones, blips = {}, {}

local function notify(message, kind)
    lib.notify({ title = 'Garage', description = message, type = kind or 'inform' })
end

local function trim(value)
    return tostring(value or ''):gsub('^%s*(.-)%s*$', '%1')
end

local function isSpawnClear(spawn)
    return not IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 3.5)
end

local function vehicleProperties(vehicle)
    local primary, secondary = GetVehicleColours(vehicle)
    local pearlescent, wheel = GetVehicleExtraColours(vehicle)
    return {
        plate = trim(GetVehicleNumberPlateText(vehicle)),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = GetVehicleBodyHealth(vehicle), engineHealth = GetVehicleEngineHealth(vehicle), fuelLevel = GetVehicleFuelLevel(vehicle),
        primaryColour = primary, secondaryColour = secondary, pearlescentColour = pearlescent, wheelColour = wheel,
        dirtLevel = GetVehicleDirtLevel(vehicle),
    }
end

local function applyProperties(vehicle, props)
    if not props then return end
    if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if props.primaryColour then SetVehicleColours(vehicle, props.primaryColour, props.secondaryColour or 0) end
    if props.pearlescentColour then SetVehicleExtraColours(vehicle, props.pearlescentColour, props.wheelColour or 0) end
    if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
    if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
end

local function spawnVehicle(modelName, spawn, properties)
    local model = joaat(modelName)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then return nil, 'Ungültiges Fahrzeugmodell: ' .. modelName end
    RequestModel(model)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    if not HasModelLoaded(model) then return nil, 'Fahrzeugmodell konnte nicht geladen werden.' end
    local vehicle = CreateVehicle(model, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    applyProperties(vehicle, properties)
    SetModelAsNoLongerNeeded(model)
    return vehicle
end

local function openPlayerGarage(garage)
    local vehicles = lib.callback.await('drp_garages:server:getVehicles', false, garage.id) or {}
    local options = {}
    for _, vehicle in ipairs(vehicles) do
        local stored = tonumber(vehicle.stored) == 1
        if stored then
            options[#options + 1] = {
                title = vehicle.vehicle_label,
                description = ('Kennzeichen: %s · Eingeparkt'):format(vehicle.plate), icon = 'car',
                onSelect = function()
                if not isSpawnClear(garage.spawn) then return notify('Der Ausparkplatz ist blockiert.', 'error') end
                local ok, data = lib.callback.await('drp_garages:server:takeOut', false, vehicle.id, garage.id)
                if not ok then return notify(data or 'Fahrzeug konnte nicht ausgeparkt werden.', 'error') end
                local spawned, errorMessage = spawnVehicle(data.vehicle_model, garage.spawn, data.vehicle_props)
                if not spawned then
                    return notify(errorMessage, 'error')
                end
                if not lib.callback.await('drp_garages:server:confirmTakeOut', false, data.id, garage.id) then
                    DeleteVehicle(spawned)
                    return notify('Fahrzeugstatus konnte nicht aktualisiert werden.', 'error')
                end
                SetPedIntoVehicle(PlayerPedId(), spawned, -1)
                notify('Fahrzeug ausgeparkt.', 'success')
                end,
            }
        else
            options[#options + 1] = {
                title = vehicle.vehicle_label,
                description = ('Kennzeichen: %s · Als ausgeparkt markiert'):format(vehicle.plate), icon = 'triangle-exclamation', iconColor = 'orange',
                onSelect = function()
                    local confirmed = lib.alertDialog({
                        header = 'Fahrzeug wiederherstellen',
                        content = 'Nutze dies nur, wenn das Fahrzeug nicht in der Welt erschienen ist.',
                        centered = true, cancel = true,
                    })
                    if confirmed ~= 'confirm' then return end
                    local ok, message = lib.callback.await('drp_garages:server:recoverVehicle', false, vehicle.id)
                    notify(message, ok and 'success' or 'error')
                    if ok then openPlayerGarage(garage) end
                end,
            }
        end
    end
    if #options == 0 then options[1] = { title = 'Keine Fahrzeuge', description = 'Du besitzt noch keine Fahrzeuge.', icon = 'car', disabled = true } end
    options[#options + 1] = {
        title = 'Fahrzeug einparken', description = 'Speichert dein eigenes Fahrzeug in dieser Garage.', icon = 'square-parking',
        onSelect = function()
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle == 0 then vehicle = GetClosestVehicle(GetEntityCoords(ped), DRPGarages.StoreDistance, 0, 70) end
            if vehicle == 0 then return notify('Kein Fahrzeug in der Nähe.', 'error') end
            local plate = trim(GetVehicleNumberPlateText(vehicle))
            local stored, message = lib.callback.await('drp_garages:server:storeVehicle', false, garage.id, plate, vehicleProperties(vehicle))
            if not stored then return notify(message or 'Fahrzeug konnte nicht eingeparkt werden.', 'error') end
            if DoesEntityExist(vehicle) then DeleteVehicle(vehicle) end
            notify(message, 'success')
        end,
    }
    lib.registerContext({ id = 'drp_player_garage', title = garage.label, options = options })
    lib.showContext('drp_player_garage')
end

local function openJobGarage(garage)
    local fleet = lib.callback.await('drp_garages:server:getJobFleet', false, garage.id)
    if not fleet then return notify('Du hast keine Berechtigung für diese Garage.', 'error') end
    local options = {}
    for _, entry in ipairs(fleet) do
        options[#options + 1] = {
            title = entry.label, description = entry.model, icon = 'car',
            onSelect = function()
                if not isSpawnClear(garage.spawn) then return notify('Der Ausparkplatz ist blockiert.', 'error') end
                local ok, vehicle = lib.callback.await('drp_garages:server:takeJobVehicle', false, garage.id, entry.model)
                if not ok then return notify(vehicle or 'Keine Berechtigung.', 'error') end
                local spawned, errorMessage = spawnVehicle(vehicle.model, garage.spawn)
                if not spawned then return notify(errorMessage, 'error') end
                SetVehicleNumberPlateText(spawned, ('%s %03d'):format(garage.job:upper():sub(1, 3), math.random(1, 999)))
                SetPedIntoVehicle(PlayerPedId(), spawned, -1)
            end,
        }
    end
    options[#options + 1] = {
        title = 'Dienstfahrzeug zurückgeben', icon = 'warehouse',
        onSelect = function()
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle == 0 then vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), DRPGarages.StoreDistance, 0, 70) end
            if vehicle ~= 0 then DeleteVehicle(vehicle) else notify('Kein Dienstfahrzeug in der Nähe.', 'error') end
        end,
    }
    lib.registerContext({ id = 'drp_job_garage_' .. garage.id, title = garage.label, options = options })
    lib.showContext('drp_job_garage_' .. garage.id)
end

CreateThread(function()
    for _, garage in ipairs(DRPGarages.PlayerGarages) do
        zones[#zones + 1] = exports.ox_target:addSphereZone({
            coords = garage.coords, radius = 2.0,
            options = {{ name = 'drp_player_garage_' .. garage.id, icon = 'fa-solid fa-square-parking', label = garage.label, onSelect = function() openPlayerGarage(garage) end }},
        })
        local blip = AddBlipForCoord(garage.blip.x, garage.blip.y, garage.blip.z)
        SetBlipSprite(blip, 357); SetBlipColour(blip, 3); SetBlipScale(blip, 0.72); SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING'); AddTextComponentString(garage.label); EndTextCommandSetBlipName(blip)
        blips[#blips + 1] = blip
    end
    for _, garage in ipairs(DRPGarages.JobGarages) do
        zones[#zones + 1] = exports.ox_target:addSphereZone({
            coords = garage.coords, radius = 2.0,
            options = {{ name = 'drp_job_garage_' .. garage.id, icon = 'fa-solid fa-car-on', label = garage.label, onSelect = function() openJobGarage(garage) end }},
        })
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, zone in ipairs(zones) do exports.ox_target:removeZone(zone) end
    for _, blip in ipairs(blips) do RemoveBlip(blip) end
end)
