--[[---------------------------------------------------------
--   Name: GM:PlayerRequestTeam()
---------------------------------------------------------]]--
function GM:PlayerRequestTeam(ply, teamID)

    -- This team isn't joinable
    if (not team.Joinable(teamID)) then
        util.Notify(ply, 'You can\'t join that team.')
        return
    end

    -- This team isn't joinable
    local canJoin, canJoinString = self:PlayerCanJoinTeam(ply, teamID)
    if (not canJoin and canJoinString) then
        util.Notify(ply, canJoinString)
        return
    end

    self:PlayerJoinTeam(ply, teamID)

end

--[[---------------------------------------------------------
--   Name: GM:PlayerJoinTeam()
---------------------------------------------------------]]--
function GM:PlayerJoinTeam(ply, newTeam)
    if (not IsValid(ply)) then return end

    local oldTeam = ply:Team()

    ply:ClassCall('Cleanup')

    if (ply:Alive()) then
        if (table.HasValue({TEAM.SPECTATORS, TEAM.UNASSIGNED, TEAM.CONNECTING}, oldTeam) or ply:IsObserver()) then
            ply:KillSilent()
        else
            ply:Kill()
        end
    end

    ply:SetTeam(newTeam)
    ply:ClassCall('Setup')
    ply:SetVar('team', newTeam)

    if (not table.HasValue({TEAM.SPECTATORS, TEAM.UNASSIGNED, TEAM.CONNECTING}, newTeam)) then
        ply:SetVar('lastTeamChange', CurTime(), true)
    end

    if (table.HasValue({TEAM.SPECTATORS, TEAM.UNASSIGNED, TEAM.CONNECTING}, newTeam)) then
        self:PlayerSpawnAsSpectator(ply)
    elseif(ply:ClassCall('CanSpawn')) then
        ply:Spawn()
    else
        self:BecomeObserver(ply)
    end

    lps.Log('Player %s joined %s team from %s team', ply:Nick(), team.GetName(newTeam) or 'None', team.GetName(oldTeam) or 'None')

    util.Notify(nil, string.format('%s joined ', ply:Nick()), team.GetColor(newTeam), team.GetName(newTeam), NOTIFY.DEFAULT, '.' )

    gamemode.Call('OnPlayerChangedTeam', ply, oldTeam, newTeam)
end

--[[---------------------------------------------------------
--   Name: GM:PlayerSetTeam()
---------------------------------------------------------]]--
function GM:PlayerSetTeam(ply, newTeam)
    if (not IsValid(ply)) then return end

    local oldTeam = ply:Team()

    ply:ClassCall('Cleanup')

    if (ply:Alive()) then
        ply:KillSilent()
    end

    ply:SetTeam(newTeam)
    ply:ClassCall('Setup')
    ply:SetVar('team', newTeam)

    if (table.HasValue({TEAM.SPECTATORS, TEAM.UNASSIGNED, TEAM.CONNECTING}, newTeam)) then
        self:PlayerSpawnAsSpectator(ply)
    elseif(ply:ClassCall('CanSpawn')) then
        ply:Spawn()
    else
        self:BecomeObserver(ply)
    end

    gamemode.Call('OnPlayerChangedTeam', ply, oldTeam, newTeam)
end

--[[---------------------------------------------------------
--   Name: GM:OnPlayerChangedTeam()
---------------------------------------------------------]]--
function GM:OnPlayerChangedTeam(ply, oldTeam, newTeam)

end

--[[---------------------------------------------------------
--   Name: GM:FindLeastCommittedOnTeam()
---------------------------------------------------------]]--
function GM:FindLeastCommittedOnTeam(teamID)
	local worst, worstTeamSwapper

	for k, v in pairs(team.GetPlayers(teamID)) do
        local lastTeamChange = v:GetVar('lastTeamChange', nil)
		if (lastTeamChange and (CurTime() < lastTeamChange + 180) and (not worstteamswapper or worstteamswapper:GetVar('lastTeamChange', nil) < lastTeamChange)) then
			worstTeamSwapper = v
		end

		if (not worst or (v:Frags() < worst:Frags())) then
			worst = v
		end
	end

	if (worstTeamSwapper) then
		return worstTeamSwapper, 'They changed teams recently.'
	end

	return worst, 'Least points on their team.'
end

--[[---------------------------------------------------------
--   Name: GM:CheckTeamBalance()
---------------------------------------------------------]]--
function GM:CheckTeamBalance()
    if(not self:GetConfig('team_auto_balance')) then return end

    local highest
	for id, tm in pairs(team.GetAllTeams()) do
		if (id > 0 and id < 1000 and team.Joinable(id)) then
			if (not highest or team.NumPlayers(id) > team.NumPlayers(highest)) then
				highest = id
			end
		end
	end

	if not highest then return end

	for id, tm in pairs(team.GetAllTeams()) do
		if (id ~= highest and id > 0 and id < 1000 and team.Joinable(id)) then
			if team.NumPlayers(id) < team.NumPlayers(highest) then
				while team.NumPlayers(id) < team.NumPlayers(highest) - 1 do
                    local ply, reason = self:FindLeastCommittedOnTeam(highest)
                    if (not IsValid(ply)) then return end
                    self:PlayerSetTeam(ply, id)
                    util.Notify(nil, string.format('%s has been changed to %s for team balance. (%s)', ply:Nick(), team.GetName(id), reason))
				end
			end
		end
	end
end