fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dülmen Roleplay'
description 'Gas station and phone shops for Dülmen Roleplay'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'ox_inventory',
    'ox_lib',
    'ox_target',
    'sky_phone'
}
