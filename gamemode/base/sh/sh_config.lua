--[[---------------------------------------------------------------------------------------------
       ___  ____  _  ___ ______  _______  __________  ________ __________  __________   ____
      / _ \/ __ \/ |/ ( )_  __/ / __/ _ \/  _/_  __/ /_  __/ // /  _/ __/ / __/  _/ /  / __/
     / // / /_/ /    /|/ / /   / _// // // /  / /     / / / _  // /_\ \  / _/_/ // /__/ _/
    /____/\____/_/|_/   /_/   /___/____/___/ /_/     /_/ /_//_/___/___/ /_/ /___/____/___/

    Visit https://github.com/gluaws/lastprop/wiki to see how to configure this gamemode!

---------------------------------------------------------------------------------------------]]--

if (SERVER) then
    --[[---------------------------------------------------------
       Load banned props
    ---------------------------------------------------------]]--
    local path = string.format('%s/%s', lps.paths.data, 'banned_props.txt')
    if (file.Exists(path, 'DATA')) then
        lps.banned = util.JSONToTable(file.Read(path))
    else
        lps.banned = {
            'models/props/cs_assault/dollar.mdl',
            'models/props/cs_assault/money.mdl',
            'models/props/cs_office/snowman_arm.mdl',
            'models/props_junk/garbage_metalcan002a.mdl',
            'models/props/cs_office/computer_mouse.mdl',
            'models/props/cs_office/projector_remote.mdl',
            'models/props/cs_office/fire_extinguisher.mdl',
            'models/props_lab/huladoll.mdl',
            'models/weapons/w_357.mdl',
            'models/props_c17/tools_wrench01a.mdl',
            'models/props_c17/signpole001.mdl',
            'models/props_lab/clipboard.mdl',
            'models/props_c17/chair02a.mdl',
            'models/props/cs_office/computer_caseb_p2a.mdl',
            'models/props_trainstation/payphone_reciever001a.mdl'
        }
        file.Write(path, util.TableToJSON(lps.banned))
    end
end


--[[---------------------------------------------------------
   Define player teams
---------------------------------------------------------]]--
TEAM = TEAM or {
    CONNECTING =    TEAM_CONNECTING,
    UNASSIGNED =    TEAM_UNASSIGNED,
    SPECTATORS =    TEAM_SPECTATOR,
    PROPS      =    1,
    HUNTERS    =    2,
}

TEAM_DATA = TEAM_DATA or {
    CONNECTING =    {id = TEAM_CONNECTING, name = 'Connecting'},
    UNASSIGNED =    {id = TEAM_UNASSIGNED, name = 'Unassigned', color = Color(200, 200, 200), class = 'spectator', spawns = {'info_player_start',  'gmod_player_start', 'info_player_teamspawn', 'ins_spawnpoint', 'aoc_spawnpoint', 'dys_spawn_point', 'info_player_coop', 'info_player_deathmatch'}},
    SPECTATORS =    {id = TEAM_SPECTATOR,  name = 'Spectators', color = Color(200, 200, 200), class = 'spectator', spawns = {'info_player_start',  'gmod_player_start', 'info_player_teamspawn', 'ins_spawnpoint', 'aoc_spawnpoint', 'dys_spawn_point', 'info_player_coop', 'info_player_deathmatch'}},
    PROPS =         {id = 1,               name = 'Props',      color = Color(255, 80, 80),   class = 'prop',      spawns = {'info_player_terrorist', 'info_player_axis', 'info_player_combine', 'info_player_pirate', 'info_player_viking', 'diprip_start_team_blue', 'info_player_blue', 'info_player_human'}},
    HUNTERS =       {id = 2,               name = 'Hunters',    color = Color(80, 150, 255),  class = 'hunter',    spawns = {'info_player_counterterrorist', 'info_player_allies', 'info_player_rebel', 'info_player_knight', 'diprip_start_team_red', 'info_player_red', 'info_player_zombie'}},
}


--[[---------------------------------------------------------
   Gamemode config
---------------------------------------------------------]]--
GM.config = GM.config or {
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
    ['hunter_crowbar_nopenalty']  = true,             -- Set to true to stop hunters from taking penalty damage when using crowbar
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
GM.loadouts = GM.loadouts or {}

GM.loadouts['PREGAME'] = GM.loadouts['PREGAME'] or {
    weapon_lastman = {},
    weapon_shotgun = {
        primary = {'Buckshot', 64}
    },
    weapon_smg1 = {
        primary = {'SMG1', 255}
    },
    weapon_crossbow = {
        primary = {'XBowBolt', 32}
    },
    weapon_rpg = {
        primary = {'RPG_Round', 6}
    },
}

GM.loadouts['POSTROUND'] = GM.loadouts['POSTROUND'] or {
    weapon_rpg = {
        primary = {'RPG_Round', 10}
    },
}

GM.loadouts[TEAM.PROPS] = GM.loadouts[TEAM.PROPS] or {
    weapon_lastman = {},
}

GM.loadouts[TEAM.HUNTERS] = GM.loadouts[TEAM.HUNTERS] or {
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

--[[---------------------------------------------------------
--   Hook: DefaultSounds
---------------------------------------------------------]]--
hook.Add('Initialize', 'DefaultSounds', function()

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
            {name = 't_asses2', label = 'Look at asses', file = 'lps/taunts/hunter/t_asses2.mp3', length = 2.246530612244898},
            {name = 't_bountyhunter1', label = 'Found you!', file = 'lps/taunts/hunter/t_bountyhunter1.mp3', length = 7.053061224489796},
            {name = 't_bountyhunter2', label = 'The hunt is on!', file = 'lps/taunts/hunter/t_bountyhunter2.mp3', length = 7.549387755102041},
            {name = 't_chardis', label = 'ALRIGHT YOU POOP NOBBLERS!', file = 'lps/taunts/hunter/t_chardis.mp3', length = 10.866938775510205},
            {name = 't_checked', label = 'SW, Check Shipt', file = 'lps/taunts/hunter/t_checked.mp3', length = 3.84},
            {name = 't_come_here_little_one', label = 'Come here little one', file = 'lps/taunts/hunter/t_come_here_little_one.mp3', length = 4.937142857142857},
            {name = 't_dontrun', label = 'Don\'t f**king run away from me', file = 'lps/taunts/hunter/t_dontrun.mp3', length = 2.27265306122449},
            {name = 't_goodbye', label = 'Say goodbye', file = 'lps/taunts/hunter/t_goodbye.mp3', length = 2.3510204081632655},
            {name = 't_how', label = 'How do we kill them', file = 'lps/taunts/hunter/t_how.mp3', length = 7.026938775510204},
            {name = 't_i_see_you', label = 'I see you', file = 'lps/taunts/hunter/t_i_see_you.mp3', length = 6.034285714285715},
            {name = 't_iwillfindyou', label = 'I will find you, toon', file = 'lps/taunts/hunter/t_iwillfindyou.mp3', length = 2.742857142857143},
            {name = 't_jawstheme', label = 'Jaws Theme', file = 'lps/taunts/hunter/t_jawstheme.mp3', length = 11.128163265306123},
            {name = 't_liamneeson', label = 'I will find you, Liam Neeson', file = 'lps/taunts/hunter/t_liamneeson.mp3', length = 7.862857142857143},
            {name = 't_predator', label = 'Predator', file = 'lps/taunts/hunter/t_predator.mp3', length = 3.657142857142857},
            {name = 't_psycho', label = 'Psycho', file = 'lps/taunts/hunter/t_psycho.mp3', length = 11.885714285714286},
            {name = 't_sneaky', label = 'You sneaky bastige', file = 'lps/taunts/hunter/t_sneaky.mp3', length = 3.683265306122449},
            {name = 't_whereareu', label = 'Where are you', file = 'lps/taunts/hunter/t_whereareu.mp3', length = 4.858775510204081},
            {name = 't_canthide', label = 'You can run but you can\'t hide!', file = 'lps/taunts/hunter/t_canthide.mp3', length = 2.4293877551020406},
            {name = 't_crappyshot', label = 'Crappy shot', file = 'lps/taunts/hunter/t_crappyshot.mp3', length = 3.944489795918367},
            {name = 't_gonnakill', label = 'I\'m gonna kill', file = 'lps/taunts/hunter/t_gonnakill.mp3', length = 2.716734693877551},
        },
        prop = {
            {name = 't_acdc', label = 'AC/DC Back in Black', file = 'lps/taunts/prop/t_acdc.mp3', length = 6.1387755102040815},
            {name = 't_alert2', label = 'Metal Gear Alert', file = 'lps/taunts/prop/t_alert2.mp3', length = 2.063673469387755},
            {name = 't_apocpony', label = 'Apocpony, MLP theme', file = 'lps/taunts/prop/t_apocpony.mp3', length = 5.773061224489796},
            {name = 't_ballin', label = 'This place is ballin yo', file = 'lps/taunts/prop/t_ballin.mp3', length = 2.6122448979591835},
            {name = 't_amazing_horse', label = 'Amazing horse', file = 'lps/taunts/prop/t_amazing_horse.mp3', length = 12.982857142857142},
            {name = 't_bananana', label = 'Bananana BANANANA', file = 'lps/taunts/prop/t_bananana.mp3', length = 3.866122448979592},
            {name = 't_batman', label = 'Tarded Batman', file = 'lps/taunts/prop/t_batman.mp3', length = 9.012244897959183},
            {name = 't_bananaphone', label = 'Banana Phone', file = 'lps/taunts/prop/t_bananaphone.mp3', length = 9.874285714285714},
            {name = 't_bloops', label = 'Bloops', file = 'lps/taunts/prop/t_bloops.mp3', length = 6.765714285714286},
            {name = 't_boxghost', label = 'I am the box ghost', file = 'lps/taunts/prop/t_boxghost.mp3', length = 2.3510204081632655},
            {name = 't_canttouchthis', label = 'Can\'t touch this', file = 'lps/taunts/prop/t_canttouchthis.mp3', length = 22.04734693877551},
            {name = 't_circus', label = 'Circus of values', file = 'lps/taunts/prop/t_circus.mp3', length = 7.575510204081633},
            {name = 't_cantina2', label = 'Cantina', file = 'lps/taunts/prop/t_cantina2.mp3', length = 3.6048979591836736},
            {name = 't_cunning', label = 'You\'ll never guess my disguise', file = 'lps/taunts/prop/t_cunning.mp3', length = 4.466938775510204},
            {name = 't_colt45', label = 'Colt 45', file = 'lps/taunts/prop/t_colt45.mp3', length = 9.221224489795919},
            {name = 't_dew', label = 'Mountain Dew', file = 'lps/taunts/prop/t_dew.mp3', length = 8.25469387755102},
            {name = 't_deathrooster2', label = 'Death metal rooster', file = 'lps/taunts/prop/t_deathrooster2.mp3', length = 7.523265306122449},
            {name = 't_dropit', label = 'Techno, Drop it', file = 'lps/taunts/prop/t_dropit.mp3', length = 8.202448979591837},
            {name = 't_dogsocks2', label = 'I\'m a dog', file = 'lps/taunts/prop/t_dogsocks2.mp3', length = 6.086530612244898},
            {name = 't_foxsay', label = 'What does the fox say', file = 'lps/taunts/prop/t_foxsay.mp3', length = 16.61387755102041},
            {name = 't_getlow', label = 'Get low', file = 'lps/taunts/prop/t_getlow.mp3', length = 9.482448979591837},
            {name = 't_gangnam', label = 'Oppa Gangnam Style', file = 'lps/taunts/prop/t_gangnam.mp3', length = 16.117551020408165},
            {name = 't_giveyouup', label = 'Never gonna give you up', file = 'lps/taunts/prop/t_giveyouup.mp3', length = 8.124081632653061},
            {name = 't_goodies', label = 'My goodies', file = 'lps/taunts/prop/t_goodies.mp3', length = 4.571428571428571},
            {name = 't_giggity', label = 'Quagmire, Giggity', file = 'lps/taunts/prop/t_giggity.mp3', length = 2.3771428571428572},
            {name = 't_guiles', label = 'Guile\'s theme', file = 'lps/taunts/prop/t_guiles.mp3', length = 12.35591836734694},
            {name = 't_grenades2', label = 'Just throw grenades at me', file = 'lps/taunts/prop/t_grenades2.mp3', length = 1.1493877551020408},
            {name = 't_holyshit', label = 'Unreal, Holy Shit', file = 'lps/taunts/prop/t_holyshit.mp3', length = 3.84},
            {name = 't_iama', label = 'I am a banana', file = 'lps/taunts/prop/t_iama.mp3', length = 2.3248979591836734},
            {name = 't_hello2', label = 'Hello... is me you are looking for', file = 'lps/taunts/prop/t_hello2.mp3', length = 6.739591836734694},
            {name = 't_imthemap', label = 'I\'m the map', file = 'lps/taunts/prop/t_imthemap.mp3', length = 6.2693877551020405},
            {name = 't_intermission', label = 'Intermission them', file = 'lps/taunts/prop/t_intermission.mp3', length = 8.202448979591837},
            {name = 't_lotion', label = 'It rubs the lotion on the skin', file = 'lps/taunts/prop/t_lotion.mp3', length = 7.366530612244898},
            {name = 't_manamana', label = 'Ma nam a na', file = 'lps/taunts/prop/t_manamana.mp3', length = 11.781224489795918},
            {name = 't_mario', label = 'Mario', file = 'lps/taunts/prop/t_mario.mp3', length = 7.079183673469387},
            {name = 't_mosquito', label = 'Mosquito', file = 'lps/taunts/prop/t_mosquito.mp3', length = 4.884897959183673},
            {name = 't_nyan', label = 'Nyan Cat Theme', file = 'lps/taunts/prop/t_nyan.mp3', length = 7.131428571428572},
            {name = 't_people_on_inside', label = 'I know people on the inside', file = 'lps/taunts/prop/t_people_on_inside.mp3', length = 4.937142857142857},
            {name = 't_porn2', label = 'Grab you dick and double click', file = 'lps/taunts/prop/t_porn2.mp3', length = 5.0416326530612245},
            {name = 't_rocky', label = 'Rocky Theme', file = 'lps/taunts/prop/t_rocky.mp3', length = 14.419591836734694},
            {name = 't_sixflags', label = 'Six Flags Theme', file = 'lps/taunts/prop/t_sixflags.mp3', length = 7.131428571428572},
            {name = 't_sneakylaugh', label = 'Peter laugh', file = 'lps/taunts/prop/t_sneakylaugh.mp3', length = 2.220408163265306},
            {name = 't_star_019', label = 'I just want BANG BANG BANG', file = 'lps/taunts/prop/t_star_019.mp3', length = 10.553469387755102},
            {name = 't_star_017', label = 'My dick don\'t need no', file = 'lps/taunts/prop/t_star_017.mp3', length = 10.553469387755102},
            {name = 't_sticky2', label = 'Sticky, Rubber fingers', file = 'lps/taunts/prop/t_sticky2.mp3', length = 5.903673469387755},
            {name = 't_sticky1', label = 'Sticky, Silks', file = 'lps/taunts/prop/t_sticky1.mp3', length = 4.048979591836734},
            {name = 't_stayinalive2', label = 'Stayin Alive 1', file = 'lps/taunts/prop/t_stayinalive2.mp3', length = 13.113469387755101},
            {name = 't_sticky5', label = 'Sticky, wrap that sticky', file = 'lps/taunts/prop/t_sticky5.mp3', length = 4.571428571428571},
            {name = 't_techno', label = 'Techno', file = 'lps/taunts/prop/t_techno.mp3', length = 11.38938775510204},
            {name = 't_toast', label = 'Toast', file = 'lps/taunts/prop/t_toast.mp3', length = 12.460408163265306},
            {name = 't_trumpets', label = 'Epic sax guy', file = 'lps/taunts/prop/t_trumpets.mp3', length = 7.471020408163265},
            {name = 't_turret_anyone_there', label = 'Turrent, Is anyone there?', file = 'lps/taunts/prop/t_turret_anyone_there.mp3', length = 1.4628571428571429},
            {name = 't_turret_hello', label = 'Turret, Hello?', file = 'lps/taunts/prop/t_turret_hello.mp3', length = 0.7314285714285714},
            {name = 't_turret_goodbye', label = 'Turret, Gooodbye!', file = 'lps/taunts/prop/t_turret_goodbye.mp3', length = 0.7836734693877551},
            {name = 't_weed', label = 'Smoke weed every day', file = 'lps/taunts/prop/t_weed.mp3', length = 1.906938775510204},
            {name = 't_vahjayjay', label = 'Who likes vaginas', file = 'lps/taunts/prop/t_vahjayjay.mp3', length = 4.702040816326531},
            {name = 't_whisp', label = 'Psst, Pssst, PSSSST', file = 'lps/taunts/prop/t_whisp.mp3', length = 7.39265306122449},
            {name = 't_wickedsick', label = 'Unreal, Wicked Sick', file = 'lps/taunts/prop/t_wickedsick.mp3', length = 2.6383673469387756},
            {name = 't_agun', label = 'You call that a gun?', file = 'lps/taunts/prop/t_agun.mp3', length = 1.906938775510204},
            {name = 't_bh', label = 'Benny Hill Theme', file = 'lps/taunts/prop/t_bh.mp3', length = 15.412244897959184},
            {name = 't_boo', label = 'Boooo', file = 'lps/taunts/prop/t_boo.mp3', length = 1.3844897959183673},
            {name = 't_de_la_biere_icitte', label = 'D\'la biere icitte', file = 'lps/taunts/prop/t_de_la_biere_icitte.mp3', length = 21.185306122448978},
            {name = 't_im_sexy', label = 'I\'m sexy and I know it', file = 'lps/taunts/prop/t_im_sexy.mp3', length = 9.038367346938776},
            {name = 't_iloveweed', label = 'I love weeeeeed', file = 'lps/taunts/prop/t_iloveweed.mp3', length = 2.455510204081633},
            {name = 't_lickmybattery', label = 'Lick my battery', file = 'lps/taunts/prop/t_lickmybattery.mp3', length = 9.874285714285714},
            {name = 't_my_dick', label = 'My dick is like an M16', file = 'lps/taunts/prop/t_my_dick.mp3', length = 9.717551020408163},
            {name = 't_naked', label = 'Help I\'m naked', file = 'lps/taunts/prop/t_naked.mp3', length = 3.5787755102040815},
            {name = 't_nomnom', label = 'Nom Nom Nom', file = 'lps/taunts/prop/t_nomnom.mp3', length = 20.114285714285714},
            {name = 't_scream', label = 'Manly Screem', file = 'lps/taunts/prop/t_scream.mp3', length = 2.4293877551020406},
            {name = 't_shutup', label = 'Meg, Shutup you sack of vomit', file = 'lps/taunts/prop/t_shutup.mp3', length = 2.6122448979591835},
            {name = 't_selfie', label = 'Let me take a selfie', file = 'lps/taunts/prop/t_selfie.mp3', length = 4.179591836734694},
            {name = 't_smb_star', label = 'Mario Star', file = 'lps/taunts/prop/t_smb_star.mp3', length = 10.344489795918367},
            {name = 't_stayinalive', label = 'Stayin Alive 2', file = 'lps/taunts/prop/t_stayinalive.mp3', length = 17.162448979591836},
            {name = 't_trololo', label = 'Trolololol', file = 'lps/taunts/prop/t_trololo.mp3', length = 12.35591836734694},
            {name = 't_yousmellfunny', label = 'You smell funny', file = 'lps/taunts/prop/t_yousmellfunny.mp3', length = 1.4889795918367348},
            {name = 't_pirate', label = 'You are a pirate', file = 'lps/taunts/prop/t_pirate.mp3', length = 4.048979591836734},
            {name = 't_hahagood1', label = 'GLaDOS, haha good one', file = 'lps/taunts/prop/t_hahagood1.mp3', length = 5.799183673469388},
            {name = 't_meow', label = 'Meow', file = 'lps/taunts/prop/t_meow.mp3', length = 0.626938775510204},
            {name = 't_eagleblimp', label = 'GLaDOS, Egal Blimp', file = 'lps/taunts/prop/t_eagleblimp.mp3', length = 6.164897959183674},
            {name = 't_sofat', label = 'GLaDOS, So fat', file = 'lps/taunts/prop/t_sofat.mp3', length = 8.986122448979591},
        },
        lastman = {
            {name = 't_annihilate', label = 'Annihilate', file = 'lps/taunts/lastman/t_annihilate.mp3', length = 70.84408163265306},
            {name = 't_birthdaycake', label = 'Birthday cake', file = 'lps/taunts/lastman/t_birthdaycake.mp3', length = 70.37387755102041},
            {name = 't_down_low', label = 'Everybody get down low', file = 'lps/taunts/lastman/t_down_low.mp3', length = 60.943673469387754},
            {name = 't_droid', label = 'Droid', file = 'lps/taunts/lastman/t_droid.mp3', length = 60.264489795918365},
            {name = 't_diffused', label = 'Diffused', file = 'lps/taunts/lastman/t_diffused.mp3', length = 60.42122448979592},
            {name = 't_drwho', label = 'Dr. Who Techo', file = 'lps/taunts/lastman/t_drwho.mp3', length = 71.31428571428572},
            {name = 't_freshprince', label = 'Fresh prince of bel-air theme', file = 'lps/taunts/lastman/t_freshprince.mp3', length = 67.8661224489796},
            {name = 't_killthenoise', label = 'Kill the noise, turn it up', file = 'lps/taunts/lastman/t_killthenoise.mp3', length = 70.7134693877551},
            {name = 't_ftw', label = 'For the win', file = 'lps/taunts/lastman/t_ftw.mp3', length = 70.53061224489795},
            {name = 't_losingcontrol', label = 'I\'m losing control', file = 'lps/taunts/lastman/t_losingcontrol.mp3', length = 70.58285714285714},
            {name = 't_grinder', label = 'Grinder they\'re coming', file = 'lps/taunts/lastman/t_grinder.mp3', length = 70.4},
            {name = 't_megaman2', label = 'Megaman theme', file = 'lps/taunts/lastman/t_megaman2.mp3', length = 65.09714285714286},
            {name = 't_outoftime1', label = 'Times up 2', file = 'lps/taunts/lastman/t_outoftime1.mp3', length = 70.60897959183673},
            {name = 't_rise1', label = 'Rise 1', file = 'lps/taunts/lastman/t_rise1.mp3', length = 70.06040816326531},
            {name = 't_outoftime2', label = 'Times up 1', file = 'lps/taunts/lastman/t_outoftime2.mp3', length = 72.69877551020409},
            {name = 't_rise2', label = 'Rise 2', file = 'lps/taunts/lastman/t_rise2.mp3', length = 73.19510204081632},
            {name = 't_signalz', label = 'Signalz', file = 'lps/taunts/lastman/t_signalz.mp3', length = 70.58285714285714},
            {name = 't_turndown', label = 'Turn down for what', file = 'lps/taunts/lastman/t_turndown.mp3', length = 70.6873469387755},
            {name = 't_ruckus', label = 'Ruckus', file = 'lps/taunts/lastman/t_ruckus.mp3', length = 70.34775510204082},
            {name = 't_pumpvolume', label = 'Pump up the volume', file = 'lps/taunts/lastman/t_pumpvolume.mp3', length = 70.94857142857143},
        },
    })

end)

