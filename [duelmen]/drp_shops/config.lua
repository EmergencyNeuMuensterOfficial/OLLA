DRPShops = {}

DRPShops.GasInventory = {
    { name = 'water', price = 6, count = 100 },
    { name = 'sprunk', price = 8, count = 100 },
    { name = 'burger', price = 12, count = 75 },
    { name = 'bandage', price = 45, count = 35 },
}

DRPShops.PhoneInventory = {
    { name = 'phone', price = 550, count = 25 },
    { name = 'sky_phone_sim_registered', price = 35, count = 100 },
    { name = 'sky_phone_sim_anonymous', price = 120, count = 40 },
}

-- Vanilla ped models; no extra clothing or ped resource is required.
DRPShops.GasClerkModel = 'mp_m_shopkeep_01'
DRPShops.PhoneClerkModel = 'a_m_y_business_01'

-- The checkout positions at fuel stations, not the fuel-pump positions.
DRPShops.GasLocations = {
    vector3(-47.32, -1758.67, 29.42),
    vector3(288.7172, -1266.8352, 29.4407),
    vector3(814.6193, -1040.2697, 26.7508),
    vector3(1208.96, -1402.47, 35.22),
    vector3(1181.37, -330.85, 69.32),
    vector3(620.84, 269.10, 103.09),
    vector3(2581.00, 362.11, 108.47),
    vector3(176.63, 6602.04, 31.85),
    vector3(1784.32, 3330.55, 41.25),
    vector3(-2554.00, 2334.40, 33.08),
    vector3(-1800.00, 803.00, 138.70),
}

DRPShops.PhoneLocations = {
    vector3(104.3436, -213.1277, 54.6361),
}

-- Kept separately so ox_inventory receives its expected vector3 locations.
DRPShops.PhoneHeadings = {
    55.8514,
}
