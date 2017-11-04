

--[[---------------------------------------------------------
	Name: gamemode:PlayerSpawnAsSpectator()
	Desc: Player spawns as a spectator
-----------------------------------------------------------]]
function GM:PlayerSpawnAsSpectator(ply)
	ply:StripWeapons()
	ply:Spectate(OBS_MODE_ROAMING)
end

--[[---------------------------------------------------------
--   Name: self:GetValidSpectatorModes(Player ply)
--   Desc: Gets a table of the allowed spectator modes (OBS_MODE_INEYE, etc)
--           Player is the player object of the spectator
---------------------------------------------------------]]--
function GM:GetValidSpectatorModes(ply)
    -- Note: Override this and return valid modes per player/team
    if ((team.NumPlayers(ply:Team()) > 1 and not ply:IsSpec()) or ply:IsAdmin()) then
        return {OBS_MODE_CHASE, OBS_MODE_IN_EYE, OBS_MODE_ROAMING}
    else
        return {OBS_MODE_ROAMING}
    end
end

--[[---------------------------------------------------------
--   Name: self:GetValidSpectatorEntityNames(Player ply)
--   Desc: Returns a table of entities that can be spectated (player etc)
---------------------------------------------------------]]--
function GM:GetValidSpectatorEntityNames(ply)
    -- Note: Override this and return valid entity names per player/team
    return {'player'}
end

--[[---------------------------------------------------------
--   Name: self:IsValidSpectator(Player ply)
--   Desc: Is our player spectating - and valid?
---------------------------------------------------------]]--
function GM:IsValidSpectator(ply)
    if (not IsValid(ply)) then return false end
    if (not ply:IsSpec() or not ply:IsObserver()) then return false end
    return true
end

--[[---------------------------------------------------------
--   Name: self:IsValidSpectatorTarget(Player ply, Entity ent)
--   Desc: Checks to make sure a spectated entity is valid.
--           By default, you can change GM.CanOnlySpectate own team if you want to
--           prevent players from spectating the other team.
---------------------------------------------------------]]--
function GM:IsValidSpectatorTarget(ply, ent)
    if (not IsValid(ent)) then return false end
    if (ent == ply) then return false end
    if (not table.HasValue(self:GetValidSpectatorEntityNames(ply), ent:GetClass())) then return false end
    if (ent:IsPlayer() and (not ent:Alive() or ent:IsObserver())) then return false end
    if (not ply:IsSpec() and ply:Team() ~= ent:Team()) then return false end
    return true
end

--[[---------------------------------------------------------
--   Name: self:GetSpectatorTargets(Player ply)
--   Desc: Returns a table of entities the player can spectate.
---------------------------------------------------------]]--
function GM:GetSpectatorTargets(ply)
    local t = {}
    for k, v in pairs(self:GetValidSpectatorEntityNames(ply)) do
        t = table.Merge(t, ents.FindByClass(v))
    end
    return t
end

--[[---------------------------------------------------------
--   Name: self:FindRandomSpectatorTarget(Player ply)
--   Desc: Finds a random player/ent we can spectate.
         This is called when a player is first put in spectate.
---------------------------------------------------------]]--
function GM:FindRandomSpectatorTarget(ply)
    local targets = self:GetSpectatorTargets(ply)
    return table.Random(targets)
end

--[[---------------------------------------------------------
--   Name: self:FindNextSpectatorTarget(Player ply, Entity ent)
--   Desc: Finds the next entity we can spectate.
         ent param is the current entity we are viewing.
---------------------------------------------------------]]--
function GM:FindNextSpectatorTarget(ply, ent)
    local targets = self:GetSpectatorTargets(ply)
    return table.FindNext(targets, ent)
end

--[[---------------------------------------------------------
--   Name: self:FindPrevSpectatorTarget(Player ply, Entity ent)
--   Desc: Finds the previous entity we can spectate.
         ent param is the current entity we are viewing.
---------------------------------------------------------]]--
function GM:FindPrevSpectatorTarget(ply, ent)
    local targets = self:GetSpectatorTargets(ply)
    return table.FindPrev(targets, ent)
end

--[[---------------------------------------------------------
--   Name: self:StartEntitySpectate(Player ply)
--   Desc: Called when we start spectating.
---------------------------------------------------------]]--
function GM:StartEntitySpectate(ply)
    local currentSpectateEntity = ply:GetObserverTarget()
    for i=1, 32 do
        if (self:IsValidSpectatorTarget(ply, currentSpectateEntity)) then
            ply:SpectateEntity(currentSpectateEntity)
            return
        end
        currentSpectateEntity = self:FindRandomSpectatorTarget(ply)
    end
end

--[[---------------------------------------------------------
--   Name: self:NextEntitySpectate(Player ply)
--   Desc: Called when we want to spec the next entity.
---------------------------------------------------------]]--
function GM:NextEntitySpectate(ply)
    local target = ply:GetObserverTarget()
    for i=1, 32 do
        target = self:FindNextSpectatorTarget(ply, target)
        if (self:IsValidSpectatorTarget(ply, target)) then
            ply:SpectateEntity(target)
            return
        end
    end
end

--[[---------------------------------------------------------
--   Name: self:PrevEntitySpectate(Player ply)
--   Desc: Called when we want to spec the previous entity.
---------------------------------------------------------]]--
function GM:PrevEntitySpectate(ply)
    local target = ply:GetObserverTarget()
    for i=1, 32 do
        target = self:FindPrevSpectatorTarget(ply, target)
        if (self:IsValidSpectatorTarget(ply, target)) then
            ply:SpectateEntity(target)
            return
        end
    end
end

--[[---------------------------------------------------------
--   Name: self:ChangeObserverMode(Player ply, Number mode)
--   Desc: Change the observer mode of a player.
---------------------------------------------------------]]--
function GM:ChangeObserverMode(ply, mode)
    if (ply:GetInfoNum('lps_specmode', 0) ~= mode) then
        ply:SendLua('RunConsoleCommand(\'lps_specmode\', ' .. mode .. ')')
    end
    if (mode == OBS_MODE_IN_EYE or mode == OBS_MODE_CHASE) then
        self:StartEntitySpectate(ply, mode)
    end
    ply:SpectateEntity(NULL)
    ply:Spectate(mode)
end

--[[---------------------------------------------------------
--   Name: self:BecomeObserver(Player ply)
----   Desc: Called when we first become a spectator.
---------------------------------------------------------]]--
function GM:BecomeObserver(ply)
    local mode = ply:GetInfoNum('lps_specmode', OBS_MODE_ROAMING)
    if (not table.HasValue(self:GetValidSpectatorModes(ply), mode)) then
        mode = table.FindNext(self:GetValidSpectatorModes(ply), mode)
    end
    self:ChangeObserverMode(ply, mode)
end

--[[---------------------------------------------------------
--   concommand: specmode
---------------------------------------------------------]]--
concommand.Add('specmode',  function (ply, cmd, args)
    if (not GAMEMODE:IsValidSpectator(ply)) then return end
    local mode = ply:GetObserverMode()
    local nextmode = table.FindNext(GAMEMODE:GetValidSpectatorModes(ply), mode)
    if (mode ~= nextmode) then
        GAMEMODE:ChangeObserverMode(ply, nextmode)
    end
end)

--[[---------------------------------------------------------
--   concommand: specnext
---------------------------------------------------------]]--
concommand.Add('specnext',  function (ply, cmd, args)
    if (not GAMEMODE:IsValidSpectator(ply)) then return end
    if (not table.HasValue(GAMEMODE:GetValidSpectatorModes(ply), ply:GetObserverMode())) then return end
    GAMEMODE:NextEntitySpectate(ply)
end)

--[[---------------------------------------------------------
--   concommand: specprev
---------------------------------------------------------]]--
concommand.Add('specprev',  function (ply, cmd, args)
    if (not GAMEMODE:IsValidSpectator(ply)) then return end
    if (not table.HasValue(GAMEMODE:GetValidSpectatorModes(ply), ply:GetObserverMode())) then return end
    GAMEMODE:PrevEntitySpectate(ply)
end)