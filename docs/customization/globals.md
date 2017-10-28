# Gamemode Globals
---

Note: Globals can *ONLY* be set server side!

> To set a global `GAMEMODE:Global(any)` </br>
> To get a global `GAMEMODE:Global()`

All globals are `shared`

*This documentation is incomplete! Just an FYI!*

## Game Globals

---

### ![shared](_media/sh.png) GM:InPreGame(bool)
If the game is in pre-game state and has not started.

> @returns, bool

### ![shared](_media/sh.png) GM:InGame(bool)
If the game is started.

> @returns bool

### ![shared](_media/sh.png) GM:InPostGame(bool)
If the game has ended and is in post-game state.

> @returns, bool

### ![shared](_media/sh.png) GM:GameStartTime(float)

> @returns, float

### ![shared](_media/sh.png) GM:Paused(bool)

> @returns, bool

## Last Man Globals

---

### ![shared](_media/sh.png) GM:LastmanEnabled(bool)

> @returns, bool

### ![shared](_media/sh.png) GM:LastmanForce(bool)

> @returns, bool

## Prop Globals

---

### ![shared](_media/sh.png) GM:DisguiseDelay(float)

> @returns, float

## Team Globals

---

### ![shared](_media/sh.png) GM:TeamSwitchDelay(float)

> @returns, float

### ![shared](_media/sh.png) GM:ForceTeamBalance(bool)

> @returns, bool

## Round Globals

---

### ![shared](_media/sh.png) GM:Round(int)
The current round number.

> @returns, int

### ![shared](_media/sh.png) GM:InPreRound(bool)

> @returns, bool

### ![shared](_media/sh.png) GM:InRound(bool)

> @returns, bool

### ![shared](_media/sh.png) GM:InPostRound(bool)

> @returns, bool

### ![shared](_media/sh.png) GM:RoundStartTime(float)

> @returns, float

### ![shared](_media/sh.png) GM:RoundEndTime(float)

> @returns, float

### ![shared](_media/sh.png) GM:NextRoundTime(float)

> @returns, float

### ![shared](_media/sh.png) GM:RoundWinner(int)

> @returns, int

### ![shared](_media/sh.png) GM:RoundLimit(int)

> @returns, int

### ![shared](_media/sh.png) GM:LastMan(teamID, ent)
Gets the last man for a team, must provide teamID to get global.

> @returns, Player or nil
