local function registerShops()
    exports.ox_inventory:RegisterShop('drp_gas', {
        name = 'Dülmen Tankstelle',
        inventory = DRPShops.GasInventory,
        locations = DRPShops.GasLocations,
    })

    exports.ox_inventory:RegisterShop('drp_phone', {
        name = 'Dülmen Phone Shop',
        inventory = DRPShops.PhoneInventory,
        locations = DRPShops.PhoneLocations,
    })
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        registerShops()
    end
end)
