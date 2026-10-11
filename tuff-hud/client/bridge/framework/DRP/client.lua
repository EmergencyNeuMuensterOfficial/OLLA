-- Dülmen Roleplay bridge for Tuff HUD.
-- The active character is the source of truth for money and job data.
local DRPBridge = {}
DRPBridge.__index = DRPBridge

function DRPBridge:GetPlayerData()
    return exports.drp_core:GetPlayerData()
end

function DRPBridge:getFrameworkPlayerData()
    return self:GetPlayerData()
end

function DRPBridge:HasRequiredPlayerData(playerData)
    return type(playerData) == 'table' and type(playerData.character) == 'table'
end

function DRPBridge:IsPlayerLoggedIn(playerData)
    return self:HasRequiredPlayerData(playerData)
end

function DRPBridge:ApplyPlayerData(playerData, client)
    if not client or not client.PlayerData then return false end
    playerData = playerData or self:GetPlayerData()
    local character = playerData and playerData.character
    if not character then return false end

    client.PlayerData.Bank = tonumber(character.bank) or 0
    client.PlayerData.Money = GetResourceState('ox_inventory') == 'started'
        and (exports.ox_inventory:Search('count', 'money') or 0)
        or (tonumber(character.cash) or 0)
    client.PlayerData.BlackMoney = 0
    client.PlayerData.Job = (character.job_name or character.job or 'unemployed'):gsub('_', ' ')
    client.PlayerData.HasGangSystem = false
    client.PlayerData.Gang = nil
    return true
end

function DRPBridge:RefreshPlayerData(playerData)
    return self:ApplyPlayerData(playerData or self:GetPlayerData(), Client)
end

function DRPBridge:RegisterEvents(isHudInitialized, refreshPlayerData, onPlayerLoaded)
    RegisterNetEvent('drp_core:client:characterSelected', function(character)
        local playerData = self:GetPlayerData()
        if playerData then playerData.character = character end
        if onPlayerLoaded then onPlayerLoaded() end
        if isHudInitialized and isHudInitialized() and refreshPlayerData then
            refreshPlayerData(self:GetPlayerData())
        end
    end)

    RegisterNetEvent('drp_core:client:moneyUpdated', function(account, balance)
        local playerData = self:GetPlayerData()
        if playerData and playerData.character then
            playerData.character[account] = balance
            if refreshPlayerData then refreshPlayerData(playerData) end
        end
    end)
end

function DRPBridge:StartStatusListener() end
function DRPBridge:GetJob()
    local data = self:GetPlayerData()
    return data and data.character and (data.character.job_name or data.character.job) or false
end
function DRPBridge:UpdateStress() end

return setmetatable({
    Name = 'Dülmen Roleplay',
    Resource = 'drp_core',
    Core = {},
    Framework = {},
}, DRPBridge)
