fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dülmen Roleplay'
description 'German job creator, boss menu and wardrobe system'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql',
    'drp_core',
    'drp_aduty',
}
