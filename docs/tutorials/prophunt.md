# Converting to Prop Hunt
I've made it easy to make LPS plain old Prop Hunt with the exception of prop rotation, taunt menu and other misc features, they will remain the gamemode.

## Gamemode
First you need to download [prop_hunt](https://github.com/gluaws/lastprop-modules/archive/prop_hunt.zip) module and put it in your `garrysmod/gamemodes` folder along with the `lastprop` gamemode.

## Configuration
If you want to have LPS just show up on the prophunt list then you don't need to do this part. For a (mostly) vanilla experience set these convars in your `garrysmod/cfg/server.cfg` file.
```
sv_alltalk                   1
lps_postround_deathmatch     0
lps_pregame_deathmatch       0
lps_lastman_enabled          0
lps_prop_autotaunt           0
lps_prop_jetpack_jump        0
lps_hunter_crowbar_nopenalty 0
lps_hunter_steal_health      0
lps_hunter_kill_bonus_nade   0
lps_hunter_jetpack_jump      0
```

Now download and extract [config module](https://github.com/gluaws/lastprop-modules/archive/config.zip) into your `garrysmod/addons` folder.

Change the `garrysmod/addons/lps/lua/lastprop/modules/config/sh_loadout.lua` file to:
```
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
            primary = {'SMG1', 255},
            secondary = {'SMG1_Grenade', 1} -- Add the nade on spawn
        },
        weapon_crossbow = {
            primary = {'XBowBolt', 32}
        }
    }
}
```

Set your gamemode to `prop_hunt` in the launch parameters for your server and you should be good to go!