---@diagnostic disable: duplicate-set-field
-- Framework-native ESX inventory. Active when no standalone inventory is selected; provides
-- fallbacks otherwise. Guarded on the framework so it loads regardless of Sky.Config.inventory.
if Sky.Config.framework ~= "esx" then return end
if not IsDuplicityVersion() then return end

local H = SkyInventoryHelpers
if Sky.Config.inventory == "esx" then
    function Sky.FW.GetInventoryStats(source)
        local player = ESX.GetPlayerFromId(source)
        if not player then
            Sky.Debug("error", "[inventory] ESX statistics unavailable: player %s is not loaded", source)
            return nil, "unavailable"
        end
        return H.NormalizeInventoryStats(player.getWeight(), player.getMaxWeight(), nil, nil, 1)
    end
end
local itemRefreshQueued = false

local function getEsxItems()
    if type(ESX.GetItems) == "function" then
        return ESX.GetItems()
    end
    return ESX.Items
end

local function refreshLegacyEsxPlayerInventories()
    local usableItems = ESX.GetUsableItems()
    local xPlayers = ESX.GetExtendedPlayers()

    for index = 1, #xPlayers do
        local xPlayer = xPlayers[index]
        local currentInventory = xPlayer.getInventory(true)
        local inventory = {}
        local totalWeight = 0

        for itemName, itemData in pairs(ESX.Items) do
            local count = currentInventory[itemName] or 0
            inventory[#inventory + 1] = {
                name = itemName,
                count = count,
                label = itemData.label,
                weight = itemData.weight,
                usable = usableItems[itemName] == true,
                rare = itemData.rare,
                canRemove = itemData.canRemove,
            }
            totalWeight = totalWeight + (itemData.weight * count)
        end

        xPlayer.inventory = inventory
        xPlayer.weight = totalWeight
        TriggerClientEvent("esx:updatePlayerData", xPlayer.source, "inventory", inventory)
    end
end

local function refreshLegacyEsxItems()
    local rows = Sky.Query("SELECT * FROM `items`", {})
    local items = {}

    for index = 1, #rows do
        local row = rows[index]
        items[row.name] = {
            label = row.label,
            weight = tonumber(row.weight) or 1,
            rare = row.rare,
            canRemove = row.can_remove,
        }
    end

    ESX.Items = items
    refreshLegacyEsxPlayerInventories()
end

local function refreshEsxItems()
    if type(ESX.RefreshItems) == "function" then
        ESX.RefreshItems()
        return
    end
    refreshLegacyEsxItems()
end

local function normalizeEsxWeaponName(weaponName)
    if type(weaponName) ~= "string" then
        return weaponName
    end
    return string.upper(weaponName)
end

---@description Registers an ESX usable item callback.
---@param name string
---@param callback function|nil
---@return boolean
function Sky.FW.RegisterUsableItem(name, callback)
    ESX.RegisterUsableItem(name, callback)
    return true
end

---@description Adds or updates an ESX item and refreshes online player inventories once per tick.
---@param definition table
---@param options? table
---@return boolean
function Sky.FW.RegisterItem(definition, options)
    if type(definition) ~= "table" or type(definition.name) ~= "string" or definition.name == "" then
        return false
    end

    local items = getEsxItems()
    local existing = items[definition.name]
    if type(existing) == "table" and type(options) == "table" and options.preserveExisting == true then
        return true
    end
    if type(existing) == "table" then
        for key, value in pairs(definition) do
            existing[key] = value
        end
    else
        items[definition.name] = definition
    end

    if Sky.Config.inventory == "esx" and not itemRefreshQueued then
        itemRefreshQueued = true
        SetTimeout(0, function()
            if not itemRefreshQueued then return end
            itemRefreshQueued = false
            refreshEsxItems()
        end)
    end
    return true
end

---@description Reloads persisted ESX items and updates every online player inventory.
---@return boolean
function Sky.FW.RefreshItems()
    if Sky.Config.inventory ~= "esx" then
        return true
    end
    itemRefreshQueued = false
    refreshEsxItems()
    return true
end

---@description Adds an item to the player's inventory when they can carry it.
---@param source number
---@param item string
---@param amount number
---@param slot? number
---@param metadata? table
---@return boolean
function Sky.FW.AddItem(source, item, amount, slot, metadata)
    if slot then print("ESX does not support item slots, please ensure you are using a supported inventory system or that you have the correct start order.") end
    if metadata then print("ESX does not support item metadata, please ensure you are using a supported inventory system or that you have the correct start order.") end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    if xPlayer.canCarryItem(item, amount) then
        xPlayer.addInventoryItem(item, amount)
        return true
    end
    return false
end

---@description Removes an item from the player's inventory and returns the amount removed.
---@param source number
---@param item string
---@param amount number
---@param slot? number
---@param metadata? table
---@return number
function Sky.FW.RemoveItem(source, item, amount, slot, metadata)
    if slot then print("ESX does not support item slots, please ensure you are using a supported inventory system or that you have the correct start order.") end
    if metadata then print("ESX does not support item metadata, please ensure you are using a supported inventory system or that you have the correct start order.") end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end

    local playerItem = xPlayer.getInventoryItem(item)
    if playerItem then
        if playerItem.count > amount then
            xPlayer.removeInventoryItem(item, amount)
            return amount
        end
        xPlayer.removeInventoryItem(item, playerItem.count)
        return playerItem.count
    end
    return 0
end

---@description Checks whether the player can carry the given amount of an item.
---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@return boolean
function Sky.FW.CanCarryItem(source, item, amount, metadata)
    if metadata then print("ESX does not support item metadata, please ensure you are using a supported inventory system or that you have the correct start order.") end

    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer.canCarryItem(item, amount)
end

---@description Checks whether the player has at least the given amount of an item.
---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@return boolean
function Sky.FW.HasItem(source, item, amount, metadata)
    amount = amount or 1
    if metadata then print("ESX does not support item metadata, please ensure you are using a supported inventory system or that you have the correct start order.") end
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventoryItem = xPlayer.getInventoryItem(item)
    if inventoryItem == nil then
        return false
    end
    return inventoryItem.count >= amount
end

---@description Returns the player's inventory as a list of normalized item tables.
---@param source number
---@return table
function Sky.FW.GetInventoryItems(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end

    local items = {}
    for _, item in pairs(xPlayer.getInventory()) do
        if item.count > 0 then
            local normalizedItem = {
                name = item.name,
                label = H.ResolveItemLabel(item.label or item.name, item.metadata or item.info),
                amount = item.count
            }
            local metadata = H.NormalizeMetadata(item.metadata or item.info)
            if metadata then
                normalizedItem.metadata = metadata
            end
            items[#items + 1] = normalizedItem
        end
    end
    return items
end

---@description Returns a single normalized inventory item, or nil when the player lacks it.
---@param source number
---@param item string
---@param metadata? table
---@return table|nil
function Sky.FW.GetInventoryItem(source, item, metadata)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerItem = xPlayer.getInventoryItem(item)
    if playerItem == nil then
        return nil
    end
    return {
        name = playerItem.name,
        label = H.ResolveItemLabel(playerItem.label or playerItem.name, playerItem.metadata or playerItem.info),
        amount = playerItem.count,
        metadata = H.NormalizeMetadata(playerItem.metadata or playerItem.info)
    }
end

---@description Returns the framework's shared item definitions table.
---@return table
function Sky.FW.GetItems()
    return getEsxItems()
end

---@description Returns the display label for an item, falling back to its name.
---@param item string
---@return string
function Sky.FW.GetItemLabel(item)
    local definition = getEsxItems()[item]
    return definition and definition.label or item
end

---@description Checks whether the player can carry the given weapon.
---@param source number
---@param weaponName string
---@param metadata? table
---@return boolean
function Sky.FW.CanCarryWeapon(source, weaponName, metadata)
    local xPlayer = ESX.GetPlayerFromId(source)
    local normalizedWeaponName = normalizeEsxWeaponName(weaponName)
    local _, definition = ESX.GetWeapon(normalizedWeaponName)
    if not definition then
        Sky.Debug("error", "[inventory] Unknown ESX weapon: %s", normalizedWeaponName)
        return false
    end
    return not xPlayer.hasWeapon(normalizedWeaponName)
end

---@description Adds a weapon with ammo to the player when they don't already have it.
---@param source number
---@param weaponName string
---@param ammo number
---@param metadata? table
---@return boolean
function Sky.FW.AddWeapon(source, weaponName, ammo, metadata)
    local xPlayer = ESX.GetPlayerFromId(source)
    local normalizedWeaponName = normalizeEsxWeaponName(weaponName)
    local _, definition = ESX.GetWeapon(normalizedWeaponName)
    if not definition then
        Sky.Debug("error", "[inventory] Unknown ESX weapon: %s", normalizedWeaponName)
        return false
    end
    if not xPlayer.hasWeapon(normalizedWeaponName) then
        xPlayer.addWeapon(normalizedWeaponName, ammo)
        if not xPlayer.hasWeapon(normalizedWeaponName) then return false end
        for _, component in ipairs(metadata and metadata.components or {}) do
            xPlayer.addWeaponComponent(normalizedWeaponName, component)
        end
        if metadata and metadata.tintIndex ~= nil then
            xPlayer.setWeaponTint(normalizedWeaponName, metadata.tintIndex)
        end
        return true
    end
    return false
end

---@description Removes a weapon from the player when they have it.
---@param source number
---@param weaponName string
---@param metadata? table
---@return boolean
function Sky.FW.RemoveWeapon(source, weaponName, metadata)
    local xPlayer = ESX.GetPlayerFromId(source)
    local normalizedWeaponName = normalizeEsxWeaponName(weaponName)
    if xPlayer.hasWeapon(normalizedWeaponName) then
        xPlayer.removeWeapon(normalizedWeaponName)
        return true
    end
    return false
end

---@description Returns the player's weapon loadout as a list of normalized weapon tables.
---@param source number
---@return table
function Sky.FW.GetWeapons(source)
    local weapons = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not xPlayer.getLoadout then
        return weapons
    end

    for _, weapon in pairs(xPlayer.getLoadout()) do
        weapons[#weapons + 1] = {
            name = weapon.name,
            label = weapon.label,
            ammo = weapon.ammo,
            components = weapon.components,
            tintIndex = weapon.tintIndex
        }
    end
    return weapons
end
