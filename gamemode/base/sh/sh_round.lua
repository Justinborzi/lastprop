ROUND = {
    DRAW  = 1003,
    TIMER = 1004
}

--[[---------------------------------------------------------
--   Name: GM:CanStartRound()
---------------------------------------------------------]]--
function GM:CanStartRound(num)
    if (team.NumPlayers(TEAM.PROPS) >= 1 and team.NumPlayers(TEAM.HUNTERS) >= 1) then
        return true
    end
    return false
end

--[[---------------------------------------------------------
--   Name: GM:Round()
---------------------------------------------------------]]--
function GM:Round(int)
    if (int ~= nil and SERVER) then
        SetGlobalInt('RoundNumber', int)
    else
        return GetGlobalInt('RoundNumber', 1)
    end
end

--[[---------------------------------------------------------
--   Name: GM:InPreRound()
---------------------------------------------------------]]--
function GM:InPreRound(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InPreRound', bool)
    else
        return GetGlobalBool('InPreRound', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:InRound()
---------------------------------------------------------]]--
function GM:InRound(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InRound', bool)
    else
        return GetGlobalBool('InRound', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:InPostRound()
---------------------------------------------------------]]--
function GM:InPostRound(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InPostRound', bool)
    else
        return GetGlobalBool('InPostRound', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:RoundStartTime()
---------------------------------------------------------]]--
function GM:RoundStartTime(float)
    if (float ~= nil and SERVER) then
        SetGlobalFloat('RoundStartTime', float)
    else
        return GetGlobalFloat('RoundStartTime', -1)
    end
end

--[[---------------------------------------------------------
--   Name: GM:RoundEndTime()
---------------------------------------------------------]]--
function GM:RoundEndTime(float)
    if (float ~= nil and SERVER) then
        SetGlobalFloat('RoundEndTime', float)
    else
        return GetGlobalFloat('RoundEndTime', -1)
    end
end

--[[---------------------------------------------------------
--   Name: GM:NextRoundTime()
---------------------------------------------------------]]--
function GM:NextRoundTime(float)
    if (float ~= nil and SERVER) then
        SetGlobalFloat('NextRoundTime', float)
    else
        return GetGlobalFloat('NextRoundTime', -1)
    end
end

--[[---------------------------------------------------------
--   Name: GM:RoundWinner()
---------------------------------------------------------]]--
function GM:RoundWinner(int)
    if (int ~= nil and SERVER) then
        SetGlobalInt('RoundWinner', int)
    else
        return GetGlobalInt('RoundWinner', -1)
    end
end

--[[---------------------------------------------------------
--   Name: GM:LastMan()
---------------------------------------------------------]]--
function GM:LastMan(teamID, ent)
    if (((IsValid(ent) and ent:IsPlayer()) or ent == false) and SERVER) then
        SetGlobalInt('RoundLastManID' .. teamID, IsValid(ent) and ent:UserID() or 0)
    else
        return Player(GetGlobalInt('RoundLastManID' .. teamID, 0))
    end
end

