DeriveGamemode('base')

--[[---------------------------------------------------------
   Gamemode info
---------------------------------------------------------]]--
GM.Name      = 'Last Prop Standing'
GM.Author    = 'Nerdism'
GM.Email     = 'nerdism.io@gmail.com'
GM.Website   = 'https://github.com/wsglua/lastprop/'
GM.TeamBased = true

--[[---------------------------------------------------------
   Include Shared
---------------------------------------------------------]]--
include('sh_globals.lua')
include('sh_config.lua')
include('sh_util.lua')
include('meta/sh_player.lua')
include('meta/sh_entity.lua')
include('sh_round.lua')
include('sh_team.lua')
include('sh_player.lua')
include('sh_sound.lua')
include('classes/cls_default.lua')
include('classes/cls_hunter.lua')
include('classes/cls_prop.lua')