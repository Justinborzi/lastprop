# Gamemode Globals
---

Note: Globals can *ONLY* be set server side!

> To set a global `GAMEMODE:Global(any)` </br>
> To get a global `GAMEMODE:Global()`

*This documentation is incomplete! Just an FYI!*

## Game Globals

---

### GM:InPreGame(bool)
If the game is in pre-game state ans has not started.

> @returns, bool

### GM:InGame(bool)
If the game is started.

> @returns bool

### GM:InPostGame(bool)
If the game has ended and is in post-game state.

> @returns, bool

### GM:GameStartTime(float)

> @returns, float

### GM:Paused(bool)

> @returns, bool

## Last Man Globals

---

### GM:LastmanEnabled(bool)

> @returns, bool

### GM:LastmanForce(bool)

> @returns, bool

## Prop Globals

---

### GM:DisguiseDelay(float)

> @returns, float

## Team Globals

---

### GM:TeamSwitchDelay(float)

> @returns, float

### GM:ForceTeamBalance(bool)

> @returns, bool

## Round Globals

---

### GM:Round(int)
The current round number.

> @returns, int

### GM:InPreRound(bool)

> @returns, bool

### GM:InRound(bool)

> @returns, bool

### GM:InPostRound(bool)

> @returns, bool

### GM:RoundStartTime(float)

> @returns, float

### GM:RoundEndTime(float)

> @returns, float

### GM:NextRoundTime(float)

> @returns, float

### GM:RoundWinner(int)

> @returns, int

### GM:RoundLimit(int)

> @returns, int

### GM:LastMan(teamID, ent)
Gets the last man for a team, must provide teamID to get global.

> @returns, Player or nil
