---@diagnostic disable: duplicate-set-field
-- Framework-native Qbox inventory (qbx_core + ox_inventory, which Qbox bundles). Active when no
-- standalone inventory is selected; provides fallbacks otherwise. Guarded on the framework.
if Sky.Config.framework ~= "qbox" then return end
if not IsDuplicityVersion() then return end

local H = SkyInventoryHelpers
if Sky.Config.inventory == "qbox" then
    Sky.FW.InventoryCapabilities = { itemMetadata = true }
    function Sky.FW.GetInventoryStats(source)
        local inventory = exports.ox_inventory:GetInventory(source)
        if not inventory then
            Sky.Debug("error", "[inventory] Qbox statistics unavailable: player %s inventory is not loaded", source)
            return nil, "unavailable"
        end
        return H.NormalizeInventoryStats(inventory.weight, inventory.maxWeight,
            H.CountOccupiedSlots(inventory.items), inventory.slots, 1000)
    end
end

---@description Confirms existing Qbox/ox_inventory items; new definitions must be loaded from data/items.lua.
---@param definition table
---@param options? table
---@return boolean
function Sky.FW.RegisterItem(definition, options)
    if type(definition) ~= "table" or type(definition.name) ~= "string" or definition.name == "" then
        return false
    end

    if exports.ox_inventory:Items(definition.name) then
        return true
    end

    Sky.Debug(
        "debug",
        "[inventory] RegisterItem cannot add missing Qbox item '%s'; add it to ox_inventory/data/items.lua and restart the inventory.",
        definition.name
    )
    return false
end

---@description Register a usable item with the framework so its callback fires on use.
---@param name string
---@param callback function
function Sky.FW.RegisterUsableItem(name, callback)
    exports.qbx_core:CreateUseableItem(name, callback)
end

---@description Add an item to a player's inventory.
---@param source number
---@param item string
---@param amount number
---@param slot? number
---@param metadata? table
---@return boolean
function Sky.FW.AddItem(source, item, amount, slot, metadata)
    local xPlayer = exports.qbx_core:GetPlayer(source)
    if not xPlayer then return false end
    return xPlayer.Functions.AddItem(item, amount, slot, H.NormalizeMetadata(metadata))
end

---@description Remove an item from a player's inventory; returns the amount actually removed.
---@param source number
---@param item string
---@param amount number
---@param slot? number
---@param metadata? table
---@return number
function Sky.FW.RemoveItem(source, item, amount, slot, metadata)
    local xPlayer = exports.qbx_core:GetPlayer(source)
    if not xPlayer then return 0 end

    if slot then
        xPlayer.Functions.RemoveItem(item, amount, slot)
        return amount
    end

    local expectedMetadata = H.NormalizeMetadata(metadata)
    if expectedMetadata then
        local playerItem
        for _, inventoryItem in pairs(xPlayer.PlayerData.items or {}) do
            if inventoryItem and inventoryItem.name == item then
                if H.MetadataMatches(inventoryItem.metadata or inventoryItem.info, expectedMetadata) then
                    playerItem = inventoryItem
                    break
                end
            end
        end
        if not playerItem then return 0 end

        if playerItem.count > amount then
            xPlayer.Functions.RemoveItem(item, amount, playerItem.slot)
            return amount
        end
        xPlayer.Functions.RemoveItem(item, playerItem.count, playerItem.slot)
        return playerItem.count
    end

    xPlayer.Functions.RemoveItem(item, amount)
    return amount
end

---@description Check whether a player can carry the given amount of an item.
---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@return boolean
function Sky.FW.CanCarryItem(source, item, amount, metadata)
    return exports.ox_inventory:CanCarryItem(source, item, amount, metadata)
end

---@description Check whether a player has at least the given amount of an item.
---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@return boolean
function Sky.FW.HasItem(source, item, amount, metadata)
    amount = amount or 1
    local xPlayer = exports.qbx_core:GetPlayer(source)
    local foundItem = xPlayer.Functions.GetItemByName(item)
    if foundItem == nil then return false end
    return foundItem.count >= amount
end

---@description Get all items in a player's inventory as normalized entries.
---@param source number
---@return table
function Sky.FW.GetInventoryItems(source)
    local items = {}
    for _, item in pairs(exports.ox_inventory:GetInventoryItems(source) or {}) do
        if item.count and item.count > 0 then
            local normalizedItem = {
                slot = tonumber(item.slot),
                name = item.name,
                label = H.ResolveItemLabel(item.label or item.name, item.metadata),
                amount = item.count
            }
            local metadata = H.NormalizeMetadata(item.metadata)
            if metadata then
                normalizedItem.metadata = metadata
            end
            items[#items + 1] = normalizedItem
        end
    end
    return items
end

---@description Get a single item from a player's inventory by name.
---@param source number
---@param item string
---@param metadata? table
---@return table|nil
function Sky.FW.GetInventoryItem(source, item, metadata)
    local xPlayer = exports.qbx_core:GetPlayer(source)
    local playerItem = xPlayer.Functions.GetItemByName(item)
    if not playerItem then return nil end
    return {
        name = playerItem.name,
        label = H.ResolveItemLabel(playerItem.label or playerItem.name, playerItem.metadata),
        amount = playerItem.count,
        metadata = H.NormalizeMetadata(playerItem.metadata or playerItem.info)
    }
end

---@description Set the metadata of the item in the given slot (Qbox ships ox_inventory, which exposes a direct setter).
---@param source number
---@param slotId number
---@param metadata? table
---@return boolean
function Sky.FW.SetInventorySlotMetadata(source, slotId, metadata)
    local numericSlot = tonumber(slotId)
    if not numericSlot then
        return false
    end
    exports.ox_inventory:SetMetadata(source, numericSlot, metadata or {})
    return true
end

---@description Get the framework's shared item definitions table.
---@return table
function Sky.FW.GetItems()
    return exports.ox_inventory:Items()
end

---@description Get the display label for an item, falling back to its name.
---@param item string
---@return string
function Sky.FW.GetItemLabel(item)
    local oxItem = exports.ox_inventory:Items(item)
    return oxItem and oxItem.label or item
end

---@description Check whether a player can carry the given weapon.
---@param source number
---@param weaponName string
---@param metadata? table
---@return boolean
function Sky.FW.CanCarryWeapon(source, weaponName, metadata)
    return exports.ox_inventory:CanCarryItem(source, weaponName, 1, metadata)
end

---@description Add a weapon to a player's inventory.
---@param source number
---@param weaponName string
---@param ammo number
---@param metadata? table
---@return boolean
function Sky.FW.AddWeapon(source, weaponName, ammo, metadata)
    return exports.ox_inventory:AddItem(source, weaponName, 1, metadata or { ammo = ammo })
end

---@description Remove a weapon from a player's inventory.
---@param source number
---@param weaponName string
---@param metadata? table
---@return boolean
function Sky.FW.RemoveWeapon(source, weaponName, metadata)
    return exports.ox_inventory:RemoveItem(source, weaponName, 1, metadata) == true
end

---@description Get all weapons currently in a player's inventory.
---@param source number
---@return table
function Sky.FW.GetWeapons(source)
    local weapons = {}
    local xPlayer = exports.qbx_core:GetPlayer(source)
    if not xPlayer or not xPlayer.PlayerData then
        return weapons
    end

    for _, item in pairs(xPlayer.PlayerData.items or {}) do
        local name = item.name
        if name and item.count and item.count > 0 then
            local isWeapon = item.type == "weapon" or string.sub(string.lower(name), 1, 7) == "weapon_"
            if isWeapon then
                weapons[#weapons + 1] = {
                    name = name,
                    label = item.label,
                    amount = item.count,
                    ammo = item.info and item.info.ammo or nil
                }
            end
        end
    end
    return weapons
end
