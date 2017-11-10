-------------------------------
-- PreRound
-------------------------------

--[[---------------------------------------------------------
--   Name: GM:OnPreRoundStart()
---------------------------------------------------------]]--
function GM:OnPreRoundStart(num)
    self:PlaySound(table.Random(lps.sounds.music), SOUND.MUSIC, hook.Call('GetPreRoundTime', self, num))
    util.SpawnAll()
end

--[[---------------------------------------------------------
--   Name: GM:GetPreRoundTime()
---------------------------------------------------------]]--
function GM:GetPreRoundTime(num)
    return self:GetConfig('preround_time')
end

--[[---------------------------------------------------------
--   Name: GM:PreRoundStart()
---------------------------------------------------------]]--
function GM:PreRoundStart(num)
    if (self:Paused()) then return end
    if (not hook.Call('CanStartRound', self, num)) then
        timer.Simple(5, function() GAMEMODE:PreRoundStart(num) end)
        return
    end

    self:InPreRound(true)
    self:Round(num)

    local time = hook.Call('GetPreRoundTime', self, num)
    self:RoundStartTime(CurTime() + time)
    timer.Simple(time, function() GAMEMODE:RoundStart(num) end)

    hook.Call('OnPreRoundStart', self, num)
    util.ClassCallAll('OnPreRoundStart', num)
    lps.net.Start(nil, 'OnPreRoundStart', {num})

    lps.Info('Pre round #%s started, round starts in %ss!', num, time)
end

-------------------------------
-- Round
-------------------------------

--[[---------------------------------------------------------
--   Name: GM:OnRoundStart()
---------------------------------------------------------]]--
function GM:OnRoundStart(num)
    for _, v in pairs(player.GetAll()) do
        hook.Call('PlayerLoadout', self, v)
    end
end

--[[---------------------------------------------------------
--   Name: GM:GetRoundTime()
---------------------------------------------------------]]--
function GM:GetRoundTime(num)
    return self:GetConfig('round_time')
end

--[[---------------------------------------------------------
--   Name: GM:RoundStart()
---------------------------------------------------------]]--
function GM:RoundStart(num)

    self:InPreRound(false)
    self:InRound(true)

    local time = hook.Call('GetRoundTime', self, num)
    self:RoundEndTime(CurTime() + time)
    timer.Create('RoundEndTimer', time, 0, function() GAMEMODE:RoundEnd(ROUND.TIMER) end)
    timer.Create('CheckRoundEnd', 1, 0, function() GAMEMODE:CheckRoundEnd() end)

    hook.Call('OnRoundStart', self, num)
    util.ClassCallAll('OnRoundStart', num)
    lps.net.Start(nil, 'OnRoundStart', {num})

    lps.Info('Round #%s started, round ends in %ss!', num, time)
end

--[[---------------------------------------------------------
--   Name: GM:SetRoundTime()
---------------------------------------------------------]]--
function GM:SetRoundTime(setTime)
    if not self:InRound()  then return end
    self:RoundEndTime(CurTime() + setTime)
    timer.Adjust('RoundEndTimer', setTime, 0, function() GAMEMODE:RoundEnd(ROUND.TIMER) end)
end

--[[---------------------------------------------------------
--   Name: GM:AddRoundTime()
---------------------------------------------------------]]--
function GM:AddRoundTime(addedTime)
    if not self:InRound()  then return end
    self:RoundEndTime(self:RoundEndTime() + addedTime)
    timer.Adjust('RoundEndTimer', self:RoundEndTime() - self:RoundStartTime(), 0, function() GAMEMODE:RoundEnd(ROUND.TIMER) end)
end

--[[---------------------------------------------------------
--   Name: GM:CheckRoundEnd()
---------------------------------------------------------]]--
function GM:CheckRoundEnd()
    if not self:InRound() then return end

    local teams = {}
    for _,v in pairs(player.GetAll()) do
        if (v:Alive() and v:Team() > 0 and v:Team() < 1000) then
            teams[v:Team()] = teams[v:Team()] or 0
            teams[v:Team()] = teams[v:Team()] + 1
        end
    end

    if (table.Count(teams) == 0) then
        self:RoundEnd(ROUND.DRAW)
        return
    end

    if (table.Count(teams) == 1) then
        self:RoundEnd(table.GetFirstKey(teams))
        return
    end

    if(self:LastmanEnabled()) then
        for teamID, num in pairs(teams) do
            if (num == 1 and team.NumPlayers(teamID) > 1) then
                local lastMan = util.GetLastMan(teamID)
                if (IsValid(lastMan) and not lastMan:GetVar('lastMan', false)) then
                    self:RoundLastMan(lastMan)
                    lastMan:SetVar('lastMan', true, true)
                end
            end
        end
    end

end
hook.Add('PlayerDisconnected', 'GAMEMODE:CheckRoundEnd', function() timer.Simple(0.2, function() GAMEMODE:CheckRoundEnd() end) end)
hook.Add('PostPlayerDeath', 'GAMEMODE:CheckRoundEnd', function() timer.Simple(0.2, function() GAMEMODE:CheckRoundEnd() end) end)

-------------------------------
-- LastMan
-------------------------------

--[[---------------------------------------------------------
--   Name: GM:OnRoundLastMan()
---------------------------------------------------------]]--
function GM:OnRoundLastMan(ply)
    if (ply:Team() == TEAM.PROPS) then
        util.AllSpectate(ply)
        self:SetRoundTime(self:GetConfig('lastman_round_time') or 60)
        util.Notify(nil, string.format('%s is the last prop standing!', ply:Nick()))
    end
end

--[[---------------------------------------------------------
--   Name: GM:RoundLastMan()
---------------------------------------------------------]]--
function GM:RoundLastMan(ply)
    if (not IsValid(ply)) then return end
    if (ply:Team() == TEAM.PROP and ply:GetInfoNum('lps_lastman', 1) == 0 and not self:LastmanForce()) then return end

    self:LastMan(ply:Team(), ply)

    hook.Call('OnRoundLastMan', self, ply)
    ply:ClassCall('OnLastMan')

    util.ClassCallAll('OnRoundLastMan', ply)
    lps.net.Start(nil, 'OnRoundLastMan', {ply})

    lps.Info('%s is the last man standing for team %s!', ply:Nick(), team.GetName(ply:Team()))
end
-------------------------------
-- RoundEnd
-------------------------------

--[[---------------------------------------------------------
--   Name: GM:OnRoundEnd()
---------------------------------------------------------]]--
function GM:OnRoundEnd(teamID, num)
    util.SetVarAll('lastMan', false, true)
    if (teamID == ROUND.TIMER) then
        team.AddScore(TEAM.PROPS, 1)
        util.Notify(nil, 'Round Over! ', team.GetColor(TEAM.PROPS), team.GetName(TEAM.PROPS), NOTIFY.DEFAULT, ' Won!')
    elseif (teamID ~= ROUND.DRAW) then
        util.Notify(nil, 'Round Over! ', team.GetColor(teamID), team.GetName(teamID), NOTIFY.DEFAULT, ' Won!')
        team.AddScore(teamID, 1)
    else
        util.Notify(nil, 'Round Over! Nobody Won!')
    end
end

--[[---------------------------------------------------------
--   Name: GM:GetPostRoundTime()
---------------------------------------------------------]]--
function GM:GetPostRoundTime(teamID, num)
    return self:GetConfig('postround_time')
end

--[[---------------------------------------------------------
--   Name: GM:RoundEnd()
---------------------------------------------------------]]--
function GM:RoundEnd(teamID)
    if not self:InRound() then
        lps.WarningTrace('GAMEMODE:RoundEnd() being called while gamemode not in round...')
        return
    end

    local num = self:Round()

    for _, teamID in pairs(TEAM) do
        if (teamID > 0 and teamID < 1000) then
            self:LastMan(teamID, false)
        end
    end

    self:InRound(false)
    self:InPostRound(true)
    self:RoundWinner(teamID)

    if (teamID == ROUND.TIMER or teamID == ROUND.DRAW) then
        lps.Info('Round #%s ended! Nobody won... (%s)', num, teamID == ROUND.TIMER and 'ROUND.TIMER' or 'ROUND.DRAW')
    else
        lps.Info('Round #%s ended! Winner: %s (%s)', num, team.GetName(teamID) or 'Nobody ???', teamID)
    end

    timer.Destroy('RoundEndTimer')
    timer.Destroy('CheckRoundEnd')

    local time = hook.Call('GetPostRoundTime', self, teamID, num)
    self:NextRoundTime(CurTime() + time)
    timer.Simple(time, function() GAMEMODE:NextRound() end)

    hook.Call('OnRoundEnd', self, teamID, num)
    util.ClassCallAll('OnRoundEnd', teamID, num)
    lps.net.Start(nil, 'OnRoundEnd', {teamID, num})

    lps.Info('Post round started! New round starts in %ss!', time)
end

-------------------------------
-- NextRound
-------------------------------

--[[---------------------------------------------------------
--   Name: GM:CanStartNextRound()
---------------------------------------------------------]]--
function GM:CanStartNextRound(num)
    if (self:GetConfig('round_limit') > 0 and self:Round() >= self:GetConfig('round_limit')) then
        timer.Simple(0.5, function() GAMEMODE:EndGame() end)
        return false
    end
    return true
end

--[[---------------------------------------------------------
--   Name: GM:OnNextRound()
---------------------------------------------------------]]--
function GM:OnNextRound(num)
    self:CleanMap()
    self:CheckTeamBalance()
    if (self:GetConfig('team_swap')) then
        util.SwitchTeams(TEAM.PROPS, TEAM.HUNTERS)
        util.Notify(nil, 'Teams Swapped!')
    end
end

--[[---------------------------------------------------------
--   Name: GM:NextRound()
---------------------------------------------------------]]--
function GM:NextRound()

    self:InPostRound(false)
    self:RoundWinner(-1)
    self:RoundStartTime(-1)
    self:RoundEndTime(-1)
    self:NextRoundTime(-1)

    num = self:Round() + 1

    if (hook.Call('CanStartNextRound', self, num) ~= false) then
        hook.Call('OnNextRound', self, num)
        util.ClassCallAll('OnNextRound', num)
        lps.net.Start(nil, 'OnNextRound', {num})

        timer.Simple(0.5, function() GAMEMODE:PreRoundStart(num) end)
    end
end
