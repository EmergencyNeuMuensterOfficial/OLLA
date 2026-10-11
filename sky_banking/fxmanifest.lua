fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Sky-Systems'
description 'Banking'
version '1.2.0'

escrow_ignore 'config/**'

shared_script '@sky_base/source/import.lua'

client_scripts {
	'@sky_base/source/client/modules/Ped.lua',
	'@sky_base/source/client/modules/Vehicle.lua',
	'config/config.lua',
	'config/locales/*.lua',
	'source/client/*.lua',
}

server_scripts {
	'config/*.lua',
	'config/locales/*.lua',
	'source/server/*.lua',
}

files {
	'config/img/**',
	'config/style.css',
	'source/html/index.html',
	'source/html/assets/*.*',
}

ui_page 'source/html/index.html'

dependency 'sky_base'
dependency '/assetpacks'