#Gamemode Configuration

## Convars

### sv_alltalk

> Last Prop has a TTT style chat to avoid ghosting, set `sv_alltalk` to 1 to allow everyone to talk.
>
> default: 0

### lps_pregame_time

> Time to wait before starting game
>
> default: 60

### lps_pregame_deathmatch

> Rocket launcher death match before game starts or while waiting for players to join
>
> default: 1

### lps_round_limit

> Round limit
>
> default: 8

### lps_round_time

> Round time
>
> default: 300

### lps_preround_time

> This is the amount of time the hunters are blinded for and props to find a hiding spot
>
> default: 60

### lps_postround_time

> Post round time
>
> default: 15

### lps_postround_deathmatch

> Give everyone rocket launchers to kill each other
>
> default: 1

### lps_death_linger_time

> Amount of time to linger in the deathcam/freezecam
>
> default: 5

### lps_death_freezecam

> Enables freeze cam
>
> default: 1

### lps_team_switch_delay

> Delay for players to join a new team
>
> default: 1

### lps_team_force_balance

> Force team balance
>
> default: 1

### lps_team_auto_balance

> Auto balance teams
>
> default: 1

### lps_team_swap

> Swap teams on each round
>
> default: 1

### lps_falldamage

> Enable fall damage
>
> default: 0

### lps_falldamage_realistic

> Enable realistic fall damage
>
> default: 0

### lps_lastman_enabled

> Enable Last Prop Standing
>
> default: 1

### lps_lastman_force_all

> Forces all players to be last prop, ignores client settings
>
> default: 0

### lps_lastman_round_time

> The time the last prop has to hide or kill all hunters before the round ends
>
> default: 60

### lps_prop_maxhealth

> Max health a prop can be
>
> default: 250

### lps_prop_autotaunt

> Enable auto taunting
>
> default: 1

### lps_prop_autotaunt_size

> Prop volume/size to auto taunt, any props with less volume will auto taunt, protects big props from auto taunts
>
> default: 1500

### lps_prop_autotaunt_near_hunters

> If enabled you will not auto taunt if a hunter is nearby
>
> default: 1

### lps_prop_autotaunt_near_hunters_range

> The range that is considered 'near by'
>
> default: 500

### lps_prop_autotaunt_time

> Time to start auto taunting, this number is for when the round end timer hits this number
>
> default: 90

### lps_prop_autotaunt_rage

> Range of movement, if player moved [X] GMod units over [X] amount of time then don't auto taunt
>
> default: 100

### lps_prop_autotaunt_delay

> Delay between auto taunt checks
>
> default: 15

### lps_prop_disguise_delay

> Delay between disguise changes
>
> default: 2

### lps_prop_jetpack_jump

> Jetpack jump for props
>
> default: 1

### lps_hunter_friendlyfire

> Set to false to stop hunter on hunter violence
>
> default: 0

### lps_hunter_crowbar_nopenalty

> Set to true to stop hunters from taking penalty damage when using crowbar
>
> default: 1

### lps_hunter_damage_penalty

> Health taken from hunter when damaging a non prop entity
>
> default: 10

### lps_hunter_steal_health

> Takes 50% of damage dealt to prop and gives it to the hunter
>
> default: 1

### lps_hunter_steal_maxhealth

> Max health a hunter can get from stealing health
>
> default: 200

### lps_hunter_kill_bonus_health

> Added health once hunter gets a kill
>
> default: 10

### lps_hunter_kill_bonus_nade

> Hunter will get a grenade once they kill a player
>
> default: 1

### lps_hunter_lastman_bonus_nade

> Hunter will get bonus grenade when they become the last man
>
> default: 1

### lps_hunter_jetpack_jump

> Jetpack jump for props
>
> default: 1

## Example Config
```cfg
lps_pregame_time              90
lps_pregame_deathmatch        1

lps_round_limit               8
lps_round_time                300
lps_preround_time             60
lps_postround_time            15
lps_postround_deathmatch      1

lps_death_linger_time         5
lps_death_freezecam           1

lps_team_switch_delay         5
lps_team_force_balance        1
lps_team_auto_balance         1
lps_team_swap                 1

lps_falldamage                0
lps_falldamage_realistic      1

lps_lastman_enabled           1
lps_lastman_force_all         0
lps_lastman_round_time        60

lps_prop_maxhealth            250
lps_prop_autotaunt            1
lps_prop_autotaunt_size       1500
lps_prop_autotaunt_near_hunters 1
lps_prop_autotaunt_near_hunters_range 500
lps_prop_autotaunt_time       90
lps_prop_autotaunt_rage       100
lps_prop_autotaunt_delay      15
lps_prop_disguise_delay       2
lps_prop_jetpack_jump         1

lps_hunter_friendlyfire       0
lps_hunter_damage_penalty     10
lps_hunter_crowbar_nopenalty  1
lps_hunter_steal_health       1
lps_hunter_steal_maxhealth    200
lps_hunter_kill_bonus_health  10
lps_hunter_kill_bonus_nade    1
lps_hunter_lastman_bonus_nade 1
lps_hunter_jetpack_jump       1
```
## Console Commands

### banprop

> USEAGE: Look at a prop and run banprop to add the model to the banned props list.


## Mapvote
To change the mapvote config edit `garrysmod/lastprop/mapvote.txt`

Deafult mapvote configuration:
```json
{
	"mapPrefixes": [ "lps_", "cs_", "ph_", "ttt_", "mu_", "rp_" ],
	"mapsToVote": 10,
	"voteTime": 20,
	"mapAllowExtend": true,
	"mapRevoteBanRounds": 4,
	"allowForce": true,
	"mapMaxExtends": 4,
	"rtvMinPlayers": 4,
	"rtvPercentage": 0.6,
	"rtvEnabled": true,
	"mapExcludes":[]
}
```

## Config Module
The [config module](https://github.com/gluaws/lastprop-modules/archive/config.zip) is for adding music, changing the database settings and changing load-outs and adding you own custom taunts!