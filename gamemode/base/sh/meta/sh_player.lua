local meta = FindMetaTable('Player')
if (not meta) then return end

--[[---------------------------------------------------------
--   Name: meta:IsObserver()
---------------------------------------------------------]]--
function meta:IsObserver()
    return (self:GetObserverMode() > OBS_MODE_NONE)
end

--[[---------------------------------------------------------
--   Name: meta:IsSpec()
---------------------------------------------------------]]--
function meta:IsSpec()
    return table.HasValue({TEAM.SPECTATORS, TEAM.UNASSIGNED, TEAM.CONNECTING}, self:Team())
end

--[[---------------------------------------------------------
--   Name: meta:IsLastMan()
---------------------------------------------------------]]--
function meta:IsLastMan()
    return GetGlobalInt('RoundLastManID' .. self:Team()) == self:UserID()
end

--[[---------------------------------------------------------
--   Name: meta:CanTaunt()
---------------------------------------------------------]]--
function meta:CanTaunt()
    if (not GAMEMODE:InRound()) then return false end
    if (self:Team() == TEAM.PROPS and self:IsLastMan()) then return false end
    return true
end

--[[---------------------------------------------------------
--   Name: meta:GetTauntType()
---------------------------------------------------------]]--
function meta:GetTauntType()
    if (self:Team() == TEAM.PROPS and self:IsLastMan()) then
        return 'lastman'
    elseif (self:Team() == TEAM.PROPS) then
        return 'prop'
    elseif (self:Team() == TEAM.HUNTERS) then
        return 'hunter'
    end
end

--[[---------------------------------------------------------
--   Name: meta:GetTauntPack()
---------------------------------------------------------]]--
function meta:GetTauntPack(tPack)
    if (CLIENT and LocalPlayer() ~= self) then return 'default' end

    if (not tPack) then
        tPack = SERVER and self:GetInfo('lps_tauntpack') or GetConVar('lps_tauntpack'):GetString()
        if (tPack == 'any') then
            tPack = table.Random(lps.taunts.packs)
        end
    end

    local tType = self:GetTauntType()
    if (not lps.taunts.sounds[tPack]) or
       (not lps.taunts.sounds[tPack][tType]) or
       (lps.taunts.info[tPack][tType].count == 0) then
        return 'default'
    end
    return tPack
end

--[[---------------------------------------------------------
--   Name: meta:Class()
---------------------------------------------------------]]--
function meta:Class()
    local c = lps.class:Get(team.GetClass(self:Team()))
    if (not c) then return false end
    return c
end

--[[---------------------------------------------------------
--   Name: meta:ClassCall()
---------------------------------------------------------]]--
function meta:ClassCall(name, ...)
    local class = self:Class()
    if (not class) then return end
    if (not class[name]) then return end
    return class[name](class, self, ...)
end

--[[---------------------------------------------------------
--   Name: meta:GetVar()
---------------------------------------------------------]]--
function meta:GetVar(name, default)
    local id = self:SteamID()
    if (not lps.player[id]) then
        return default
    end
    return lps.player[id][name] or default
end

--[[---------------------------------------------------------
--   Name: meta:SetVar()
---------------------------------------------------------]]--
function meta:SetVar(name, data, sync)
    local id = self:SteamID()
    if (not lps.player[id]) then
        lps.player[id] = {}
    end
    lps.player[id][name] = data
    if(sync and SERVER) then
        lps.net.Start(self, 'PlayerSetVar', {name, data})
    end
end

if (CLIENT) then
    local function SetVar(data)
        local localPlayer = LocalPlayer()
        if (IsValid(localPlayer)) then
            localPlayer:SetVar(data[1], data[2])
        else
            timer.Simple(1, function() SetVar(data) end)
        end
    end
    lps.net.Hook('PlayerSetVar', SetVar)
end

--[[---------------------------------------------------------
--   Name: meta:LPSEmitSound()
---------------------------------------------------------]]--
function meta:LPSEmitSound(soundPath, soundLevel, pitchPercent, volume, channel)
    if (not soundPath) then return end
    if (self:IsDisguised()) then
         local disguise = self:GetDisguise()
         if (IsValid(disguise)) then
            disguise:EmitSound(soundPath, soundLevel, pitchPercent, volume, channel)
         end
    else
        self:EmitSound(soundPath, soundLevel, pitchPercent, volume, channel)
    end
end

--[[---------------------------------------------------------
--   Name: meta:LPSStopSound()
---------------------------------------------------------]]--
function meta:LPSStopSound(soundPath)
    if (soundPath ~= nil) then
        self:StopSound(soundPath)
    else
        if (SERVER) then self:SendLua('RunConsoleCommand(\'stopsound\')') else RunConsoleCommand('stopsound') end
    end
end

--[[---------------------------------------------------------
--   Name: meta:LPSPlaySound()
---------------------------------------------------------]]--
function meta:LPSPlaySound(soundPath, channel, time)
    if (not soundPath) then return end
    if (SERVER) then
        lps.net.Start(self, 'PlaySound', {soundPath, channel, time})
    else
        GAMEMODE:PlaySound(soundPath, channel, time)
    end
end

--[[---------------------------------------------------------
--   Name: meta:GetShootPos()
---------------------------------------------------------]]--
function meta:GetShootPos()
    local vec = Vector(0, 0, 0)
    if(self:IsDisguised()) then
         local disguise = self:GetDisguise()
         if (IsValid(disguise)) then
            local hullxy_max, hullxy_min, hullz, duckz = disguise:GetSize()
            vec = Vector(0, 0, hullz)
         end
         return self:GetPos() + vec
    end
    return self:EyePos()
end

--[[---------------------------------------------------------
--   Name: meta:GetEyeTrace()
---------------------------------------------------------]]--
function meta:GetEyeTrace(tr)
    local tr = tr or {}
    tr.start = tr.start or self:GetShootPos()
    tr.endpos = tr.endpos or tr.start + (self:GetAimVector() * (4096 * 8))
    tr.mask = tr.mask or MASK_ALL
    tr.filter = tr.filter or function(ent)
        if (not IsValid(ent)) then return false end
        if (ent:GetClass() == 'lps_disguise' and ent:GetPlayer() == self) then return false end
        if ent == self then return false end
        return true
    end
    return util.TraceLine(tr)
end

--[[---------------------------------------------------------
--   Name: meta:CanDisguise()
---------------------------------------------------------]]--
function meta:CanDisguise(ent)

    if (not self:Alive() or self:IsSpec()) then
        return false
    end

    if (self:Team() ~= TEAM.PROPS) then
        return false
    end

    if (not GAMEMODE:InGame()) then
        return false
    end

    if (GAMEMODE:InPostRound()) then
        return false
    end

    if (self:IsDisguised() and self:DisguiseLocked()) then
        return false, 'Your locked! Unlock to change props!'
    end

    local delay =  self:GetVar('lastDisguise', 0) + GAMEMODE:DisguiseDelay()
    if (delay > CurTime()) then
        return false, string.format('You have to wait %s before you can disguise again.', string.ToMinutesSeconds(delay - CurTime()))
    end

    if (ent and not IsValid(ent)) then
        print('IsValid')
        return false
    end

    if (not self:GetVar('replaceProp', false) and ent and not self:CanDisguiseFit(ent)) then
        return false, 'You can\'t fit in that area!'
    end

    if (self:IsDisguised() and not self:GetVar('replaceProp', false) and ent and ent:GetModel() == self:GetVar('disguiseModel', '')) then
        return false, 'Your already that model!'
    end

    if (ent and not ent:IsValidDisguise()) then
        return false, 'That prop is banned form this server!'
    end

    return true
end

--[[---------------------------------------------------------
--   Name: meta:IsDisguised()
---------------------------------------------------------]]--
function meta:IsDisguised()
    return IsValid(self:GetNWEntity('disguise'))
end

--[[---------------------------------------------------------
--   Name: meta:GetDisguise()
---------------------------------------------------------]]--
function meta:GetDisguise()
    return self:GetNWEntity('disguise')
end

--[[---------------------------------------------------------
--   Name: meta:DisguiseLocked()
---------------------------------------------------------]]--
function meta:DisguiseLocked()
    local disguise = self:GetNWEntity('disguise')
    if (disguise and IsValid(disguise) and disguise.GetLocked) then
        return disguise:GetLocked()
    end
    return false
end

--[[---------------------------------------------------------
--   Name: meta:CanDisguiseFit()
---------------------------------------------------------]]--
function meta:CanDisguiseFit(ent)
    local hullxy_max, hullxy_min, hullz, duckz = ent:GetSize()
    local trace = {}
    trace.start = self:GetPos()
    trace.endpos = self:GetPos()
    trace.maxs = Vector(hullxy_max, hullxy_max, hullz)
    trace.mins = Vector(hullxy_min, hullxy_min, 0)
    trace.mask = MASK_SHOT
    trace.filter = function(ent)
        if (ent:GetClass() == 'lps_disguise' and ent:GetPlayer() == self) or (ent == self) then return false end
        return true
    end
    local tr = util.TraceHull(trace)
    if tr.Hit then
        return false
    end
    return true
end

--[[---------------------------------------------------------
--   Name: meta:SetDisguiseHull()
---------------------------------------------------------]]--
function meta:SetDisguiseHull(hullxy_max, hullxy_min, hullz, duckz)
    hullxy_max = hullxy_max or 16
    hullxy_min = hullxy_min or -16
    hullz = hullz or 72
    duckz = duckz or hullz / 2

    self:SetHull(Vector(hullxy_min, hullxy_min, 0), Vector(hullxy_max, hullxy_max, hullz))
    self:SetHullDuck(Vector(hullxy_min, hullxy_min, 0), Vector(hullxy_max, hullxy_max, duckz))
    self:SetVar('disguiseHull', {hullxy_max = hullxy_max, hullxy_min = hullxy_min, hullz = hullz, duckz = duckz})

    if (SERVER) then
        lps.net.Start(self, 'DisguiseHull', {hullxy_max, hullxy_min, hullz, duckz})
    end
end

if (CLIENT) then
    local function SetDisguiseHull(data)
        local localPlayer = LocalPlayer()
        if (IsValid(localPlayer)) then
            localPlayer:SetDisguiseHull(data[1], data[2], data[3], data[4])
        else
            timer.Simple(1, function() SetDisguiseHull(data) end)
        end
    end
    lps.net.Hook('DisguiseHull', SetDisguiseHull)
end