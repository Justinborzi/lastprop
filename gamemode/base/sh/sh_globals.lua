
--[[---------------------------------------------------------
--   Name: GM:CanStartGame()
---------------------------------------------------------]]--
function GM:CanStartGame()
    if (team.NumPlayers(TEAM.PROPS) >= 1 and team.NumPlayers(TEAM.HUNTERS) >= 1) then
        return true
    end
    return false
end

--[[---------------------------------------------------------
--   Name: GM:InPreGame()
---------------------------------------------------------]]--
function GM:InPreGame(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InPreGame', bool)
    else
        return GetGlobalBool('InPreGame', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:InGame()
---------------------------------------------------------]]--
function GM:InGame(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InGame', bool)
    else
        return GetGlobalBool('InGame', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:InPostGame()
---------------------------------------------------------]]--
function GM:InPostGame(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('InPostGame', bool)
    else
        return GetGlobalBool('InPostGame', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:GameStartTime()
---------------------------------------------------------]]--
function GM:GameStartTime(float)
    if (float ~= nil and SERVER) then
        SetGlobalFloat('GameStartTime', float)
    else
        return GetGlobalFloat('GameStartTime', CurTime())
    end
end

--[[---------------------------------------------------------
--   Name: GM:GameStartTime()
---------------------------------------------------------]]--
function GM:Paused(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('Paused', bool)
    else
        return GetGlobalBool('Paused', false)
    end
end

--[[---------------------------------------------------------
--   Name: GM:LastmanEnabled()
---------------------------------------------------------]]--
function GM:LastmanEnabled(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('LastmanEnabled', bool)
    else
        return GetGlobalBool('LastmanEnabled', self.config['lastman_enabled'])
    end
end

--[[---------------------------------------------------------
--   Name: GM:LastmanForce()
---------------------------------------------------------]]--
function GM:LastmanForce(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('LastmanForce', bool)
    else
        return GetGlobalBool('LastmanForce', self.config['lastman_force_all'])
    end
end

--[[---------------------------------------------------------
--   Name: GM:DisguiseDelay()
---------------------------------------------------------]]--
function GM:DisguiseDelay(float)
    if (float ~= nil and SERVER) then
        SetGlobalFloat('DisguiseDelay', float)
    else
        return GetGlobalFloat('DisguiseDelay', self.config['prop_disguise_delay'])
    end
end

--[[---------------------------------------------------------
--   Name: GM:TeamSwitchDelay()
---------------------------------------------------------]]--
function GM:TeamSwitchDelay(float)
    if (float ~= nil and SERVER) then
        SetGlobalFloat('TeamSwitchDelay', float)
    else
        return GetGlobalFloat('TeamSwitchDelay', self.config['team_switch_delay'])
    end
end

--[[---------------------------------------------------------
--   Name: GM:ForceTeamBalance()
---------------------------------------------------------]]--
function GM:ForceTeamBalance(bool)
    if (bool ~= nil and SERVER) then
        SetGlobalBool('ForceTeamBalance', bool)
    else
        return GetGlobalBool('ForceTeamBalance', self.config['team_force_balance'])
    end
end