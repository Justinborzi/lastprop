
--[[---------------------------------------------------------
   Include server
---------------------------------------------------------]]--
include('sv_util.lua')
include('meta/sv_player.lua')
include('sv_player.lua')
include('sv_entity.lua')
include('sv_round.lua')
include('sv_spectator.lua')
include('sv_team.lua')
include('sv_commands.lua')
include('sv_sql.lua')

--[[---------------------------------------------------------
--   Name: GM:Initialize()
---------------------------------------------------------]]--
function GM:Initialize()
    self:InPreGame(true)
    self:Paused(true)
    self:DBInitialize()
    if (self:GetConfig('team_auto_balance')) then
        timer.Create('CheckTeamBalance', 15, 0, function() GAMEMODE:CheckTeamBalance() end)
    end
end

--[[---------------------------------------------------------
--   Name:  GM:Think()
---------------------------------------------------------]]--
function GM:Think()

    for _,v in pairs(player.GetAll()) do

        if (not IsValid(v)) then continue end

        v:ClassCall('Think')

        --kickass new taunting system :D
        if (self.nextTauntThink > CurTime()) then continue end

        local taunt, tauntCooldown = v:GetVar('taunt', nil), v:GetVar('tauntCooldown', 0)
        if (not taunt or tauntCooldown == 0) then continue end

        local tauntSound = v:GetTaunt(taunt)
        if (not tauntSound) then
            tauntSound = v:CreateTaunt(taunt)
        end

        local alive, isPlaying, inRound = v:Alive(), tauntSound[1]:IsPlaying(), self:InRound()
        if (isPlaying and (tauntCooldown < CurTime() or not alive or not inRound)) then
            tauntSound[1]:Stop()
            v:SetVar('taunt', nil)
            v:SetVar('tauntCooldown', 0)
        elseif (not isPlaying and tauntCooldown > CurTime() and alive and inRound) then
            tauntSound[1]:Play()
        end
    end

    if (not self.nextTauntThink or self.nextTauntThink < CurTime()) then
        self.nextTauntThink = CurTime() + 1
    end
end

--[[---------------------------------------------------------
--   Name: GM:OnStartGame()
---------------------------------------------------------]]--
function GM:OnStartGame()
    lps.Info('Game Started!\n')
end

--[[---------------------------------------------------------
--   Name: GM:StartGame()
---------------------------------------------------------]]--
function GM:StartGame()
    self:InPreGame(false)
    hook.Call('OnStartGame', self)
    self:InGame(true)
    self:PreRoundStart(1)
end

--[[---------------------------------------------------------
--   Name: GM:OnEndGame()
---------------------------------------------------------]]--
function GM:OnEndGame()
    util.KillAll()
    lps.Info('Game Ended!\n')
end

--[[---------------------------------------------------------
--   Name: GM:EndGame()
---------------------------------------------------------]]--
function GM:EndGame()
    self:InGame(false)
    hook.Call('OnEndGame', self)
    self:InPostGame(true)
end

--[[---------------------------------------------------------
--   Name: GM:OnPause()
---------------------------------------------------------]]--
function GM:OnPause()
    lps.Info('No active players, game paused!')
end

--[[---------------------------------------------------------
--   Name: GM:Pause()
---------------------------------------------------------]]--
function GM:Pause()

    self:Paused(true)

    hook.Call('OnPause', self)

    if (timer.Exists('pregameStart')) then
        timer.Destroy('pregameStart')
    end
    if (self:InRound()) then
        self:RoundEnd(self:Round())
    end
end

--[[---------------------------------------------------------
--   Name: GM:OnResume()
---------------------------------------------------------]]--
function GM:OnResume()
    lps.Info('Player joined, resumeing game!')
end

--[[---------------------------------------------------------
--   Name: GM:Resume()
---------------------------------------------------------]]--
function GM:Resume()

    self:Paused(false)

    hook.Call('OnResume', self)

    local function QueueGame()
        if (not hook.Call('CanStartGame', GAMEMODE)) then
            GAMEMODE:GameStartTime(CurTime() + GAMEMODE:GetConfig('pregame_time'))
            lps.Info('Unable to start game (check failed) starting in %ss', GAMEMODE:GetConfig('pregame_time'))
        else
            timer.Destroy('pregameStart')
            GAMEMODE:StartGame()
        end
    end

    if (self:InPreGame()) then
        QueueGame()
        timer.Create('pregameStart', self:GetConfig('pregame_time'), 0, function () QueueGame() end)
    end

    if (self:InGame()) then
        self:NextRound()
    end
end

--[[---------------------------------------------------------
--   Name: GM:CleanMap()
---------------------------------------------------------]]--
function GM:CleanMap()
    game.CleanUpMap()

    -- Remove weapons
    for _, wep in pairs(ents.FindByClass('weapon_*')) do
        wep:Remove()
    end

    -- Remove items
    for _, item in pairs(ents.FindByClass('item_*')) do
        item:Remove()
    end

    -- Fixes Collisions
    for _, ent in pairs(ents.FindByClass('prop_physics*')) do
        ent:SetCollisionGroup(COLLISION_GROUP_NONE)
    end

    hook.Call('OnCleanMap', self)
end

--[[---------------------------------------------------------
--   Name: GM:ShowHelp()
---------------------------------------------------------]]--
function GM:ShowHelp(ply)
    ply:ConCommand('lps_showhelp')
end