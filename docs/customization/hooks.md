# Gamemode Hooks
This documentation is incomplete! Just an FYI!

## Keybinds/Input

---
### ![client](_media/cl.png) GM:RegisterBindings()

```client
hook.Add('RegisterBindings', 'MyHook:RegisterBindings', function()
    lps.bindings:Register('global', 'things', KEY_SLASH, INPUT.KEY, 'Do Things', 'When you press this key it does things!')
end)
```
When you have a custom keybind add the defult in this hook.

---

### ![client](_media/cl.png) GM:KeyDown(key, keycode, char, keytype, busy, cursor)

```client
hook.Add('KeyDown', 'MyHook:KeyDown', function()
    local things = lps.bindings:GetKey('global', 'things')
    if (key == tpv.key and keytype == tpv.type and not busy and not cursor) then
        -- Key down
    end
end)
```
This hook is called when a player presses down a key on their keyboard.

> @key, [the key pressed](http://wiki.garrysmod.com/page/Enums/KEY)<br/>
> @keycode, the keycode pressed (for web browsers)<br/>
> @char, the char pressed<br/>
> @keytype, INPUT.MOUSE or INPUT.KEY<br/>
> @busy, bool if player is busy<br/>
> @cursor, if cursor is visible<br/>

---

### ![client](_media/cl.png) GM:KeyUp(key, keycode, char, keytype, busy, cursor)

```client
hook.Add('KeyUp', 'MyHook:KeyUp', function()
    local things = lps.bindings:GetKey('global', 'things')
    if (key == tpv.key and keytype == tpv.type and not busy and not cursor) then
        -- Key up
    end
end)
```
This hook is called when a player releases a key on their keyboard.

> @key, [the key pressed](http://wiki.garrysmod.com/page/Enums/KEY)<br/>
> @keycode, the keycode pressed (for web browsers)<br/>
> @char, the char pressed<br/>
> @keytype, INPUT.MOUSE or INPUT.KEY<br/>
> @busy, bool if player is busy<br/>
> @cursor, if cursor is visible<br/>


## Minigame

---

### ![client](_media/cl.png) GM:MinigameStartDraw(ply, minigame)

```client
hook.Add('MinigameStartDraw', 'MyHook:MinigameStartDraw', function(ply, minigame)
    if (minigame ~= 'My Minigame') then return end
    -- do things
end)
```
First frame for `MinigameDraw` hook

> @ply, `LocalPlayer()`<br/>
> @minigame, name of mingame player has selected

---

### ![client](_media/cl.png) GM:MinigameDraw(ply, minigame)

```client
hook.Add('MinigameDraw', 'MyHook:MinigameDraw', function(ply, minigame)
    if (minigame ~= 'My Minigame') then return end
    -- do things
end)
```
This is where you draw your minigame, its a proxy for `HUDPaint`. But is only called when the minigame should be drawn.

> @ply, `LocalPlayer()`<br/>
> @minigame, name of mingame player has selected

---

### ![client](_media/cl.png) GM:MinigameEndDraw(ply, minigame)

```client
hook.Add('MinigameEndDraw', 'MyHook:MinigameEndDraw', function(ply, minigame)
    if (minigame ~= 'My Minigame') then return end
    -- do things
end)
```
Last frame for `MinigameDraw` hook

> @ply, `LocalPlayer()`<br/>
> @minigame, name of mingame player has selected

## Scoreboard

---

### ![client](_media/cl.png) GM:GetPlayerScoreboardIconText(ply)

```client
hook.Add('GetPlayerScoreboardIconText', 'MyHook:GetPlayerScoreboardIconText', function(ply)
    if (not IsValid(ply)) then return end
    return ply:GetUserGroup()
end)
```
Gets the players scoreboard icon text

> @ply, player object<br/>
> @return, string

---

### ![client](_media/cl.png) GM:GetPlayerScoreboardIcon(ply)

```client
hook.Add('GetPlayerScoreboardIcon', 'MyHook:GetPlayerScoreboardIcon', function(ply)
    if (not IsValid(ply)) then return end
    return 'icon16/color_wheel.png'
end)
```
Gets the players scoreboard icon

> @ply, player object<br/>
> @return, string

---

### ![client](_media/cl.png) GM:GetPlayerScoreboardColor(ply)
```client
hook.Add('GetPlayerScoreboardColor', 'MyHook:GetPlayerScoreboardColor', function(ply)
    if (not IsValid(ply)) then return end
    if (ply:IsAdmin()) then
        return util.Rainbow(nil, nil, 180)
    end
    return team.GetColor(ply:Team())
end)
```
Gets the players scoreboard color

> @ply, player object<br/>
> @return, color

## Team

---

### ![shared](_media/sh.png) GM:PlayerMaxTeamSwitch(ply, teamID)

```shared
hook.Add('PlayerMaxTeamSwitch', 'MyHook:PlayerMaxTeamSwitch', function(ply, teamID)
    return 0
end)
```
Gets max team switches for a player, `return 0` for unlimited

> @ply, player object<br/>
> @teamID, team to be joined<br/>
> @return, number

---

### ![shared](_media/sh.png) GM:ModifyTeam(teamID, teamInfo)

```shared
hook.Add('ModifyTeam', 'MyHook:ModifyTeam', function(teamID, teamInfo)
    if (teamID == TEAM.PROPS) then
        teamInfo.name = "le' Props"
        teamInfo.color = Color(0,0,0)
        teamInfo.class = 'my_custom_class'
        teamInfo.spawns = {'diprip_start_team_red', 'info_player_red', 'info_player_zombie'}
    end
    return teamInfo
end)
```
Allows you to modify the default teams

> @teamID, the team<br/>
> @teamInfo, team name, spawns and class<br/>
> @return, teamInfo


## Rounds

---

### ![shared](_media/sh.png) GM:CanStartRound(num)

```shared
hook.Add('CanStartRound', 'MyHook:CanStartRound', function(num)
    if (team.NumPlayers(TEAM.PROPS) >= 1 and team.NumPlayers(TEAM.HUNTERS) >= 1) then
        return true
    end
    return false
end)
```
Preform checks before round, return true to allow round to start

> @num, round number<br/>
> @return, bool

---

### ![server](_media/sv.png) GM:GetPreRoundTime(num)

```server
hook.Add('GetPreRoundTime', 'MyHook:GetPreRoundTime', function(num)
    return GAMEMODE:GetConfig('preround_time')
end)
```
This hook is called to get the time (in seconds) of the pre-round

> @num, round number<br/>
> @return, number

---

### ![shared](_media/sh.png) GM:OnPreRoundStart(num)

```shared
hook.Add('OnPreRoundStart', 'MyHook:OnPreRoundStart', function(num)
    --do stuff
end)
```
This hook is called on the begining of the pre-round

> @num, round number<br/>

---

### ![server](_media/sv.png) GM:GetRoundTime(num)

```server
hook.Add('GetRoundTime', 'MyHook:GetRoundTime', function(num)
    return GAMEMODE:GetConfig('round_time')
end)
```
This hook is called to get the time (in seconds) of the round

> @num, round number<br/>
> @return, number

---

### ![shared](_media/sh.png) GM:OnRoundStart(num)

```shared
hook.Add('OnRoundStart', 'MyHook:OnRoundStart', function(num)
    --do stuff
end)
```
This hook is called on the begining of the round

> @num, round number

---

### ![shared](_media/sh.png) GM:RoundLastMan(ply)

```shared
hook.Add('RoundLastMan', 'MyHook:RoundLastMan', function(ply)
    --do stuff
end)
```
This hook is called when there os only one man left on a team

> @ply, the last man

---

### ![shared](_media/sh.png) GM:OnRoundEnd(teamID, num)

```shared
hook.Add('OnRoundEnd', 'MyHook:OnRoundEnd', function(teamID, num)
    if (teamID == ROUND.TIMER) then
        -- props win
    elseif (teamID ~= ROUND.DRAW) then
        -- teamID wins
    else
        -- nobody wins
    end
end)
```
This hook is called on the end of the round

> @teamID, winning team<br/>
> @num, round number<br/>

---

### ![server](_media/sv.png) GM:GetPostRoundTime(num)

```server
hook.Add('GetRoundTime', 'MyHook:GetRoundTime', function(num)
    return GAMEMODE:GetConfig('postround_time')
end)
```
This hook is called to get the time (in seconds) of the post-round

> @num, round number<br/>
> @return, number

---

### ![shared](_media/sh.png) GM:OnNextRound(num)

```shared
hook.Add('OnNextRound', 'MyHook:OnNextRound', function(num)
    --do stuff
end)
```
This hook is called when the next round is about to start

> @num, round number<br/>

---

### ![server](_media/sv.png) GM:CanStartNextRound(num)

```server
hook.Add('CanStartNextRound', 'MyHook:CanStartNextRound', function(num)
    return true
end)
```
This hook is called to start the next round, return false to stop from going to the next round.

> @num, round number<br/>
> @return, bool

## Database

---

### ![server](_media/sv.png) GM:DBInitialize()

```server
hook.Add('DBInitialize', 'MyHook:DBInitialize', function()
    --do stuff
end)
```
This hook is called when the is initializeing.

---

### ![server](_media/sv.png) GM:DBConnected()

```server
hook.Add('DBConnected', 'MyHook:DBConnected', function()
    local queryObj = lps.sql:Create('mytable')
    queryObj:Create('steam_id', 'VARCHAR(25) NOT NULL')
    queryObj:Create('name', 'VARCHAR(255) NOT NULL')
    queryObj:Create('losses', 'INT NOT NULL')
    queryObj:Create('wins', 'INT NOT NULL')
	queryObj:Execute()
end)
```
This hook is called when the DB is connected.

---

### ![server](_media/sv.png) GM:DBFailed(error)

```server
hook.Add('DBFailed', 'MyHook:DBFailed', function(error)
    lps.Warning('Unable to connect to the database! Check your database credentials! Your stats will not be saved! %s', error)
end)
```
This hook is called when the DB failed to connect.


## Game

---

### ![shared](_media/sh.png) GM:OnStartGame(teamID, num)

```shared
hook.Add('OnStartGame', 'MyHook:OnStartGame', function()
    -- do stuff
end)
```
This hook is called when the game starts.

---

### ![shared](_media/sh.png) GM:OnEndGame()

```shared
hook.Add('OnEndGame', 'MyHook:OnEndGame', function()
    -- do stuff
end)
```
This hook is called when the game ends.

---

### ![server](_media/sv.png) GM:OnResume()

```server
hook.Add('OnResume', 'MyHook:OnResume', function()
    -- cleanup
end)
```
This hook is called when the game resumes from being paused.

---

### ![server](_media/sv.png) GM:OnPause()

```server
hook.Add('OnPause', 'MyHook:OnPause', function()
    -- cleanup
end)
```
This hook is called when there are no players on the server and the game pauses.
