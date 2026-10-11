local function trim(value)
    return tostring(value or ''):gsub('^%s*(.-)%s*$', '%1')
end

local function playerCharacter(source)
    return exports.drp_core:GetActiveCharacter(source)
end

local function playerGarage(id)
    for _, garage in ipairs(DRPGarages.PlayerGarages) do
        if garage.id == id then return garage end
    end
end

local function jobGarage(id)
    for _, garage in ipairs(DRPGarages.JobGarages) do
        if garage.id == id then return garage end
    end
end

local function canUseJobGarage(source, garage)
    local character = playerCharacter(source)
    return character and character.job_name == garage.job
        and (tonumber(character.job_grade) or 0) >= (tonumber(garage.minGrade) or 0)
end

MySQL.ready(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS drp_owned_vehicles (
        id INT UNSIGNED NOT NULL AUTO_INCREMENT,
        character_id INT UNSIGNED NOT NULL,
        plate VARCHAR(16) NOT NULL,
        vehicle_model VARCHAR(64) NOT NULL,
        vehicle_label VARCHAR(100) NOT NULL,
        vehicle_props LONGTEXT NULL,
        garage_id VARCHAR(64) NOT NULL DEFAULT 'legion',
        stored TINYINT(1) NOT NULL DEFAULT 1,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE KEY uniq_drp_vehicle_plate (plate),
        KEY idx_drp_vehicle_owner (character_id),
        CONSTRAINT fk_drp_vehicle_character FOREIGN KEY (character_id) REFERENCES drp_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
    print('[drp_garages] Vehicle schema is ready.')
end)

lib.callback.register('drp_garages:server:getVehicles', function(source, garageId)
    if not playerGarage(garageId) then return {} end
    local character = playerCharacter(source)
    if not character then return {} end
    -- CAST avoids connector-specific TINYINT-to-boolean conversion. The
    -- client receives a real 0/1 state for every vehicle.
    return MySQL.query.await([[SELECT id, plate, vehicle_model, vehicle_label, garage_id,
        CAST(stored AS UNSIGNED) AS stored
        FROM drp_owned_vehicles WHERE character_id = ? ORDER BY stored DESC, vehicle_label ASC]], { character.id }) or {}
end)

lib.callback.register('drp_garages:server:takeOut', function(source, vehicleId, garageId)
    local garage = playerGarage(garageId)
    local character = playerCharacter(source)
    if not garage or not character then return false, 'Garage nicht verfügbar.' end
    local row = MySQL.single.await([[SELECT id, plate, vehicle_model, vehicle_label, vehicle_props,
        CAST(stored AS UNSIGNED) AS stored
        FROM drp_owned_vehicles WHERE id = ? AND character_id = ?]], { tonumber(vehicleId), character.id })
    if not row then return false, 'Dieses Fahrzeug gehört dir nicht.' end
    if row.stored ~= 1 and row.stored ~= '1' and row.stored ~= true then
        return false, 'Dieses Fahrzeug ist bereits ausgeparkt.'
    end
    row.vehicle_props = row.vehicle_props and json.decode(row.vehicle_props) or {}
    return true, row
end)

lib.callback.register('drp_garages:server:confirmTakeOut', function(source, vehicleId, garageId)
    local garage = playerGarage(garageId)
    local character = playerCharacter(source)
    if not garage or not character then return false end
    return MySQL.update.await([[UPDATE drp_owned_vehicles SET stored = 0, garage_id = ?
        WHERE id = ? AND character_id = ? AND stored = 1]], { garage.id, tonumber(vehicleId), character.id }) == 1
end)

lib.callback.register('drp_garages:server:recoverVehicle', function(source, vehicleId)
    local character = playerCharacter(source)
    if not character then return false, 'Kein Charakter geladen.' end
    local id = tonumber(vehicleId)
    if not id then return false, 'Ungültige Fahrzeug-ID.' end

    -- Do not depend on MySQL's affected-row count here.  Some configurations
    -- report 0 when a row already contains the requested value, which made a
    -- successfully repaired vehicle look like a failed repair to the player.
    MySQL.update.await([[UPDATE drp_owned_vehicles SET stored = 1
        WHERE id = ? AND character_id = ?]], { id, character.id })
    local vehicle = MySQL.single.await([[SELECT stored FROM drp_owned_vehicles
        WHERE id = ? AND character_id = ?]], { id, character.id })
    if vehicle and tonumber(vehicle.stored) == 1 then
        return true, 'Fahrzeug wurde wieder in die Garage eingelagert.'
    end
    return false, 'Fahrzeugstatus konnte nicht wiederhergestellt werden.'
end)

lib.callback.register('drp_garages:server:storeVehicle', function(source, garageId, plate, properties)
    local garage = playerGarage(garageId)
    local character = playerCharacter(source)
    plate = trim(plate):upper()
    if not garage or not character or plate == '' then return false, 'Ungültige Garage oder Kennzeichen.' end
    local result = MySQL.update.await([[UPDATE drp_owned_vehicles
        SET stored = 1, garage_id = ?, vehicle_props = ? WHERE character_id = ? AND plate = ?]], {
        garage.id, json.encode(properties or {}), character.id, plate,
    })
    if result == 1 then
        return true, 'Fahrzeug eingeparkt und gespeichert.'
    else
        return false, 'Dieses Fahrzeug gehört dir nicht.'
    end
end)

lib.callback.register('drp_garages:server:getJobFleet', function(source, garageId)
    local garage = jobGarage(garageId)
    if not garage or not canUseJobGarage(source, garage) then return nil end
    return garage.vehicles
end)

lib.callback.register('drp_garages:server:takeJobVehicle', function(source, garageId, model)
    local garage = jobGarage(garageId)
    if not garage or not canUseJobGarage(source, garage) then return false, 'Keine Berechtigung.' end
    for _, vehicle in ipairs(garage.vehicles) do
        if vehicle.model == model then return true, vehicle end
    end
    return false, 'Ungültiges Dienstfahrzeug.'
end)

-- Temporary administration tool for testing or awarding purchased vehicles.
RegisterCommand('givevehicle', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'drp.garage.admin') then return end
    local target = tonumber(args[1])
    local model = trim(args[2]):lower()
    if not target or model == '' then
        return print('Usage: givevehicle [server-id] [spawn-name] [optional plate]')
    end
    local plate = trim(args[3] or ('DRP%04d'):format(math.random(0, 9999))):upper()
    local character = playerCharacter(target)
    -- A console command can also target a database character ID. This is
    -- useful for awards while the player has not yet fully loaded.
    if not character then
        character = MySQL.single.await('SELECT id FROM drp_characters WHERE id = ?', { target })
    end
    if not character then
        return print(('givevehicle: No active player or character with ID %s was found.'):format(target))
    end
    local inserted, databaseError = pcall(MySQL.insert.await, [[INSERT INTO drp_owned_vehicles (character_id, plate, vehicle_model, vehicle_label, garage_id, stored)
        VALUES (?, ?, ?, ?, 'legion', 1)]], { character.id, plate, model, model:upper() })
    if inserted and databaseError then
        if GetPlayerName(target) then
            TriggerClientEvent('ox_lib:notify', target, { title = 'Garage', description = ('Du hast ein Fahrzeug erhalten: %s'):format(model:upper()), type = 'success' })
        end
        print(('givevehicle: %s (%s) was assigned to character %s.'):format(model, plate, character.id))
    else
        print(('givevehicle: The plate "%s" is already assigned. Use a unique plate.'):format(plate))
    end
end, true)

-- Repairs a vehicle left in the old "out" state by a failed spawn attempt.
-- Console usage: recovervehicle [character-id] [plate]
RegisterCommand('recovervehicle', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'drp.garage.admin') then return end
    local characterId, plate = tonumber(args[1]), trim(args[2]):upper()
    if not characterId or plate == '' then return print('Usage: recovervehicle [character-id] [plate]') end
    local changed = MySQL.update.await('UPDATE drp_owned_vehicles SET stored = 1 WHERE character_id = ? AND plate = ?', { characterId, plate })
    print(changed == 1 and ('recovervehicle: %s was returned to storage.'):format(plate)
        or ('recovervehicle: No vehicle with plate %s was found for character %s.'):format(plate, characterId))
end, true)
