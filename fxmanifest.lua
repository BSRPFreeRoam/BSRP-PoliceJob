fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'bsrp-policejob'
author 'BS Race'
description 'BSRP Police Job — LEO tools, interactions, stations (no qb-core)'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/fw.lua',
}

client_scripts {
    'client/main.lua',
    'client/job.lua',
    'client/interactions.lua',
    'client/objects.lua',
    'client/evidence.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/interactions.lua',
    'server/commands.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

-- Hard deps only. ps-dispatch / ps-mdt are optional soft hooks (never listed here).
dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'bsrp',
}
