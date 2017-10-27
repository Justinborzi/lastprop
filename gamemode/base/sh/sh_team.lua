--[[---------------------------------------------------------
--   Name: GM:CreateTeams()
--   Desc: Set up all your teams here. Note - HAS to be shared.
---------------------------------------------------------]]--
function GM:ModifyTeam(teamID, teamInfo)
    return teamInfo
end

--[[---------------------------------------------------------
--   Name: GM:CreateTeams()
--   Desc: Set up all your teams here. Note - HAS to be shared.
---------------------------------------------------------]]--
function GM:CreateTeams()
    for _, t in pairs(TEAM_DATA) do
        table.Merge(t, hook.Call('ModifyTeam', self, t.id, {color = t.color, class = t.class, spawns = t.spawns}))
        if t.id and t.name and t.color then team.SetUp(t.id, t.name, t.color, true) end
        if t.id and t.spawns and #t.spawns > 0 then team.SetSpawnPoint(t.id, t.spawns) end
        if t.id and t.class then team.SetClass(t.id, t.class) end
        lps.Info('Set up team: %s', t.name)
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerCanJoinTeam(Player ply, Number teamid)
--   Desc: Are we allowed to join a team? Return true if so.
---------------------------------------------------------]]--
function GM:PlayerCanJoinTeam(ply, teamID)

    local timeBetweenSwitches, lastTeamChange = self:TeamSwitchDelay(), ply:GetVar('lastTeamChange', 0)
    if (timeBetweenSwitches > 0 and lastTeamChange and (CurTime() - lastTeamChange < timeBetweenSwitches)) then
        return false, string.format('Please wait %i more seconds before trying to change team again.', (timeBetweenSwitches - (CurTime() - lastTeamChange)) + 1)
    end

    if (table.HasValue({TEAM.PROPS, TEAM.HUNTERS}, ply:Team()) and table.HasValue({TEAM.PROPS, TEAM.HUNTERS}, teamID) and self:InRound()) then
        return false, 'You can\'t switch teams in the middle of the round!'
    end

    -- Already on this team!
    if (ply:Team() == teamid) then
        return false, 'You\'re already on that team!'
    end

    local maxTeamSwitch = hook.Call('PlayerMaxTeamSwitch', self, ply, teamID)
    if (maxTeamSwitch > 0 and maxTeamSwitch <= ply:GetVar('teamChanges', 0)) then
        return false, 'You have reached the team switch limit!'
    end

    if (self:InPostGame()) then
        return false
    end

    -- Don't let them join a team if it has more players than another team
    if (self:ForceTeamBalance()) then
        for id, tm in pairs(team.GetAllTeams()) do
            if (id > 0 and id < 1000 and team.NumPlayers(id) <  team.NumPlayers(teamID) and team.Joinable(id)) then
                return false, 'That team is full!'
            end
        end
    end

    return true
end

--[[---------------------------------------------------------
--   Name: GM:PlayerMaxTeamSwitch(Player ply, Number teamid)
---------------------------------------------------------]]--
function GM:PlayerMaxTeamSwitch(ply, teamID)
    return 0
end