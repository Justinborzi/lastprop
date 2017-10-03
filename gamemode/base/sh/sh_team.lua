--[[---------------------------------------------------------
   Define/Create player teams
---------------------------------------------------------]]--
TEAM = {
    CONNECTING =    TEAM_CONNECTING,
    UNASSIGNED =    TEAM_UNASSIGNED,
    SPECTATORS =    TEAM_SPECTATOR,
    PROPS      =    1,
    HUNTERS    =    2,
}

TEAM_DATA = {
    CONNECTING =    {id = TEAM_CONNECTING, name = 'Connecting'},
    UNASSIGNED =    {id = TEAM_UNASSIGNED, name = 'Unassigned', color = Color(200, 200, 200), class = 'spectator', spawns = {'info_player_start',  'gmod_player_start', 'info_player_teamspawn', 'ins_spawnpoint', 'aoc_spawnpoint', 'dys_spawn_point', 'info_player_coop', 'info_player_deathmatch'}},
    SPECTATORS =    {id = TEAM_SPECTATOR,  name = 'Spectators', color = Color(200, 200, 200), class = 'spectator', spawns = {'info_player_start',  'gmod_player_start', 'info_player_teamspawn', 'ins_spawnpoint', 'aoc_spawnpoint', 'dys_spawn_point', 'info_player_coop', 'info_player_deathmatch'}},
    PROPS =         {id = 1,               name = 'Props',      color = Color(255, 80, 80),   class = 'prop',      spawns = {'info_player_terrorist', 'info_player_axis', 'info_player_combine', 'info_player_pirate', 'info_player_viking', 'diprip_start_team_blue', 'info_player_blue', 'info_player_human'}},
    HUNTERS =       {id = 2,               name = 'Hunters',    color = Color(80, 150, 255),  class = 'hunter',    spawns = {'info_player_counterterrorist', 'info_player_allies', 'info_player_rebel', 'info_player_knight', 'diprip_start_team_red', 'info_player_red', 'info_player_zombie'}},
}

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
        lps.Info('Set up team: %s\n', t.name)
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerCanJoinTeam(Player ply, Number teamid)
--   Desc: Are we allowed to join a team? Return true if so.
---------------------------------------------------------]]--
function GM:PlayerCanJoinTeam(ply, teamID)

    local timeBetweenSwitches, lastTeamChange = self:GetConfig('team_switch_delay'), ply:GetVar('lastTeamChange', 0)
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

    if (self:InPostGame()) then
        return false
    end

    -- Don't let them join a team if it has more players than another team
    if (self:GetConfig('team_force_balance')) then
        for id, tm in pairs(team.GetAllTeams()) do
            if (id > 0 and id < 1000 and team.NumPlayers(id) <  team.NumPlayers(teamID) and team.Joinable(id)) then
                return false, 'That team is full!'
            end
        end
    end

    return true
end