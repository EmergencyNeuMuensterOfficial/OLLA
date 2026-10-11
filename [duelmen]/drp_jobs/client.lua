local zones, props = {}, {}
local savedAppearance

local function notify(description, type)
    lib.notify({ title = 'Dülmen Jobs', description = description, type = type or 'inform' })
end

local function captureAppearance()
    local ped = PlayerPedId()
    local appearance = { components = {}, props = {} }
    for component = 0, 11 do
        appearance.components[component] = { GetPedDrawableVariation(ped, component), GetPedTextureVariation(ped, component), GetPedPaletteVariation(ped, component) }
    end
    for prop = 0, 7 do
        appearance.props[prop] = { GetPedPropIndex(ped, prop), GetPedPropTextureIndex(ped, prop) }
    end
    return appearance
end

local function applyAppearance(appearance)
    if not appearance then return end
    local ped = PlayerPedId()
    for component, values in pairs(appearance.components or {}) do
        SetPedComponentVariation(ped, tonumber(component), values[1], values[2], values[3] or 0)
    end
    for prop, values in pairs(appearance.props or {}) do
        local propId = tonumber(prop)
        if values[1] and values[1] >= 0 then SetPedPropIndex(ped, propId, values[1], values[2], true) else ClearPedProp(ped, propId) end
    end
end

local function currentJob()
    local data = exports.drp_core:GetPlayerData()
    return data and data.character
end

local function openWardrobe(jobName)
    local outfit = lib.callback.await('drp_jobs:server:getWardrobe', false, jobName)
    local character = currentJob()
    if not character then return end
    local options = {
        {
            title = 'Eigene Kleidung anziehen', icon = 'person',
            onSelect = function()
                applyAppearance(savedAppearance)
                savedAppearance = nil
                notify('Deine private Kleidung wurde angezogen.', 'success')
            end,
        },
    }
    if outfit then
        options[#options + 1] = {
            title = 'Dienstuniform anziehen', icon = 'shirt',
            onSelect = function()
                if not savedAppearance then savedAppearance = captureAppearance() end
                applyAppearance({ components = json.decode(outfit.components), props = json.decode(outfit.props) })
                notify('Dienstuniform angezogen.', 'success')
            end,
        }
    end
    options[#options + 1] = {
        title = 'Aktuelles Outfit als Ranguniform speichern', icon = 'floppy-disk',
        description = 'Nur für den Boss dieses Jobs.',
        onSelect = function()
            TriggerServerEvent('drp_jobs:server:saveOutfit', jobName, captureAppearance())
        end,
    }
    lib.registerContext({ id = 'drp_jobs_wardrobe', title = 'Garderobe', options = options })
    lib.showContext('drp_jobs_wardrobe')
end

local function openBossMenu(jobName)
    local data = lib.callback.await('drp_jobs:server:getBossData', false, jobName)
    if not data then return notify('Keine Boss-Berechtigung.', 'error') end
    local options = {}
    for _, employee in ipairs(data.employees) do
        local employeeOptions = {
            {
                title = 'Kündigen', icon = 'user-minus', iconColor = 'red',
                onSelect = function() TriggerServerEvent('drp_jobs:server:fireEmployee', employee.id, jobName) end,
            },
        }
        for _, grade in ipairs(data.grades) do
            employeeOptions[#employeeOptions + 1] = {
                title = ('Rang setzen: %s'):format(grade.label), description = ('Lohn: $%s'):format(grade.salary), icon = 'user-pen',
                onSelect = function() TriggerServerEvent('drp_jobs:server:setEmployeeGrade', employee.id, jobName, grade.grade) end,
            }
        end
        local id = ('drp_jobs_employee_%s'):format(employee.id)
        lib.registerContext({ id = id, title = ('%s %s'):format(employee.first_name, employee.last_name), options = employeeOptions })
        options[#options + 1] = { title = ('%s %s'):format(employee.first_name, employee.last_name), description = ('Rang %s'):format(employee.job_grade), icon = 'users', menu = id }
    end
    for _, player in ipairs(data.online) do
        options[#options + 1] = {
            title = ('Einstellen: %s'):format(player.name), description = ('Server-ID: %s'):format(player.source), icon = 'user-plus',
            onSelect = function() TriggerServerEvent('drp_jobs:server:hirePlayer', player.source, jobName) end,
        }
    end
    lib.registerContext({ id = 'drp_jobs_boss', title = 'Boss-Menü', options = options })
    lib.showContext('drp_jobs_boss')
end

RegisterNetEvent('drp_jobs:client:openBossMenu', openBossMenu)

local function clearLocations()
    for _, zone in ipairs(zones) do exports.ox_target:removeZone(zone) end
    for _, prop in ipairs(props) do if DoesEntityExist(prop) then DeleteEntity(prop) end end
    zones, props = {}, {}
end

local function spawnProp(modelName, coords)
    local model = joaat(modelName)
    RequestModel(model)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    if not HasModelLoaded(model) then return end
    local prop = CreateObjectNoOffset(model, coords.x, coords.y, coords.z - 1.0, false, false, false)
    SetEntityHeading(prop, coords.heading or 0.0)
    FreezeEntityPosition(prop, true)
    props[#props + 1] = prop
    SetModelAsNoLongerNeeded(model)
end

local function loadLocations()
    clearLocations()
    local locations = lib.callback.await('drp_jobs:server:getLocations', false) or {}
    for _, location in ipairs(locations) do
        local coords = vec3(location.x, location.y, location.z)
        local isBossLocation = location.location_type == 'boss'
        spawnProp(isBossLocation and DRPJobs.BossProp or DRPJobs.WardrobeProp, vector4(location.x, location.y, location.z, location.heading))
        zones[#zones + 1] = exports.ox_target:addSphereZone({
            coords = coords, radius = 1.5, debug = false,
            options = {
                {
                    name = ('drp_job_%s_%s'):format(location.location_type, location.id),
                    icon = isBossLocation and 'fa-solid fa-briefcase' or 'fa-solid fa-shirt',
                    label = isBossLocation and 'Boss-Menü öffnen' or 'Garderobe öffnen',
                    distance = 2.0,
                    canInteract = function()
                        local character = currentJob()
                        return character and character.job_name == location.job_name
                    end,
                    onSelect = function()
                        if isBossLocation then openBossMenu(location.job_name) else openWardrobe(location.job_name) end
                    end,
                },
            },
        })
    end
end

local function openCreator()
    local jobs = lib.callback.await('drp_jobs:server:getJobs', false)
    if not jobs then return notify('Keine Berechtigung für den Job Creator.', 'error') end
    local options = {
        {
            title = 'Neuen Job erstellen', icon = 'plus',
            onSelect = function()
                local input = lib.inputDialog('Neuen Job erstellen', {
                    { type = 'input', label = 'Interner Name', placeholder = 'police', required = true },
                    { type = 'input', label = 'Anzeigename', placeholder = 'Polizei', required = true },
                })
                if not input then return end
                local ok, message = lib.callback.await('drp_jobs:server:createJob', false, input[1]:lower(), input[2])
                notify(message, ok and 'success' or 'error')
            end,
        },
    }
    for _, job in ipairs(jobs) do
        local jobId = ('drp_jobcreator_%s'):format(job.name)
        local locationsId = ('drp_joblocations_%s'):format(job.name)
        local ranksId = ('drp_jobranks_%s'):format(job.name)
        local rankOptions, gradeChoices = {}, {}
        for _, grade in ipairs(job.grades or {}) do
            gradeChoices[#gradeChoices + 1] = { value = grade.grade, label = ('%s (Rang %s)'):format(grade.label, grade.grade) }
            local rankEditId = ('drp_jobrank_%s_%s'):format(job.name, grade.grade)
            lib.registerContext({ id = rankEditId, title = ('Rang %s: %s'):format(grade.grade, grade.label), options = {
                { title = 'Rang bearbeiten', icon = 'pen', onSelect = function()
                    local input = lib.inputDialog('Rang bearbeiten', {
                        { type = 'input', label = 'Rangname', default = grade.label, required = true },
                        { type = 'number', label = 'Lohn pro Paycheck', default = grade.salary, min = 0 },
                        { type = 'checkbox', label = 'Boss-Berechtigung', checked = tonumber(grade.is_boss) == 1 },
                    })
                    if not input then return end
                    local ok, message = lib.callback.await('drp_jobs:server:updateGrade', false, job.name, grade.grade, input[1], input[2], input[3])
                    notify(message, ok and 'success' or 'error')
                end },
                { title = 'Rang löschen', description = grade.grade == 0 and 'Der Grundrang kann nicht gelöscht werden.' or 'Mitarbeiter dieses Rangs werden auf Rang 0 gesetzt.', icon = 'trash', iconColor = 'red', disabled = grade.grade == 0, onSelect = function()
                    local confirm = lib.alertDialog({ header = 'Rang wirklich löschen?', content = grade.label, centered = true, cancel = true })
                    if confirm == 'confirm' then
                        local ok, message = lib.callback.await('drp_jobs:server:deleteGrade', false, job.name, grade.grade)
                        notify(message, ok and 'success' or 'error')
                    end
                end },
            } })
            rankOptions[#rankOptions + 1] = {
                title = ('%s · Rang %s'):format(grade.label, grade.grade),
                description = ('$%s pro Paycheck%s'):format(grade.salary, tonumber(grade.is_boss) == 1 and ' · Boss' or ''),
                icon = tonumber(grade.is_boss) == 1 and 'crown' or 'user', menu = rankEditId,
            }
        end
        lib.registerContext({ id = ranksId, title = ('Ränge: %s'):format(job.label), options = rankOptions })
        local locationOptions = {}
        for _, location in ipairs(job.locations or {}) do
            locationOptions[#locationOptions + 1] = {
                title = location.location_type == 'boss' and 'Boss-Menü-Punkt' or 'Garderoben-Punkt',
                description = ('ID %s · %.1f, %.1f, %.1f'):format(location.id, location.x, location.y, location.z),
                icon = 'trash', iconColor = 'red',
                onSelect = function() TriggerServerEvent('drp_jobs:server:deleteLocation', location.id) end,
            }
        end
        if #locationOptions == 0 then locationOptions[1] = { title = 'Keine Punkte gesetzt', disabled = true } end
        lib.registerContext({ id = locationsId, title = ('Punkte: %s'):format(job.label), options = locationOptions })
        lib.registerContext({ id = jobId, title = job.label, options = {
            { title = 'Spieler zuweisen', icon = 'user-check', onSelect = function()
                local input = lib.inputDialog(('Spieler für %s zuweisen'):format(job.label), {
                    { type = 'number', label = 'Server-ID', required = true, min = 1 },
                    { type = 'select', label = 'Rang', required = true, options = gradeChoices },
                })
                if not input then return end
                local ok, message = lib.callback.await('drp_jobs:server:creatorAssign', false, input[1], job.name, input[2])
                notify(message, ok and 'success' or 'error')
            end },
            { title = 'Boss-Punkt hier platzieren', icon = 'briefcase', onSelect = function() local c = GetEntityCoords(PlayerPedId()); TriggerServerEvent('drp_jobs:server:addLocation', job.name, 'boss', { x = c.x, y = c.y, z = c.z, w = GetEntityHeading(PlayerPedId()) }) end },
            { title = 'Garderobe hier platzieren', icon = 'shirt', onSelect = function() local c = GetEntityCoords(PlayerPedId()); TriggerServerEvent('drp_jobs:server:addLocation', job.name, 'wardrobe', { x = c.x, y = c.y, z = c.z, w = GetEntityHeading(PlayerPedId()) }) end },
            { title = 'Gesetzte Punkte verwalten', icon = 'map-location-dot', menu = locationsId },
            { title = 'Ränge verwalten', icon = 'users-gear', menu = ranksId },
            { title = 'Rang hinzufügen', icon = 'user-plus', onSelect = function()
                local input = lib.inputDialog(('Rang für %s'):format(job.label), {
                    { type = 'number', label = 'Rangnummer', required = true, min = 0, max = 99 },
                    { type = 'input', label = 'Rangname', required = true },
                    { type = 'number', label = 'Lohn pro Paycheck', default = 0, min = 0 },
                    { type = 'checkbox', label = 'Boss-Berechtigung', checked = false },
                })
                if not input then return end
                local ok, message = lib.callback.await('drp_jobs:server:addGrade', false, job.name, input[1], input[2], input[3], input[4])
                notify(message, ok and 'success' or 'error')
            end },
        } })
        options[#options + 1] = { title = job.label, description = ('%s Ränge'):format(#job.grades), icon = 'briefcase', menu = jobId }
    end
    lib.registerContext({ id = 'drp_job_creator', title = 'Job Creator', options = options })
    lib.showContext('drp_job_creator')
end

RegisterCommand('jobcreator', openCreator, false)
RegisterNetEvent('drp_jobs:client:refreshLocations', loadLocations)
RegisterNetEvent('drp_jobs:client:jobUpdated', function() notify('Dein Job wurde aktualisiert.', 'success') end)

CreateThread(function() Wait(1500); loadLocations() end)
AddEventHandler('onResourceStop', function(resourceName) if resourceName == GetCurrentResourceName() then clearLocations() end end)
