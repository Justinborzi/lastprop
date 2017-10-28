# Changelog

---
## 1.1.0
This is a kinda big update but most of it is vgui, have fun!

### Changes:
* Improved gamemode stability
* Last prop now get an RPG with one rocket
* Scoreboard rewrite
* Mapvote rewrite
* SQL config, no longer need `database.cfg`. Database config is now set through config module.
* `lps_pregame_time` default is now `90`
* `lps_hunter_friendlyfire` default is now `false`
* `lps_hunter_damage_penalty` default is now `5`

### Bugfixes:
* Fixed taunt menu order
* Keybinds not saving
* Input lib improvements, `IsBusy` hook now returns true if chat is open
* Prop hitboxes work *amazingly* now
* Fixed !stuck command
* Fixed pressing 'E' on props (for sound FX) not wokring for bigger props

### New Features:
* `PlayerMaxTeamSwitch` hook allows you to limit players from team switching
* New Scoreboard! You can now add icons for each player!
* New Mapvote system, you can now extend, and force (for admins) maps during a mapvote, config is located `garrysmod/lastprop/mapvote.txt`
* New "Person is the last prop standing" screen!
* New pregame deathmatch not spawns in random sweps
* Lastprop gun is now an insta kill
* New config option `lps_lastman_force_all`
* New client option, Kliner mode, toggles spawning as a T-pose kliner, defalt false
* New client option, Last Prop Enabled, toggles last prop for that player, defalt true
* Added player stats! type '!stats' to view!

### New Hooks:
* `GetPlayerScoreboardIconText`
* `GetPlayerScoreboardIcon`
* `GetPlayerScoreboardColor`
* `PlayerMaxTeamSwitch`

If your using the following modules update them
* ULX module
* ServerGaurd module
* Config module

---
## 1.0.1
* Added `sv_alltalk` option, `0` for a ttt style voice chat, `1` for all chat.
* Fixed team auto balance, in some cases could cause server to crash.

---
## 1.0.0
First Release! Woo! Game mode is sable enough to release! Enjoy!

