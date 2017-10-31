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

    local tType, tPack = self:GetTauntType(), self:GetTauntPack()
    if (not tType or not tPack) then return end

    min = math.Clamp(min or 0, lps.taunts.info[tPack][tType].min, lps.taunts.info[tPack][tType].max)
    max = math.Clamp(max or 500, min, lps.taunts.info[tPack][tType].max)

    local taunt
    if (lps.taunts.info[tPack][tType].count > 1) then
        repeat
            taunt = table.Random(lps.taunts.sounds[tPack][tType])
        until
            taunt.name ~= self:GetVar('lastTaunt', nil) and taunt.length >= min and taunt.length <= max
    else
        taunt = table.Random(lps.taunts.sounds[tPack][tType])
    end

    self:PlayTaunt(taunt.name, tPack)
end


--[[---------------------------------------------------------
--   Name: meta:PlayTaunt()
---------------------------------------------------------]]--
function meta:PlayTaunt(name, pack)

    if (self:IsSpec() or not self:Alive()) then return end

    if ((self:GetVar('tauntCooldown', 0)) > CurTime()) then
        util.Notify(self, string.format('You have to wait %s before you can taunt again.', string.ToMinutesSeconds(self:GetVar('tauntCooldown', 0) - CurTime())))
        return
    end

    local tType, tPack = self:GetTauntType(), self:GetTauntPack(pack)
    if (not tType or not tPack) then return end

    if (lps.taunts.sounds[tPack][tType][name]) then
        self:SetVar('tauntCooldown', (CurTime() + lps.taunts.sounds[tPack][tType][name].length + 0.5))
        self:SetVar('lastTaunt', name)
        self:SetVar('tauntPack', tPack)
        self:SetVar('taunt', lps.taunts.sounds[tPack][tType][name])
        hook.Call('PlayerTaunt', GAMEMODE, self, lps.taunts.sounds[tPack][tType][name])
    else
        util.Notify(self, string.format('Unable to find taunt [%s][%s][%s]!', tPack, tType, name))
    end
end

--[[---------------------------------------------------------
--   Name: meta:StopTaunt()
---------------------------------------------------------]]--
function meta:StopTaunt()
    local taunt, tCooldown = self:GetVar('taunt', nil), self:GetVar('tauntCooldown', 0)
    if (not taunt or tCooldown == 0) then return end

    local tSound = self:GetTaunt(taunt)
    if (tSound and tSound[1]:IsPlaying()) then
        tSound[1]:Stop()
    end

    self:SetVar('taunt', nil)
    self:SetVar('tauntPack', nil)
    self:SetVar('tauntCooldown', 0)
end

--[[---------------------------------------------------------
--   Name: meta:SetDisguise()
---------------------------------------------------------]]--
function meta:SetDisguise(ent)
    return self:SetNWEntity('disguise', ent)
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

    local validEnt = IsValid(ent)
    local disguise = self:GetDisguise()

    if not IsValid(disguise) then
        self:SetModel('models/shells/shell_9mm.mdl')
        self:SetColor(Color(255, 255, 255, 0))
        self:SetBloodColor(BLOOD_COLOR_MECH)
        self:SetRenderMode(RENDERMODE_NONE)
        self:SetNoDraw(true)
        self:DrawShadow(false)
        self:SetCustomCollisionCheck(true)

        disguise = ents.Create('lps_disguise')
        disguise:SetOwner(self)
        disguise:SetParent(self)
        disguise:SetPlayer(self)
        disguise:Spawn()

        self:SetDisguise(disguise)
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

    if (self:GetVar('replaceProp', false) and IsValid(ent)) then
        local angles = ent:GetAngles()
        local pos = ent:GetPos()
        ent:Remove()

        self:SetPos(pos)
        disguise:SetLocked(angles)

        if (self:GetPhysicsObject():IsValid()) then
            self:SetVelocity(vector_origin)
            self:GetPhysicsObject():SetVelocity(vector_origin) -- prevents bugs
        end
    end
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
    self:SetCustomCollisionCheck(false)

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

    if (not self:IsInWorld()) then return true end

    local pos = self:GetPos()
    local disguise = self:GetDisguise()

    local t = {
        start = pos,
        endpos = pos,
        mask = MASK_PLAYERSOLID
    }

    if (IsValid(disguise)) then
        t.filter = function(ent)
            if (ent:GetClass() == 'lps_disguise' and ent:GetPlayer() == self) then return false end
            if ent == self then return false end
            return true
        end

        t.mins = disguise:OBBMins()
        t.maxs = disguise:OBBMaxs()

        local tr = util.TraceHull(t)
        if (tr.Entity and (tr.Entity:IsWorld() or tr.Entity:IsValid())) then
            return true
        end
    end

    t.filter = t.filter or self
    t.mins = self:OBBMins()
    t.maxs = self:OBBMaxs()

    local tr = util.TraceHull(t)
    if (tr.Entity and (tr.Entity:IsWorld() or tr.Entity:IsValid())) then
        return true
    end

    return false
end

--[[---------------------------------------------------------
--   Name: meta:UnStick()
---------------------------------------------------------]]--
function meta:UnStick()
    local newPos = self:GetPos()
    local oldPos = newPos

    local angle = self:GetAngles()
    local forward = angle:Forward()
    local right = angle:Right()
    local up = angle:Up()

    local scale = 1 -- Increase and it will unstuck you from even harder places but with lost accuracy. Please, don't try higher values than 12
    local search = {
        {forward, scale},   -- forward
        {right, scale},     -- right
        {right, -scale},    -- left
        {up, scale},        -- up
        {up, -scale},       -- down
        {forward, -scale},  -- back
    }

    local function NotStuck()
        local t = {
            mask = MASK_PLAYERSOLID,
            start = self:GetPos(),
            endpos = self:GetPos(),
        }

        local disguise = self:GetDisguise()
        if (IsValid(disguise)) then
            t.filter = function(ent)
                if (ent:GetClass() == 'lps_disguise' and ent:GetPlayer() == self) then return false end
                if ent == self then return false end
                return true
            end

            if (util.TraceEntity(t, disguise).StartSolid ~= false) then
               return false
            end
        end

        t.filter = t.filter or self

        return util.TraceEntity(t, self).StartSolid == false
    end

    newPos = self:GetPos()
    oldPos = newPos

    if (NotStuck()) then return true end

    local stuck = true
    for i=1, 6 do
        if (stuck == false) then break end
        for j=1, 100 do
            local origin = self:GetPos()
            origin = origin + search[i][2] * search[i][1]

            self:SetPos(origin)

            if (not NotStuck()) then continue end

            newPos = self:GetPos()
            stuck = false
            break
        end
    end

    if (stuck or not self:IsInWorld()) then
        local spawn = GAMEMODE:PlayerSelectTeamSpawn(self:Team(), self)
        if (IsValid(spawn)) then
            newPos = spawn:GetPos() -- spawn if cant find spot
        end
    end

    if oldPos == newPos then return true end

    self:SetPos(newPos)

    if (self:GetPhysicsObject():IsValid()) then
        self:SetVelocity(vector_origin)
        self:GetPhysicsObject():SetVelocity(vector_origin) -- prevents bugs
    end

    return true
end