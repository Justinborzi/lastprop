--[[---------------------------------------------------------
   Define player teams
---------------------------------------------------------]]--
TEAM = {
    CONNECTING =    TEAM_CONNECTING,
    UNASSIGNED =    TEAM_UNASSIGNED,
    SPECTATORS =    TEAM_SPECTATOR,
    PROPS      =    1,
    HUNTERS    =    2,
}

TEAM_DATA = {
    CONNECTING =    {id = TEAM_CONNECTING, name = 'Connecting'},
    UNASSIGNED =    {id = TEAM_UNASSIGNED, name = 'Unassigned', color = Color(200, 200, 200), class = 'spectator', spawns = {'info_player_start',  'gmod_player_start', 'info_player_teamspawn', 'ins_spawnpoint', 'aoc_spawnpoint', 'dys_spawn_point', 'info_player_coop', 'info_player_deathmatch'}},
    SPECTATORS =    {id = TEAM_SPECTATOR,  name = 'Spectators', color = Color(200, 200, 200), class = 'spectator', spawns = {'info_player_start',  'gmod_player_start', 'info_player_teamspawn', 'ins_spawnpoint', 'aoc_spawnpoint', 'dys_spawn_point', 'info_player_coop', 'info_player_deathmatch'}},
    PROPS =         {id = 1,               name = 'Props',      color = Color(255, 80, 80),   class = 'prop',      spawns = {'info_player_terrorist', 'info_player_axis', 'info_player_combine', 'info_player_pirate', 'info_player_viking', 'diprip_start_team_blue', 'info_player_blue', 'info_player_human'}},
    HUNTERS =       {id = 2,               name = 'Hunters',    color = Color(80, 150, 255),  class = 'hunter',    spawns = {'info_player_counterterrorist', 'info_player_allies', 'info_player_rebel', 'info_player_knight', 'diprip_start_team_red', 'info_player_red', 'info_player_zombie'}},
}


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
    ['hunter_lastman_bonus_nade'] = true,             -- Hunter will get bonus grenade when there is a last prop
    ['hunter_jetpack_jump']       = true,             -- Jetpack jump for props
}

for var, value in pairs(GM.config) do
    if (not ConVarExists('lps_' .. var)) then
        if (type(value) == 'number') then
            value = tostring(value)
        elseif (type(value) == 'boolean') then
            value = (value == true) and '1' or '0'
        end
        CreateConVar('lps_' .. var, value, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_NOTIFY })
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
   Gamemode Loadouts
---------------------------------------------------------]]--
GM.loadouts = {
    [TEAM.PROPS] = {
        weapon_lastman = {},
    },
    [TEAM.HUNTERS] = {
        weapon_crowbar = {},
        weapon_shotgun = {
            primary = {'Buckshot', 64}
        },
        weapon_smg1 = {
            primary = {'SMG1', 255}
        },
        weapon_crossbow = {
            primary = {'XBowBolt', 32}
        }
    }
}

--[[---------------------------------------------------------
--   Name: GM:GetLoadout()
---------------------------------------------------------]]--
function GM:GetLoadout(ply, teamID)
    if (self.loadouts[teamID]) then
        return self.loadouts[teamID]
    end
end

--[[---------------------------------------------------------
--   Hook: DefaultSounds
---------------------------------------------------------]]--
hook.Add('InitPostEntity', 'DefaultSounds', function()

    GAMEMODE:AddUISound('lock', 'buttons/button24.wav')
    GAMEMODE:AddUISound('unlock', 'buttons/button3.wav')

    GAMEMODE:AddSFX('victory', 'lps/sounds/sfx/victory.mp3')
    GAMEMODE:AddSFX('defeat', 'lps/sounds/sfx/defeat.mp3')
    GAMEMODE:AddSFX('death', 'lps/sounds/sfx/death.mp3')
    GAMEMODE:AddSFX('start_hunters', 'lps/sounds/sfx/start_hunters.mp3')
    GAMEMODE:AddSFX('start_props', 'lps/sounds/sfx/start_props.mp3')

    GAMEMODE:AddMusic({
        'lps/sounds/music/afraid.mp3',
        'lps/sounds/music/backitup.mp3',
        'lps/sounds/music/bardello.mp3',
        'lps/sounds/music/dreaming.mp3',
        'lps/sounds/music/dreams.mp3',
        'lps/sounds/music/giraffe.mp3',
        'lps/sounds/music/midnightrun.mp3',
        'lps/sounds/music/moon.mp3',
        'lps/sounds/music/revibe.mp3',
        'lps/sounds/music/sendai.mp3',
        'lps/sounds/music/solparte.mp3',
        'lps/sounds/music/stansmood.mp3',
        'lps/sounds/music/tennyson.mp3',
        'lps/sounds/music/thoughts.mp3',
        'lps/sounds/music/wind.mp3',
        'lps/sounds/music/evilmorty.mp3',
    })

    GAMEMODE:RegisterTauntPack('default', {
        hunter = {
            {name = 't_asses2', file = 'lps/taunts/hunter/t_asses2.mp3', length = 2},
            {name = 't_bountyhunter1', file = 'lps/taunts/hunter/t_bountyhunter1.mp3', length = 7},
            {name = 't_bountyhunter2', file = 'lps/taunts/hunter/t_bountyhunter2.mp3', length = 8},
            {name = 't_canthide', file = 'lps/taunts/hunter/t_canthide.mp3', length = 2},
            {name = 't_chardis', file = 'lps/taunts/hunter/t_chardis.mp3', length = 11},
            {name = 't_checked', file = 'lps/taunts/hunter/t_checked.mp3', length = 4},
            {name = 't_come_here_little_one', file = 'lps/taunts/hunter/t_come_here_little_one.mp3', length = 5},
            {name = 't_crappyshot', file = 'lps/taunts/hunter/t_crappyshot.mp3', length = 4},
            {name = 't_dontrun', file = 'lps/taunts/hunter/t_dontrun.mp3', length = 2},
            {name = 't_gonnakill', file = 'lps/taunts/hunter/t_gonnakill.mp3', length = 3},
            {name = 't_goodbye', file = 'lps/taunts/hunter/t_goodbye.mp3', length = 2},
            {name = 't_how', file = 'lps/taunts/hunter/t_how.mp3', length = 7},
            {name = 't_iwillfindyou', file = 'lps/taunts/hunter/t_iwillfindyou.mp3', length = 3},
            {name = 't_i_see_you', file = 'lps/taunts/hunter/t_i_see_you.mp3', length = 6},
            {name = 't_jawstheme', file = 'lps/taunts/hunter/t_jawstheme.mp3', length = 11},
            {name = 't_liamneeson', file = 'lps/taunts/hunter/t_liamneeson.mp3', length = 8},
            {name = 't_predator', file = 'lps/taunts/hunter/t_predator.mp3', length = 4},
            {name = 't_psycho', file = 'lps/taunts/hunter/t_psycho.mp3', length = 12},
            {name = 't_sneaky', file = 'lps/taunts/hunter/t_sneaky.mp3', length = 4},
            {name = 't_whereareu', file = 'lps/taunts/hunter/t_whereareu.mp3', length = 5},
        },
        prop = {
            {name = 't_acdc', file = 'lps/taunts/prop/t_acdc.mp3', length = 6},
            {name = 't_agun', file = 'lps/taunts/prop/t_agun.mp3', length = 2},
            {name = 't_alert2', file = 'lps/taunts/prop/t_alert2.mp3', length = 2},
            {name = 't_amazing_horse', file = 'lps/taunts/prop/t_amazing_horse.mp3', length = 13},
            {name = 't_apocpony', file = 'lps/taunts/prop/t_apocpony.mp3', length = 6},
            {name = 't_ballin', file = 'lps/taunts/prop/t_ballin.mp3', length = 3},
            {name = 't_bananana', file = 'lps/taunts/prop/t_bananana.mp3', length = 4},
            {name = 't_bananaphone', file = 'lps/taunts/prop/t_bananaphone.mp3', length = 10},
            {name = 't_batman', file = 'lps/taunts/prop/t_batman.mp3', length = 9},
            {name = 't_bh', file = 'lps/taunts/prop/t_bh.mp3', length = 15},
            {name = 't_bloops', file = 'lps/taunts/prop/t_bloops.mp3', length = 7},
            {name = 't_boo', file = 'lps/taunts/prop/t_boo.mp3', length = 1},
            {name = 't_boxghost', file = 'lps/taunts/prop/t_boxghost.mp3', length = 2},
            {name = 't_cantina2', file = 'lps/taunts/prop/t_cantina2.mp3', length = 4},
            {name = 't_canttouchthis', file = 'lps/taunts/prop/t_canttouchthis.mp3', length = 22},
            {name = 't_circus', file = 'lps/taunts/prop/t_circus.mp3', length = 8},
            {name = 't_colt45', file = 'lps/taunts/prop/t_colt45.mp3', length = 9},
            {name = 't_cunning', file = 'lps/taunts/prop/t_cunning.mp3', length = 4},
            {name = 't_deathrooster2', file = 'lps/taunts/prop/t_deathrooster2.mp3', length = 8},
            {name = 't_dew', file = 'lps/taunts/prop/t_dew.mp3', length = 8},
            {name = 't_de_la_biere_icitte', file = 'lps/taunts/prop/t_de_la_biere_icitte.mp3', length = 21},
            {name = 't_dogsocks2', file = 'lps/taunts/prop/t_dogsocks2.mp3', length = 6},
            {name = 't_dropit', file = 'lps/taunts/prop/t_dropit.mp3', length = 8},
            {name = 't_eagleblimp', file = 'lps/taunts/prop/t_eagleblimp.mp3', length = 6},
            {name = 't_foxsay', file = 'lps/taunts/prop/t_foxsay.mp3', length = 17},
            {name = 't_gangnam', file = 'lps/taunts/prop/t_gangnam.mp3', length = 16},
            {name = 't_getlow', file = 'lps/taunts/prop/t_getlow.mp3', length = 9},
            {name = 't_giggity', file = 'lps/taunts/prop/t_giggity.mp3', length = 2},
            {name = 't_giveyouup', file = 'lps/taunts/prop/t_giveyouup.mp3', length = 8},
            {name = 't_goodies', file = 'lps/taunts/prop/t_goodies.mp3', length = 5},
            {name = 't_grenades2', file = 'lps/taunts/prop/t_grenades2.mp3', length = 1},
            {name = 't_guiles', file = 'lps/taunts/prop/t_guiles.mp3', length = 12},
            {name = 't_hahagood1', file = 'lps/taunts/prop/t_hahagood1.mp3', length = 6},
            {name = 't_hello2', file = 'lps/taunts/prop/t_hello2.mp3', length = 7},
            {name = 't_holyshit', file = 'lps/taunts/prop/t_holyshit.mp3', length = 4},
            {name = 't_iama', file = 'lps/taunts/prop/t_iama.mp3', length = 2},
            {name = 't_iloveweed', file = 'lps/taunts/prop/t_iloveweed.mp3', length = 2},
            {name = 't_imthemap', file = 'lps/taunts/prop/t_imthemap.mp3', length = 6},
            {name = 't_im_sexy', file = 'lps/taunts/prop/t_im_sexy.mp3', length = 9},
            {name = 't_intermission', file = 'lps/taunts/prop/t_intermission.mp3', length = 8},
            {name = 't_lickmybattery', file = 'lps/taunts/prop/t_lickmybattery.mp3', length = 10},
            {name = 't_lotion', file = 'lps/taunts/prop/t_lotion.mp3', length = 7},
            {name = 't_manamana', file = 'lps/taunts/prop/t_manamana.mp3', length = 12},
            {name = 't_mario', file = 'lps/taunts/prop/t_mario.mp3', length = 7},
            {name = 't_meow', file = 'lps/taunts/prop/t_meow.mp3', length = 1},
            {name = 't_mosquito', file = 'lps/taunts/prop/t_mosquito.mp3', length = 5},
            {name = 't_my_dick', file = 'lps/taunts/prop/t_my_dick.mp3', length = 10},
            {name = 't_naked', file = 'lps/taunts/prop/t_naked.mp3', length = 4},
            {name = 't_nomnom', file = 'lps/taunts/prop/t_nomnom.mp3', length = 20},
            {name = 't_nyan', file = 'lps/taunts/prop/t_nyan.mp3', length = 7},
            {name = 't_people_on_inside', file = 'lps/taunts/prop/t_people_on_inside.mp3', length = 5},
            {name = 't_pirate', file = 'lps/taunts/prop/t_pirate.mp3', length = 4},
            {name = 't_porn2', file = 'lps/taunts/prop/t_porn2.mp3', length = 5},
            {name = 't_rocky', file = 'lps/taunts/prop/t_rocky.mp3', length = 14},
            {name = 't_scream', file = 'lps/taunts/prop/t_scream.mp3', length = 2},
            {name = 't_selfie', file = 'lps/taunts/prop/t_selfie.mp3', length = 4},
            {name = 't_shutup', file = 'lps/taunts/prop/t_shutup.mp3', length = 3},
            {name = 't_sixflags', file = 'lps/taunts/prop/t_sixflags.mp3', length = 7},
            {name = 't_smb_star', file = 'lps/taunts/prop/t_smb_star.mp3', length = 10},
            {name = 't_sneakylaugh', file = 'lps/taunts/prop/t_sneakylaugh.mp3', length = 2},
            {name = 't_sofat', file = 'lps/taunts/prop/t_sofat.mp3', length = 9},
            {name = 't_star_017', file = 'lps/taunts/prop/t_star_017.mp3', length = 11},
            {name = 't_star_019', file = 'lps/taunts/prop/t_star_019.mp3', length = 11},
            {name = 't_stayinalive', file = 'lps/taunts/prop/t_stayinalive.mp3', length = 17},
            {name = 't_stayinalive2', file = 'lps/taunts/prop/t_stayinalive2.mp3', length = 13},
            {name = 't_sticky1', file = 'lps/taunts/prop/t_sticky1.mp3', length = 4},
            {name = 't_sticky2', file = 'lps/taunts/prop/t_sticky2.mp3', length = 6},
            {name = 't_sticky5', file = 'lps/taunts/prop/t_sticky5.mp3', length = 5},
            {name = 't_techno', file = 'lps/taunts/prop/t_techno.mp3', length = 11},
            {name = 't_toast', file = 'lps/taunts/prop/t_toast.mp3', length = 12},
            {name = 't_trololo', file = 'lps/taunts/prop/t_trololo.mp3', length = 12},
            {name = 't_trumpets', file = 'lps/taunts/prop/t_trumpets.mp3', length = 7},
            {name = 't_turret_anyone_there', file = 'lps/taunts/prop/t_turret_anyone_there.mp3', length = 1},
            {name = 't_turret_goodbye', file = 'lps/taunts/prop/t_turret_goodbye.mp3', length = 1},
            {name = 't_turret_hello', file = 'lps/taunts/prop/t_turret_hello.mp3', length = 1},
            {name = 't_vahjayjay', file = 'lps/taunts/prop/t_vahjayjay.mp3', length = 5},
            {name = 't_weed', file = 'lps/taunts/prop/t_weed.mp3', length = 2},
            {name = 't_whisp', file = 'lps/taunts/prop/t_whisp.mp3', length = 7},
            {name = 't_wickedsick', file = 'lps/taunts/prop/t_wickedsick.mp3', length = 3},
            {name = 't_yousmellfunny', file = 'lps/taunts/prop/t_yousmellfunny.mp3', length = 1},
        },
        lastman = {
            {name = 't_annihilate', file = 'lps/taunts/lastman/t_annihilate.mp3', length = 71},
            {name = 't_birthdaycake', file = 'lps/taunts/lastman/t_birthdaycake.mp3', length = 70},
            {name = 't_diffused', file = 'lps/taunts/lastman/t_diffused.mp3', length = 60},
            {name = 't_down_low', file = 'lps/taunts/lastman/t_down_low.mp3', length = 61},
            {name = 't_droid', file = 'lps/taunts/lastman/t_droid.mp3', length = 60},
            {name = 't_drwho', file = 'lps/taunts/lastman/t_drwho.mp3', length = 71},
            {name = 't_freshprince', file = 'lps/taunts/lastman/t_freshprince.mp3', length = 68},
            {name = 't_ftw', file = 'lps/taunts/lastman/t_ftw.mp3', length = 71},
            {name = 't_grinder', file = 'lps/taunts/lastman/t_grinder.mp3', length = 70},
            {name = 't_killthenoise', file = 'lps/taunts/lastman/t_killthenoise.mp3', length = 71},
            {name = 't_losingcontrol', file = 'lps/taunts/lastman/t_losingcontrol.mp3', length = 71},
            {name = 't_megaman2', file = 'lps/taunts/lastman/t_megaman2.mp3', length = 65},
            {name = 't_outoftime1', file = 'lps/taunts/lastman/t_outoftime1.mp3', length = 71},
            {name = 't_outoftime2', file = 'lps/taunts/lastman/t_outoftime2.mp3', length = 73},
            {name = 't_pumpvolume', file = 'lps/taunts/lastman/t_pumpvolume.mp3', length = 71},
            {name = 't_rise1', file = 'lps/taunts/lastman/t_rise1.mp3', length = 70},
            {name = 't_rise2', file = 'lps/taunts/lastman/t_rise2.mp3', length = 73},
            {name = 't_ruckus', file = 'lps/taunts/lastman/t_ruckus.mp3', length = 70},
            {name = 't_signalz', file = 'lps/taunts/lastman/t_signalz.mp3', length = 71},
            {name = 't_turndown', file = 'lps/taunts/lastman/t_turndown.mp3', length = 71},
        },
    })

end)

