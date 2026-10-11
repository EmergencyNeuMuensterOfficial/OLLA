DRP = DRP or {}

local schema = [[
CREATE TABLE IF NOT EXISTS drp_players (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    license VARCHAR(64) NOT NULL,
    name VARCHAR(64) NOT NULL,
    cash INT NOT NULL DEFAULT 500,
    bank INT NOT NULL DEFAULT 2500,
    metadata LONGTEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_drp_players_license (license)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
]]

CreateThread(function()
    MySQL.query.await(schema)
    print(('[%s] Database schema is ready.'):format(GetCurrentResourceName()))
end)

function DRP.FetchOrCreatePlayer(license, displayName)
    local player = MySQL.single.await('SELECT * FROM drp_players WHERE license = ?', { license })
    if player then return player end

    local id = MySQL.insert.await([[INSERT INTO drp_players (license, name, cash, bank, metadata)
        VALUES (?, ?, ?, ?, ?)]], {
        license,
        displayName,
        DRP.Config.DefaultCash,
        DRP.Config.DefaultBank,
        '{}'
    })

    return MySQL.single.await('SELECT * FROM drp_players WHERE id = ?', { id })
end

function DRP.SavePlayer(player)
    return MySQL.update.await([[UPDATE drp_players
        SET name = ?, cash = ?, bank = ?, metadata = ?
        WHERE id = ?]], {
        player.name,
        player.cash,
        player.bank,
        json.encode(player.metadata or {}),
        player.id
    })
end
