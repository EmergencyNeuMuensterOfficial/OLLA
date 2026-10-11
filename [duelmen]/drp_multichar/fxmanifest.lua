fx_version "cerulean"
game "gta5"

author "SwisserAI"
description "Generated with SwisserAI - https://ai.swisser.dev"
version "1.0.0"

shared_scripts {
    "config/config.lua",
    "shared/main.lua"
}

client_scripts {
    "main.lua",
    "nui.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/database.lua",
    "server/main.lua"
}

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/style.css",
    "html/js/characters.js",
    "html/js/app.js",
    "html/tailwind.css",
    "html/fonts/*.woff2",
    "html/fonts.css"
}

dependencies {
    "oxmysql",
    "drp_core",
    "ox_inventory"
}
