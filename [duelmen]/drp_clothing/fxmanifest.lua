fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dülmen Roleplay'
description 'Character clothing shops and persistent civilian outfits'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_script 'client.lua'
server_script '@oxmysql/lib/MySQL.lua'
server_script 'server.lua'

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql',
    'drp_core'
}
