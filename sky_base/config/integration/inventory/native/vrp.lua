---@diagnostic disable: duplicate-set-field, deprecated
-- Framework-native VRP inventory. Base layer for VRP servers. Guarded on the framework.
-- Legacy vRP uses kilograms and strength-based carrying capacity.
if Sky.Config.framework ~= "vrp" then return end
if not IsDuplicityVersion() then return end

local itemsConfig = module("vrp", "cfg/items")

if Sky.Config.inventory == "vrp" then
    function Sky.FW.GetInventoryStats(source)
        local user_id = vRP.getUserId({ source })
        if not user_id then
            Sky.Debug("error", "[inventory] vRP statistics unavailable: player %s is not loaded", source)
            return nil, "unavailable"
        end
        return SkyInventoryHelpers.NormalizeInventoryStats(vRP.getInventoryWeight({ user_id }),
            vRP.getInventoryMaxWeight({ user_id }), nil, nil, 1)
    end
end

---@description Registers a VRP usable item callback.
---@param name string
---@param callback function|nil
function Sky.FW.RegisterUsableItem(name, callback)
    vRP.defInventoryItem(name, name, "Custom desc", function()
        if not callback then return {} end
        return {
            ["Use"] = {
                function(player)
                    callback(player, { name = name })
                end
            }
        }
    end, 0.5)
end

---@description Adds an item to the player's VRP inventory.
---@param source number
---@param item string
---@param amount number
---@param slot? number
---@param metadata? table
---@return boolean
function Sky.FW.AddItem(source, item, amount, slot, metadata)
    if source == nil then return false end
    local user_id = vRP.getUserId({source})
    return vRP.giveInventoryItem({user_id, item, amount, true})
end

---@description Removes an item from the player's VRP inventory and returns the amount removed.
---@param source number
---@param item string
---@param amount number
---@param slot? number
---@param metadata? table
---@return number
function Sky.FW.RemoveItem(source, item, amount, slot, metadata)
    if source == nil then return 0 end
    local user_id = vRP.getUserId({source})
    local removed = vRP.tryGetInventoryItem({user_id, item, amount, true})
    return removed and amount or 0
end

---@description Checks whether the player has at least the given amount of an item.
---@param source number
---@param item string
---@param amount number
---@return boolean
function Sky.FW.HasItem(source, item, amount)
    if source == nil then return false end
    amount = tonumber(amount) or 1
    local user_id = vRP.getUserId({source})
    return (vRP.getInventoryItemAmount({user_id, item, true}) or 0) >= amount
end

---@description Returns the player's VRP inventory table.
---@param source number
---@return table
function Sky.FW.GetInventoryItems(source)
    if source == nil then return {} end
    local user_id = vRP.getUserId({source})
    local data = vRP.getUserDataTable({user_id})
    return data and data.inventory or {}
end

---@description Returns the amount the player holds of a single item.
---@param source number
---@param item string
---@return number|nil
function Sky.FW.GetInventoryItem(source, item)
    if source == nil then return nil end
    local user_id = vRP.getUserId({source})
    return vRP.getInventoryItemAmount({user_id, item, true})
end

---@description Returns the framework's shared item definitions table.
---@return table
function Sky.FW.GetItems()
    if vRP and vRP.items then
        return vRP.items
    end
    if itemsConfig then
        return itemsConfig.items or itemsConfig
    end
    return {}
end

---@description Returns the display label for an item.
---@param item string
---@return string
function Sky.FW.GetItemLabel(item)
    return vRP.getItemName({item})
end
