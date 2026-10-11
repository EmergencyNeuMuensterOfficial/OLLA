fx_version 'cerulean'
game 'gta5'

author 'Dülmen Roleplay'
description 'Custom standalone HUD for Dülmen Roleplay'
version '0.1.0'

lua54 'yes'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}

shared_script '@ox_lib/init.lua'

server_script 'server/main.lua'
client_script 'client/main.lua'

dependencies {
    'ox_lib',
    'ox_inventory',
    'drp_core',
    'drp_multichar'
}
