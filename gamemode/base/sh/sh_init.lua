DeriveGamemode('base')

--[[---------------------------------------------------------
   Include Shared
---------------------------------------------------------]]--
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


--[[---------------------------------------------------------
   Gamemode info
---------------------------------------------------------]]--
GM.Name      = 'Last Prop Standing'
GM.Author    = 'Nerdism'
GM.Email     = 'nerdism.io@gmail.com'
GM.Website   = 'https://github.com/wsglua/lastprop/'
GM.TeamBased = true

--[[---------------------------------------------------------
--   Name: GM:CanStartGame()
---------------------------------------------------------]]--
function GM:CanStartGame()
    if (team.NumPlayers(TEAM.PROPS) >= 1 and team.NumPlayers(TEAM.HUNTERS) >= 1) then
        return true
    end
    return false
end

--[[---------------------------------------------------------
--   Name: GM:InPreGame()
---------------------------------------------------------]]--
function GM:InPreGame(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InPreGame', bool)
    else
        return GetGlobalBool('InPreGame', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:InGame()
---------------------------------------------------------]]--
function GM:InGame(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InGame', bool)
    else
        return GetGlobalBool('InGame', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:InPostGame()
---------------------------------------------------------]]--
function GM:InPostGame(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InPostGame', bool)
    else
        return GetGlobalBool('InPostGame', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:GameStartTime()
---------------------------------------------------------]]--
function GM:GameStartTime(float)
    if (float ~= nil and SERVER) then
        SetGlobalFloat('GameStartTime', float)
    else
        return GetGlobalFloat('GameStartTime', CurTime())
    end
end

--[[---------------------------------------------------------
--   Name: GM:GameStartTime()
---------------------------------------------------------]]--
function GM:Paused(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('Paused', bool)
    else
        return GetGlobalBool('Paused', false)
    end
end