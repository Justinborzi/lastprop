local meta = FindMetaTable('Player')
if not meta then return end

--[[---------------------------------------------------------
--   Name: meta:GetTaunt()
---------------------------------------------------------]]--
function meta:GetTaunt(taunt)
    if (not self.taunts) then
        self.taunts = {}
    end
    return self.taunts[taunt.name]
end

--[[---------------------------------------------------------
--   Name: meta:CreateTaunt()
---------------------------------------------------------]]--
function meta:CreateTaunt(taunt)
    if (not self.taunts) then
        self.taunts = {}
    end
    local filter = RecipientFilter()
    filter:AddAllPlayers()
    self.taunts[taunt.name] = {CreateSound(self, taunt.name, filter), filter}
    return self.taunts[taunt.name]
end


--[[---------------------------------------------------------
--   Name: meta:PlayTaunt()
---------------------------------------------------------]]--
function meta:RandomTaunt(min, max)

    if (self:IsSpec() or not self:Alive()) then return end

    if ((self:GetVar('tauntCooldown', 0)) > CurTime()) then
        util.Notify(self, string.format('You have to wait %s before you can taunt again.', string.ToMinutesSeconds(self:GetVar('tauntCooldown', 0) - CurTime())))
        return
    end

    local tauntType, tauntPack = self:GetTauntType(), self:GetTauntPack()
    if (not tauntType or not tauntPack) then return end

    min = math.Clamp(min or 0, lps.taunts.info[tauntPack][tauntType].min, lps.taunts.info[tauntPack][tauntType].max)
    max = math.Clamp(max or 500, min, lps.taunts.info[tauntPack][tauntType].max)

    local taunt
    repeat
        taunt = table.Random(lps.taunts.sounds[tauntPack][tauntType])
    until
        taunt.name ~= self:GetVar('lastTaunt', nil) and taunt.length >= min and taunt.length <= max

    self:PlayTaunt(taunt.name)
end


--[[---------------------------------------------------------
--   Name: meta:PlayTaunt()
---------------------------------------------------------]]--
function meta:PlayTaunt(name)

    if (self:IsSpec() or not self:Alive()) then return end

    if ((self:GetVar('tauntCooldown', 0)) > CurTime()) then
        util.Notify(self, string.format('You have to wait %s before you can taunt again.', string.ToMinutesSeconds(self:GetVar('tauntCooldown', 0) - CurTime())))
        return
    end

    local tauntType, tauntPack = self:GetTauntType(), self:GetTauntPack()
    if (not tauntType or not tauntPack) then return end

    if (lps.taunts.sounds[tauntPack][tauntType][name]) then
        self:SetVar('tauntCooldown', (CurTime() + lps.taunts.sounds[tauntPack][tauntType][name].length + 0.5))
        self:SetVar('lastTaunt', name)
        self:SetVar('taunt', lps.taunts.sounds[tauntPack][tauntType][name])
        hook.Call('PlayerTaunt', GAMEMODE, self, lps.taunts.sounds[tauntPack][tauntType][name])
    else
        util.Notify(self, string.format('Unable to find taunt [%s][%s][%s]!', tauntPack, tauntType, name))
    end
end

--[[---------------------------------------------------------
--   Name: meta:StopTaunt()
---------------------------------------------------------]]--
function meta:StopTaunt()
    local taunt, tauntCooldown = self:GetVar('taunt', nil), self:GetVar('tauntCooldown', 0)
    if (not taunt or tauntCooldown == 0) then return end

    local tauntSound = self:GetTaunt(taunt)
    if (tauntSound and tauntSound[1]:IsPlaying()) then
        tauntSound[1]:Stop()
    end

    self:SetVar('taunt', nil)
    self:SetVar('tauntCooldown', 0)
end

--[[---------------------------------------------------------
--   Name: meta:SetDisguise()
---------------------------------------------------------]]--
function meta:SetDisguise(ent)
    return self:SetNWEntity('disguise', ent)
end

--[[---------------------------------------------------------
--   Name: meta:DisguiseAs()
---------------------------------------------------------]]--
function meta:DisguiseAs(ent)
    self:Disguise(ent)
    self:SetPos(ent:GetPos())
    ent:Remove()
end

--[[---------------------------------------------------------
--   Name: meta:Disguise()
---------------------------------------------------------]]--
function meta:Disguise(ent)
    if (not self:CanDisguise()) then return end
    if (not self:IsDisguised()) then
        self:SetVar('model', self:GetModel(), true)
        self:SetVar('collisionGroup', self:GetCollisionGroup(), true)
    end

    self:Flashlight(false)

    local validEnt = IsValid(ent)
    local disguise = self:GetDisguise()

    if not IsValid(disguise) then
        disguise = ents.Create('disguise')
        disguise:SetParent(self)
        disguise:SetOwner(self)
        disguise:Spawn()
        self:SetDisguise(disguise)
        self:SetModel('models/shells/shell_9mm.mdl')
        self:SetColor(Color(255, 255, 255, 0))
        self:SetBloodColor(BLOOD_COLOR_MECH)
        self:SetRenderMode(RENDERMODE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        self:SetNoDraw(true)
        self:DrawShadow(false)
    end

    local hullxy_max, hullxy_min, hullz, duckz, obb
    if (IsValid(ent)) then
        local phys = ent:GetPhysicsObject()
        if (IsValid(phys)) then
            self:SetVar('disguiseVol', phys:GetVolume(), true)
        else
            self:SetVar('disguiseVol', 1, true)
        end
        obb = {ent:OBBMins(), ent:OBBMaxs()}
        hullxy_max, hullxy_min, hullz, duckz = ent:GetSize()
        disguise:SetModel(ent:GetModel())
        disguise:SetSkin(ent:GetSkin())
    else
        self:SetVar('disguiseVol', 25000, true)
        obb = {disguise:OBBMins(), disguise:OBBMaxs()}
        hullxy_max, hullxy_min, hullz, duckz = disguise:GetSize()
        disguise:SetModel('models/player/Kleiner.mdl')
    end

    self:SetVar('disguiseOBB', obb, true)
    self:SetVar('disguiseModel', disguise:GetModel(), true)
    self:SetVar('disguiseSkin', disguise:GetSkin(), true)

    disguise:SetPos(self:GetPos() - Vector(0, 0, disguise:OBBMins().z))
    disguise:SetAngles(self:GetAngles())

    if (self:DisguiseLocked()) then
        disguise:SetLocked(false)
    end

    self:SetDisguiseHull(hullxy_max, hullxy_min, hullz, duckz)
    self:LPSEmitSound('weapons/bugbait/bugbait_squeeze' .. math.random(1, 3) .. '.wav')
    self:SetVar('lastDisguise', CurTime(), true)

    local effect = EffectData()
    effect:SetOrigin(self:GetPos() + Vector(0, 0, 1))
    effect:SetScale(hullxy_max)
    effect:SetMagnitude(hullz)
    util.Effect('poof', effect, true, true)

    self:CalculateHealth()

    hook.Call('PlayerDisguise', GAMEMODE, self, ent)
end

--[[---------------------------------------------------------
--   Name: meta:UnDisguise()
---------------------------------------------------------]]--
function meta:UnDisguise()
    local disguise = self:GetDisguise()
    if IsValid(disguise) then
        disguise:Remove()
        self:SetDisguise(nil)
    end

    self:SetVar('disguiseOBB', 0, true)
    self:SetVar('disguiseModel', '', true)
    self:SetVar('disguiseSkin', '', true)

    self:SetColor(Color(255, 255, 255, 255))
    self:SetDisguiseHull()
    self:SetNoDraw(false)
    self:DrawShadow(true)
    self:SetRenderMode(RENDERMODE_NORMAL)
    self:SetBloodColor(BLOOD_COLOR_RED)
    self:SetModel(self:GetVar('model', 'models/player/group01/male_01.mdl'))
    self:SetCollisionGroup(self:GetVar('collisionGroup', COLLISION_GROUP_PLAYER))

    self:LPSEmitSound('weapons/bugbait/bugbait_squeeze' .. math.random(1, 3) .. '.wav')
    local effect = EffectData()
    effect:SetOrigin(self:GetPos() + Vector(0, 0, 1))
    effect:SetScale(16)
    effect:SetMagnitude(72)
    util.Effect('poof', effect, true, true)

    self:CalculateHealth()

    hook.Call('PlayerUnDisguise', GAMEMODE, self)
end

--[[---------------------------------------------------------
--   Name: meta:CalculateHealth()
---------------------------------------------------------]]--
function meta:CalculateHealth()
    local maxHealth = GAMEMODE:GetConfig('prop_maxhealth')
    local percentage = self:Health()/self:GetMaxHealth()
    local max = self:IsDisguised() and math.Clamp(math.ceil(self:GetVar('disguiseVol', 1)/200), 1, maxHealth) or 100
    self:SetMaxHealth(max)
    self:SetHealth(math.Clamp(math.ceil(max * percentage), 1, maxHealth))
end

--[[---------------------------------------------------------
--   Name: meta:CalculateSpeed()
---------------------------------------------------------]]--
function meta:CalculateSpeed()
    -- todo: ? maybe
end

--[[---------------------------------------------------------
--   Name: meta:IsStuck()
---------------------------------------------------------]]--
function meta:IsStuck()
    local pos = self:GetPos()
    local t = {}
    if (self:IsDisguised()) then
        local disguise = self:GetDisguise()
        if (IsValid(disguise)) then
            t.filter = function(ent)
                if (ent:GetClass() == 'disguise' and ent:GetOwner() == self) then return false end
                if ent == self then return false end
                return true
            end
            t.start = pos
            t.endpos = pos
            t.mins = disguise:OBBMins()
            t.maxs = disguise:OBBMaxs()
            t.mask = MASK_PLAYERSOLID

            local tr = util.TraceHull(t)
            if tr.Entity and (tr.Entity:IsWorld() or tr.Entity:IsValid()) then
                return true
            end
        end
    else
        t.filter = self
        t.start = pos
        t.endpos = pos
        t.mins = self:OBBMins()
        t.maxs = self:OBBMaxs()
        t.mask = MASK_PLAYERSOLID

        local tr = util.TraceHull(t)
        if tr.Entity and (tr.Entity:IsWorld() or tr.Entity:IsValid()) then
            return true
        end
    end
    return false
end

--[[---------------------------------------------------------
--   Name: meta:UnStick()
---------------------------------------------------------]]--
function meta:UnStick()

    local t = { start = nil, endpos = nil, mask = MASK_PLAYERSOLID, filter = nil }
    local function PlayerNotStuck()
        t.start = self:GetPos()
        t.endpos = t.start
        t.filter = self
        return util.TraceEntity(t, self).StartSolid == false
    end

    local newPos = nil
    local function FindPassableSpace(direction, step)
        local i = 0
        while (i < 100) do
            local origin = self:GetPos()
            origin = origin + step * direction

            self:SetPos(origin)
            if (PlayerNotStuck(self)) then
                newPos = self:GetPos()
                return true
            end
            i = i + 1
        end
        return false
    end

    newPos = self:GetPos()
    local oldPos = newPos

    if (not PlayerNotStuck(self)) then
        local angle = self:GetAngles()
        local forward = angle:Forward()
        local right = angle:Right()
        local up = angle:Up()

        local searchScale = 1 -- Increase and it will unstuck you from even harder places but with lost accuracy. Please, don't try higher values than 12
        if (not FindPassableSpace( forward, searchScale)) then
            if (not FindPassableSpace( right, searchScale)) then
                if (not FindPassableSpace( right, -searchScale)) then --Left
                        if (not FindPassableSpace( up, searchScale)) then -- up
                            if (not FindPassableSpace( up, -searchScale)) then -- down
                                if (not FindPassableSpace( forward, -searchScale)) then -- back
                                return false
                            end
                        end
                    end
                end
            end
        end

        if oldPos == newPos then
            return true -- Not stuck?
        else
            self:SetPos(newPos)
            if SERVER and self and self:IsValid() and self:GetPhysicsObject():IsValid() then
                if self:IsPlayer() then
                    self:SetVelocity(vector_origin)
                end
                self:GetPhysicsObject():SetVelocity(vector_origin) -- prevents bugs :s
            end
            return true
        end
    end
end