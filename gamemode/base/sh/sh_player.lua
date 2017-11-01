--[[---------------------------------------------------------
--   Name: GM:Move(Player ply, CMoveData mv)
--   Desc: Setup Move, this also calls the player's class move
--           function.
---------------------------------------------------------]]--
function GM:Move(ply, mv)
    local move = ply:ClassCall('Move', mv)
    if (move ~= nil) then
        return move
    end
    return false
end

--[[---------------------------------------------------------
--   Name: GM:KeyPress(Player ply, Number key)
--   Desc: Player presses a key, this also calls the player's class
--           OnKeyPress function.
---------------------------------------------------------]]--
function GM:KeyPress(ply, key)
    local keyPress = ply:ClassCall('OnKeyPress', key)
    if (keyPress ~= nil) then
        return keyPress
    end
end

--[[---------------------------------------------------------
--   Name: GM:KeyRelease(Player ply, Number key)
   Desc: Player releases a key, this also calls the player's class
         OnKeyRelease function.
---------------------------------------------------------]]--
function GM:KeyRelease(ply, key)
    local keyRelease = ply:ClassCall('OnKeyRelease', key)
    if (keyRelease ~= nil) then
        return keyRelease
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerFootstep(Player ply, Vector pos, Number foot, String sound, Float volume, CReceipientFilter rf)
--   Desc: Player's feet makes a sound, this also calls the player's class Footstep function.
--           If you want to disable all footsteps set GM.NoPlayerFootsteps to true.
--             If you want to disable footsteps on a class, set Class.DisableFootsteps to true.
---------------------------------------------------------]]--
function GM:PlayerFootstep(ply, pos, foot, sound, volume, rf)
    local class = ply:Class()
    if(not class) then return end
    if(class.disableFootsteps) then return true end
    if(class.Footstep) then
        local footstep = class:Footstep(ply, pos, foot, sound, volume, rf)
        if(footstep ~= nil) then
            return footstep
        end
    end
    return true
end

--[[---------------------------------------------------------
--   Name: GM:PlayerNoClip(player, bool)
--   Desc: Player pressed the noclip key, return true if
--            the player is allowed to noclip, false to block
---------------------------------------------------------]]--
function GM:PlayerNoClip(ply, on)
    if (ply:IsObserver() or ply:IsSpec()) then return false end
    -- Allow noclip if we're in single player or have cheats enabled
    if (game.SinglePlayer() or GetConVar('sv_cheats'):GetBool()) then return true end
    -- Don't if it's not.
    return false
end

--[[---------------------------------------------------------
--   Name: GM:GetLoadout()
---------------------------------------------------------]]--
function GM:GetLoadout(ply, id)
    if (self.loadouts[id]) then
        return self.loadouts[id]
    end
end

--[[---------------------------------------------------------
--   Name: GM:ShouldCollide()
---------------------------------------------------------]]--
function GM:ShouldCollide(ent1, ent2)
	if (not IsValid(ent1) and not IsValid(ent2)) then return false end

    local class1, class2 = ent1:GetClass(), ent2:GetClass()

    if (class1 == 'player' and class2 == 'player') then
        if (ent1:Team() == TEAM.PROPS or ent2:Team() == TEAM.PROPS) then
            return false
        elseif (ent1 == ent2) then
            return false
        end
    end

    if (class1 == 'lps_disguise' and class2 == 'lps_disguise') then
        return false
    end

    if (class1 == 'lps_disguise' or class2 == 'lps_disguise') then
        if (ent1:GetOwner() == ent2:GetOwner()) then
            return false
        end
    end

	-- We must call this because anything else should return true.
	return true
end