Locales = {} -- edit translation in config/locales
Config = {}

-- Documentation: https://docs.sky-systems.net/docs/scripts/banking
Config.UseBilling = false -- no ESX/QBCore billing resource is installed on Dülmen Roleplay
Config.ESXCoreResource = "es_extended" -- ONLY ESX
Config.QBCoreResource = "qb-core" -- ONLY QBCore

-- YOUR CHANGES HERE:
-- Choose your billing system.
-- ESX values: 'esx_billing', 'okokbilling', 'loaf_billing'
-- QBCore values: 'g_billing'
Config.BillingSystem = 'okokbilling' -- Choose your script here

-- !! IMPORTANT !!
-- Choose the mode for your script:
-- 'data': Shows invoices INSIDE the bank (esx_billing, loaf_billing, old okokbilling)
-- 'menu': Closes the bank and opens its OWN menu (g-billing, new okokbilling)
Config.BillingMode = 'menu' -- Set this to 'menu' for g-billing or your new okokbilling

Config.UseSounds = true
Config.UseATMs = true

Config.Blips = {
    Bank = {
        showBlip = true,
        blip = {
            name = "Bank",
            sprite = 108,
            color = 2
        },
    },
}

Config.Locations = {
    Bank = {
        {x = 150.266, y = -1040.203, z = 29.374},
        {x = -1212.98, y = -330.841, z = 37.787},
        {x = -2962.582, y = 482.627, z = 15.703},
        {x = -112.202, y = 6469.295, z = 31.626},
        {x = 314.187, y = -278.621, z = 54.17},
        {x = -351.534, y = -49.529, z = 49.042},
        {x = 241.727, y = 220.706, z = 106.286},
        {x = 1175.064, y = 2706.643, z = 38.094}
    },
}
