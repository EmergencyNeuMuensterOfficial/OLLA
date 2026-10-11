fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dülmen Roleplay'
description 'Permission based staff duty outfits'
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
    'oxmysql',
}
