DRPGarages = {}

DRPGarages.PlayerGarages = {
    {
        id = 'legion', label = 'Legion Square Garage',
        coords = vec3(215.74, -810.12, 30.73),
        spawn = vec4(229.37, -800.02, 30.57, 157.0),
        blip = vec3(215.74, -810.12, 30.73),
    },
    {
        id = 'pillbox', label = 'Pillbox Garage',
        coords = vec3(298.42, -600.43, 43.28),
        spawn = vec4(291.35, -611.29, 43.22, 70.0),
        blip = vec3(298.42, -600.43, 43.28),
    },
    {
        id = 'sandy', label = 'Sandy Shores Garage',
        coords = vec3(1737.55, 3710.08, 34.14),
        spawn = vec4(1731.13, 3710.88, 34.14, 20.0),
        blip = vec3(1737.55, 3710.08, 34.14),
    },
}

-- Add job fleets here. "minGrade" is the minimum job grade permitted to use
-- the garage. Vehicle entries use GTA/FiveM spawn names.
DRPGarages.JobGarages = {
    {
        id = 'police_missionrow', label = 'LSPD Fahrzeughalle', job = 'police', minGrade = 0,
        coords = vec3(452.04, -1017.38, 28.45),
        spawn = vec4(438.53, -1018.45, 28.65, 90.0),
        vehicles = {
            { model = 'police', label = 'Vapid Police Cruiser' },
            { model = 'rhinehartpol', label = 'LSPD Rhinehart' },
            { model = 'imperialdepol', label = 'Polizei Imperial' },
        },
    },
    {
        id = 'ambulance_pillbox', label = 'Rettungsdienst Fahrzeughalle', job = 'ambulance', minGrade = 0,
        coords = vec3(307.36, -596.15, 43.28),
        spawn = vec4(294.04, -608.47, 43.23, 70.0),
        vehicles = {
            { model = 'ambulance', label = 'Ambulance' },
        },
    },
}

DRPGarages.StoreDistance = 16.0
