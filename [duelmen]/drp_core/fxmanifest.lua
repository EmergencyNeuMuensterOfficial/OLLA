fx_version 'cerulean'
game 'gta5'

author 'Dülmen Roleplay'
description 'Core framework for Dülmen Roleplay'
version '0.1.0'

lua54 'yes'

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/callbacks.lua',
    'server/players.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'oxmysql',
    'ox_target'
}
