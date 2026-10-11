ADuty = {}

-- Permission groups. A staff member may only assign a group below their own.
ADuty.Groups = {
    supporter = { label = 'Supporter', level = 1 },
    moderation = { label = 'Moderation', level = 2 },
    administration = { label = 'Administration', level = 3 },
    heads = { label = 'Heads', level = 4 },
    headteam = { label = 'Head-Team', level = 5 },
}

-- These are the exact Discord staff ranks. They are mapped to the five
-- permission groups above when using /staffrank.
ADuty.Ranks = {
    testsupporter = { label = 'Test Supporter', group = 'supporter' },
    juniorsupporter = { label = 'Junior Supporter', group = 'supporter' },
    supporter = { label = 'Supporter', group = 'supporter' },
    seniorsupporter = { label = 'Senior Supporter', group = 'supporter' },

    juniormoderator = { label = 'Junior Moderator', group = 'moderation' },
    moderator = { label = 'Moderator', group = 'moderation' },
    seniormoderator = { label = 'Senior Moderator', group = 'moderation' },

    junioradmin = { label = 'Junior Admin', group = 'administration' },
    admin = { label = 'Admin', group = 'administration' },
    senioradmin = { label = 'Senior Admin', group = 'administration' },

    headsupporter = { label = 'Head Supporter', group = 'heads' },
    headmoderator = { label = 'Head Moderator', group = 'heads' },
    headadmin = { label = 'Head Admin', group = 'heads' },

    stvteamleitung = { label = 'Stv. Teamleitung', group = 'headteam' },
    teamleitung = { label = 'Teamleitung', group = 'headteam' },
    manager = { label = 'Manager', group = 'headteam' },
    stvprojektverwaltung = { label = 'Stv. Projektverwaltung', group = 'headteam' },
    projektverwaltung = { label = 'Projektverwaltung', group = 'headteam' },
    stvprojektleitung = { label = 'Stv. Projektleitung', group = 'headteam' },
    projektleitung = { label = 'Projektleitung', group = 'headteam' },
    stvprojektinhaber = { label = 'Stv. Projektinhaber', group = 'headteam' },
    projektinhaber = { label = 'Projektinhaber', group = 'headteam' },
}

ADuty.Roles = {
    supporter = {
        label = 'Supporter', description = 'Grüner Staff-Anzug', colour = '#22c55e',
        outfit = 'support', minimumGroup = 'supporter',
    },
    moderator = {
        label = 'Moderator', description = 'Blauer Staff-Anzug', colour = '#3b82f6',
        outfit = 'mod', minimumGroup = 'moderation',
    },
    administrator = {
        label = 'Administrator', description = 'Roter Staff-Anzug', colour = '#ef4444',
        outfit = 'superadmin', minimumGroup = 'administration',
    },
    teamleitung = {
        label = 'Teamleitung', description = 'Pink-Weißer Staff-Anzug', colour = '#ec4899',
        outfit = 'dev', minimumGroup = 'heads',
    },
    manager = {
        label = 'Manager', description = 'Goldener Staff-Anzug', colour = '#f59e0b',
        outfit = 'admin', minimumGroup = 'headteam',
    },
    projektleitung = {
        label = 'Projektleitung', description = 'Grauer Staff-Anzug', colour = '#94a3b8',
        outfit = 'projektleitung', minimumGroup = 'headteam',
    },
    projektinhaber = {
        label = 'Projektinhaber', description = 'Gold-Weiß-Grauer Owner-Anzug', colour = '#d4af37',
        outfit = 'projektinhaber', minimumGroup = 'headteam',
    },
}

-- Supplied staff uniforms.  Hair is intentionally excluded so a player's
-- custom hairstyle and face stay intact while on duty.
ADuty.Outfits = {
    projektinhaber = {
        male = { tshirt = { 15, 0 }, torso = { 287, 7 }, decals = { 0, 0 }, arms = { 3, 0 }, pants = { 114, 7 }, shoes = { 78, 7 }, mask = { 135, 7 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, hair = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
        female = { tshirt = { 15, 0 }, torso = { 300, 7 }, decals = { 0, 0 }, arms = { 8, 0 }, pants = { 121, 7 }, shoes = { 82, 7 }, mask = { 153, 7 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, hair = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
    },
    projektleitung = {
        male = { tshirt = { 15, 0 }, torso = { 287, 6 }, decals = { 0, 0 }, arms = { 3, 0 }, pants = { 114, 6 }, shoes = { 78, 6 }, mask = { 135, 6 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
        female = { tshirt = { 15, 0 }, torso = { 300, 6 }, decals = { 0, 0 }, arms = { 8, 0 }, pants = { 121, 6 }, shoes = { 82, 6 }, mask = { 153, 6 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
    },
    superadmin = {
        male = { tshirt = { 15, 0 }, torso = { 287, 2 }, decals = { 0, 0 }, arms = { 3, 0 }, pants = { 114, 2 }, shoes = { 78, 2 }, mask = { 135, 2 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
        female = { tshirt = { 15, 0 }, torso = { 300, 2 }, decals = { 0, 0 }, arms = { 8, 0 }, pants = { 121, 2 }, shoes = { 82, 2 }, mask = { 153, 2 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
    },
    admin = {
        male = { tshirt = { 15, 0 }, torso = { 287, 3 }, decals = { 0, 0 }, arms = { 3, 0 }, pants = { 114, 3 }, shoes = { 78, 3 }, mask = { 135, 3 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
        female = { tshirt = { 15, 0 }, torso = { 300, 3 }, decals = { 0, 0 }, arms = { 8, 0 }, pants = { 121, 3 }, shoes = { 82, 3 }, mask = { 153, 3 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
    },
    mod = {
        male = { tshirt = { 15, 0 }, torso = { 287, 4 }, decals = { 0, 0 }, arms = { 3, 0 }, pants = { 114, 4 }, shoes = { 78, 4 }, mask = { 135, 4 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
        female = { tshirt = { 15, 0 }, torso = { 300, 4 }, decals = { 0, 0 }, arms = { 8, 0 }, pants = { 121, 4 }, shoes = { 82, 4 }, mask = { 153, 4 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
    },
    dev = {
        male = { tshirt = { 15, 0 }, torso = { 287, 9 }, decals = { 0, 0 }, arms = { 3, 0 }, pants = { 114, 9 }, shoes = { 78, 9 }, mask = { 135, 9 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
        female = { tshirt = { 15, 0 }, torso = { 300, 9 }, decals = { 0, 0 }, arms = { 8, 0 }, pants = { 121, 9 }, shoes = { 82, 9 }, mask = { 153, 9 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
    },
    support = {
        male = { tshirt = { 15, 0 }, torso = { 287, 5 }, decals = { 0, 0 }, arms = { 3, 0 }, pants = { 114, 5 }, shoes = { 78, 5 }, mask = { 135, 5 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
        female = { tshirt = { 15, 0 }, torso = { 300, 5 }, decals = { 0, 0 }, arms = { 8, 0 }, pants = { 121, 5 }, shoes = { 82, 5 }, mask = { 153, 5 }, chain = { 0, 0 }, bags = { 0, 0 }, bproof = { 0, 0 }, helmet = { -1, 0 }, ears = { 0, 0 } },
    },
}
