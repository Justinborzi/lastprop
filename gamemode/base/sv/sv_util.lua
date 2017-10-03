util = util or {}

--[[---------------------------------------------------------
--   Name: util.ClassCallAll()
---------------------------------------------------------]]--
function util.ClassCallAll(name, ...)
    for _, v in pairs(player.GetAll()) do
        if (not v:IsSpectator()) then
            v:ClassCall(name, ...)
        end
    end
end

--[[---------------------------------------------------------
--   Name: util.ClassCallTeam()
---------------------------------------------------------]]--
function util.ClassCallTeam(teamID, name, ...)
    for _, v in pairs(team.GetPlayers(teamID)) do
        v:ClassCall(name, ...)
    end
end

--[[---------------------------------------------------------
--   Name: util.KillAll()
---------------------------------------------------------]]--
function util.KillAll()
    for _, v in pairs(player.GetAll()) do
        if (not v:IsSpectator() and v:Alive()) then
            v:KillSilent()
        end
    end
end

--[[---------------------------------------------------------
--   Name: util.SpawnAll()
---------------------------------------------------------]]--
function util.SpawnAll()
    for _, v in pairs(player.GetAll()) do
        if (not v:IsSpectator() and not v:Alive()) then
            v:Spawn()
        end
    end
end

--[[---------------------------------------------------------
--   Name: util.ForceSpawnAll()
---------------------------------------------------------]]--
function util.ForceSpawnAll()
    for _, v in pairs(player.GetAll()) do
        if (not v:IsSpectator()) then
            v:Spawn()
        end
    end
end

--[[---------------------------------------------------------
--   Name:  util.StripAll()
---------------------------------------------------------]]--
function util.StripAll()
    for _, v in pairs(player.GetAll()) do
        if (not v:IsSpectator()) then
            v:StripWeapons()
            v:StripAmmo()
        end
    end
end

--[[---------------------------------------------------------
--   Name: util.SwitchTeams()
---------------------------------------------------------]]--
function util.SwitchTeams(teamID1, teamID2)
    local score1, score2 = team.GetScore(teamID1), team.GetScore(teamID2)
    team.SetScore(teamID1, score2)
    team.SetScore(teamID2, score1)
    for _, v in pairs(player.GetAll()) do
        local teamID = v:Team()
        if (teamID == teamID2 or teamID == teamID1) then
            GAMEMODE:PlayerSetTeam(v, teamID == teamID1 and teamID2 or teamID1)
        end
    end
end

--[[---------------------------------------------------------
--   Name: util.FreezeTeam()
---------------------------------------------------------]]--
function util.FreezeTeam(teamID, bool)
    for _, v in pairs(team.GetPlayers(teamID)) do
        v:Freeze(bool)
    end
end

--[[---------------------------------------------------------
--   Name: util.FreezeAll()
---------------------------------------------------------]]--
function util.FreezeAll(bool)
    for _, v in pairs(player.GetAll()) do
        if (not v:IsSpectator()) then
            v:Freeze(bool)
        end
    end
end

--[[---------------------------------------------------------
--   Name: util.SetVarAll()
---------------------------------------------------------]]--
function util.SetVarAll(var, data, sync)
    for _, v in pairs(player.GetAll()) do
        v:SetVar(var, data)
    end
    if (sync) then
        lps.net.Start(nil, 'PlayerSetVar', {var, data})
    end
end

--[[---------------------------------------------------------
--   Name: util.GetLastMan()
---------------------------------------------------------]]--
function util.GetLastMan(teamID)
    for _, v in pairs(team.GetPlayers(teamID)) do
        if (v:Alive()) then
            return v
        end
    end
end

--[[---------------------------------------------------------
--   Name: util.AllSpectate()
---------------------------------------------------------]]--
function util.AllSpectate(ent)
    for _, v in pairs(player.GetAll()) do
        if (not v:Alive() and v:IsObserver()) then
            v:SpectateEntity(ent)
            v:Spectate(OBS_MODE_CHASE)
        end
    end
end