if (SERVER) then
    AddCSLuaFile()

    sound.Add({
        name = 'disguise_boing',
        channel = CHAN_WEAPON,
        volume = 1.0,
        level = 90,
        pitch = 100,
        sound = 'entities/disguise/boing.mp3'
    })
end

ENT.Type        = 'anim'
ENT.Base        = 'base_anim'
ENT.Spawnable   = false
ENT.AdminOnly   = false
ENT.RenderGroup = RENDERGROUP_BOTH

DEFINE_BASECLASS('base_anim')

if (SERVER) then

    --[[---------------------------------------------------------
    --   Name: ENT:Initialize()
    ---------------------------------------------------------]]--
    function ENT:Initialize()
        self:SetSolid(SOLID_VPHYSICS)
        self:SetLocked(false)
        self:SetUseType(SIMPLE_USE)
    end

    --[[---------------------------------------------------------
    --   Name: ENT:Use()
    ---------------------------------------------------------]]--
    function ENT:Use(activator, caller, useType, value)
        local ply = self:GetOwner()
        if (not IsValid(ply) or not IsValid(caller) or not caller:IsPlayer() or caller == ply) then return end
        util.Notify(ply, string.format('%s is trying to pick you up! RUUUNNNN!', caller:Nick()))
        self:EmitSound('disguise_boing')
    end

    --[[---------------------------------------------------------
    --   Name: ENT:OnTakeDamage()
    ---------------------------------------------------------]]--
    function ENT:OnTakeDamage(dmgInfo)
        local ply = self:GetOwner()
        if (not IsValid(ply)) then return end
        ply:TakeDamageInfo(dmgInfo)
    end

    --[[---------------------------------------------------------
    --   Name: ENT:SetOwner()
    ---------------------------------------------------------]]--
    function ENT:SetOwner(ent)
        self:SetNWEntity('owner', ent)
        self.BaseClass:SetOwner(ent)
    end

    --[[---------------------------------------------------------
    --   Name: ENT:SetLocked()
    ---------------------------------------------------------]]--
    function ENT:SetLocked(angle)
        if (type(angle) == 'boolean') and (not angle) then
            self:SetNWBool('locked', false)
        elseif (type(angle) == 'boolean') and (angle) then
            self:SetNWBool('locked', true)
            self:SetNWAngle('lockedAngle', self:GetOwner():EyeAngles())
        elseif (type(angle) == 'Angle') then
            self:SetNWBool('locked', true)
            self:SetNWAngle('lockedAngle', Angle(math.Clamp(angle.p,-90, 90), angle.y, 0))
        end
    end

    --[[---------------------------------------------------------
    --   Name: ENT:AdjustLockedAngles()
    ---------------------------------------------------------]]--
    function ENT:AdjustLockedAngles(angle)
        local angles = self:GetNWAngle('lockedAngle') + angle
        self:SetNWAngle('lockedAngle', Angle(math.Clamp(angles.p,-90, 90), angles.y, 0))
    end

    --[[---------------------------------------------------------
    --   Name: ENT:SetLockedAngles()
    ---------------------------------------------------------]]--
    function ENT:SetLockedAngles(angle)
        self:SetNWAngle('locked', angle)
    end
else
    ENT.angles = Angle(0,0,0)
    ENT.vector = Vector(0,0,0)


    --[[---------------------------------------------------------
    --   Name: ENT:Think()
    ---------------------------------------------------------]]--
    function ENT:Think()
        local ply = self:GetOwner()
        if (not IsValid(ply)) then return end

        local locked, lockedAngle = self:GetNWBool('locked', false), self:GetNWAngle('lockedAngle', nil)
        if (not locked or self.angles ~= lockedAngle) then
            local mins, angles = self:OBBMins(), locked and lockedAngle or ply:EyeAngles()
            if (angles.p >= -90 and angles.p <= 90) then
                self.angles = angles
            end
            self.vector = Vector(0, 0, ((mins.x-mins.z)*((self.angles.p < 0 and self.angles.p*-1 or self.angles.p)/90)) + mins.z)
        end

        self:SetAngles(self.angles)
        self:SetPos(ply:GetPos() - self.vector)
    end

    --[[---------------------------------------------------------
    --   Name: ENT:Draw()
    ---------------------------------------------------------]]--
    function ENT:Draw()
        local ply, localPlayer = self:GetOwner(), LocalPlayer()
        if (not IsValid(ply) or not IsValid(localPlayer)) then
            self:DrawModel()
            return
        end
        if (ply == localPlayer) then
            local tpv, dist = GetConVar('lps_tpvp'):GetBool(), GetConVar('lps_tpv_dist'):GetInt()
            if (tpv and dist > 30) then
                self:DrawModel()
            end
        else
            self:DrawModel()
        end
    end
end

--[[---------------------------------------------------------
--   Name: ENT:GetOwner()
---------------------------------------------------------]]--
function ENT:GetOwner()
    return self:GetNWEntity('owner', nil)
end

--[[---------------------------------------------------------
--   Name: ENT:GetLocked()
---------------------------------------------------------]]--
function ENT:GetLocked()
    return self:GetNWBool('locked', false)
end

--[[---------------------------------------------------------
--   Name: ENT:GetLockedAngles()
---------------------------------------------------------]]--
function ENT:GetLockedAngles()
    return self:GetNWAngle('locked')
end