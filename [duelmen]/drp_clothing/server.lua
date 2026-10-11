local function getCharacter(source)
    return exports.drp_core:GetActiveCharacter(source)
end

local function isAppearance(value)
    return type(value) == 'table' and type(value.components) == 'table' and type(value.props) == 'table'
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS drp_character_appearances (
        character_id INT UNSIGNED NOT NULL PRIMARY KEY,
        appearance LONGTEXT NOT NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_drp_appearance_character FOREIGN KEY (character_id)
            REFERENCES drp_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
end)

lib.callback.register('drp_clothing:server:getAppearance', function(source)
    local character = getCharacter(source)
    if not character then return nil end
    local stored = MySQL.scalar.await('SELECT appearance FROM drp_character_appearances WHERE character_id = ?', { character.id })
    if type(stored) ~= 'string' then return nil end
    local ok, appearance = pcall(json.decode, stored)
    return ok and isAppearance(appearance) and appearance or nil
end)

RegisterNetEvent('drp_clothing:server:purchase', function(appearance)
    local source = source
    local character = getCharacter(source)
    if not character or not isAppearance(appearance) then return end

    for component, data in pairs(appearance.components) do
        local id = tonumber(component)
        if not id or id < 0 or id > 11 or type(data) ~= 'table' or not tonumber(data.drawable) or not tonumber(data.texture) then return end
    end
    for prop, data in pairs(appearance.props) do
        local id = tonumber(prop)
        if not id or id < 0 or id > 7 or type(data) ~= 'table' or not tonumber(data.drawable) or not tonumber(data.texture) then return end
    end

    if not exports.drp_core:RemoveMoney(source, 'bank', DRPClothing.PurchasePrice, 'clothing_purchase') then
        return TriggerClientEvent('drp_clothing:client:purchaseResult', source, false, 'Nicht genug Geld auf dem Bankkonto.')
    end

    local success = pcall(function()
        MySQL.insert.await([[INSERT INTO drp_character_appearances (character_id, appearance)
            VALUES (?, ?) ON DUPLICATE KEY UPDATE appearance = VALUES(appearance)]], { character.id, json.encode(appearance) })
    end)
    if not success then
        exports.drp_core:AddMoney(source, 'bank', DRPClothing.PurchasePrice, 'clothing_refund')
        return TriggerClientEvent('drp_clothing:client:purchaseResult', source, false, 'Die Kleidung konnte nicht gespeichert werden. Dein Geld wurde zurückerstattet.')
    end
    TriggerClientEvent('drp_clothing:client:purchaseResult', source, true, ('Outfit für $%s gespeichert.'):format(DRPClothing.PurchasePrice))
end)

AddEventHandler('drp_characters:server:characterLoaded', function(source)
    SetTimeout(1800, function()
        if getCharacter(source) then TriggerClientEvent('drp_clothing:client:loadAppearance', source) end
    end)
end)
