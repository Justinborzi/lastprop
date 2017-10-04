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
   Gamemode config
---------------------------------------------------------]]--
GM.config = {
    ['pregame_time']              = 60,               -- Time to wait before starting game.
    ['pregame_deathmatch']        = true,             -- Rocket deathmatch before game starts or while waiting for players to join

    ['round_limit']               = 5,                -- Round limit
    ['round_time']                = 300,              -- Round time
    ['preround_time']             = 60,               -- Pre round time (This is the amount of time the hunter are blinded and props get to find a hinding spot)
    ['postround_time']            = 15,               -- Post round time
    ['postround_deathmatch']      = true,             -- Give everyone rocket launchers to kill eachother

    ['death_linger_time']         = 5,                -- Amount of time to linger in the deathcam/freezecam
    ['death_freezecam']           = true,             -- Enables freeze cam

    ['team_switch_delay']         = 5,                -- Delay for players to join a new team
    ['team_force_balance']        = true,             -- Force team balance
    ['team_auto_balance']         = true,             -- Auto balance teams
    ['team_swap']                 = true,             -- Swap teams on each round

    ['falldamage']                = false,            -- Enable fall damage
    ['falldamage_realistic']      = true,             -- Enable realistic fall damage

    ['lastman_enabled']           = true,             -- Enable Last Prop Standing
    ['lastman_round_time']        = 60,               -- The time the last prop has to hide or kill all hunter before the round ends
    ['lastman_swep']              = 'weapon_lastman', -- The SWEP the last prop standing gets

    ['prop_maxhealth']            = 250,              -- Max health a prop can be
    ['prop_autotaunt']            = true,             -- Enable auto taunting
    ['prop_autotaunt_size']       = 1500,             -- Prop volume/size to auto taunt, any props with less volume will autotaunt, protects big props from autotaunts
    ['prop_autotaunt_near_hunters'] = true,           -- If enabled you will not auto taunt if a hunter is nearby
    ['prop_autotaunt_near_hunters_range'] = 500,      -- The range that is considered 'near by'
    ['prop_autotaunt_time']       = 90,               -- Time to start auto taunting, this number is when the round end timer hits this number
    ['prop_autotaunt_rage']       = 100,              -- Range of movement, if player moved [X] GMod units over [X] mount of time then don't auto taunt
    ['prop_autotaunt_delay']      = 15,               -- Delay between auto taunt checks
    ['prop_disguise_delay']       = 2,                -- Delay between disguise changes
    ['prop_jetpack_jump']         = true,             -- Jetpack jump for props

    ['hunter_friendlyfire']       = false,            -- Set to false to stop hunter on hunter violence
    ['hunter_damage_penalty']     = 10,               -- Health taken from hunter when damaging a non prop ent
    ['hunter_steal_health']       = true,             -- Takes 50% of damage dealt to prop and gives it to hunter
    ['hunter_steal_maxhealth']    = 200,              -- Max Health a hunter can get from stealing health.
    ['hunter_kill_bonus_health']  = 10,               -- Added health once hunter gets a kill
    ['hunter_kill_bonus_nade']    = 1,                -- Hunter will get a grenade once they kill a player
    ['hunter_spawn_with_nade']    = false,            -- Hunter will spawn with one grenade
    ['hunter_lastman_bonus_nade'] = true,             -- Hunter will get bonus grenade when there is a last prop
    ['hunter_jetpack_jump']       = true,             -- Jetpack jump for props
}

for var, value in pairs(GM.config) do
    if (type(value) == 'number') then
        value = tostring(value)
    elseif (type(value) == 'boolean') then
        value = (value == true) and '1' or '0'
    end
    if (not ConVarExists('lps_' .. var)) then
        CreateConVar('lps_' .. var, value, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY })
        lps.Info('Setting up ConVar: %s %s', 'lps_' .. var, value)
    end
end

--[[---------------------------------------------------------
--   Name: GM:GetConfig()
---------------------------------------------------------]]--
function GM:GetConfig(name)
    if (ConVarExists('lps_' .. name)) then
        local conVar = GetConVar('lps_' .. name)
        if (type(self.config[name]) == 'string') then
            return conVar:GetString()
        elseif (type(self.config[name]) == 'number') then
            return conVar:GetInt()
        elseif (type(self.config[name]) == 'boolean') then
            return conVar:GetBool()
        end
    elseif(self.config[name])then
        lps.Warning('ConVar lps_%s doesn\'t exist! Using defult: %s', name, self.config[name])
        return self.config[name]
    else
        lps.Error('Config lps_%s doesn\'t exist!', name)
    end
end

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

--[[---------------------------------------------------------
   Include Shared
---------------------------------------------------------]]--
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
