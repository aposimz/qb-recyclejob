fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot'
description 'Allows players to work in the recycling plant for money'
version '2.2.0'

dependencies {
  'ox_inventory' -- Ensure ox_inventory loads before this resource
}

shared_scripts {
  '@qb-core/shared/locale.lua',
  'locales/ja.lua',
  'locales/*.lua',
  'config.lua'
}

client_script {
  'client/main.lua',
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/CircleZone.lua'
}

server_script 'server/main.lua'
