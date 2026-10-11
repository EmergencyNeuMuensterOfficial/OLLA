fx_version 'cerulean'
game 'gta5'

author 'Dülmen Roleplay'
description 'Character creation and selection for Dülmen Roleplay'
version '0.1.0'

lua54 'yes'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'drp_core',
    'ox_inventory'
}
