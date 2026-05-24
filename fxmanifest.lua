fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot'
description 'Allows players to work in the recycling plant for money'
version '2.2.0'

dependencies {
    'ox_inventory',
}

shared_scripts {
  '@qb-core/shared/locale.lua',
  'locales/ja.lua',
  'locales/*.lua',
  'config.lua'
}

client_script {
  'client.lua',
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/CircleZone.lua'
}

server_script 'server.lua'
