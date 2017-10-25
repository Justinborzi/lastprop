if (SERVER) then
    AddCSLuaFile()

    sound.Add({
        name = 'weapon_lastman_reload',
        channel = CHAN_WEAPON,
        volume = 1.0,
        level = 90,
        pitch = 100,
        sound = 'weapons/lastman/reload.mp3'
    })

    sound.Add({
        name = 'weapon_lastman_shoot',
        channel = CHAN_WEAPON,
        volume = 1.0,
        level = 90,
        pitch = 100,
        sound = 'weapons/lastman/shoot.mp3'
    })

    sound.Add({
        name = 'weapon_lastman_deploy',
        channel = CHAN_WEAPON,
        volume = 1.0,
        level = 90,
        pitch = 100,
        sound = 'weapons/lastman/deploy.mp3'
    })
end

game.AddParticles('particles/laserp_particles.pcf')
PrecacheParticleSystem('Weapon_LaserP_Beam')

SWEP.PrintName      = 'Frikin Laser EYES'
SWEP.Spawnable      = true
SWEP.AdminOnly      = false
SWEP.DrawAmmo       = false
SWEP.DrawCrosshair  = false
SWEP.Slot           = 1
SWEP.SlotPos        = 1
SWEP.ViewModel      = Model('models/weapons/c_arms_animations.mdl')

SWEP.Primary.Delay          = 0.3
SWEP.Primary.ReloadTime     = 2
SWEP.Primary.Recoil         = .5
SWEP.Primary.ClipSize       = 20
SWEP.Primary.DefaultClip    = 20
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = 'none'

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = 'none'

--[[---------------------------------------------------------
--   Name: SWEP:Initialize()
---------------------------------------------------------]]--
function SWEP:Initialize()
    self:SetWeaponHoldType('magic')
    self.Weapon:SetClip1(self.Primary.ClipSize)
    self.Weapon.Clip1 = function(self)
        if (self.Clip == nil) then
            self.Clip = self.Primary.DefaultClip
        end
        return self.Clip
    end
end

--[[---------------------------------------------------------
--   Name: SWEP:GetMaxClip1()
---------------------------------------------------------]]--
function SWEP:GetMaxClip1()
    return self.Primary.ClipSize
end

--[[---------------------------------------------------------
--   Name: SWEP:SetClip1()
---------------------------------------------------------]]--
function SWEP:SetClip1(num)
    self.Weapon.Clip = num
end

--[[---------------------------------------------------------
--   Name: SWEP:TakePrimaryAmmo()
---------------------------------------------------------]]--
function SWEP:TakePrimaryAmmo(num)
    self:SetClip1(self.Weapon:Clip1() - num)
end

--[[---------------------------------------------------------
--   Name: SWEP:CanPrimaryAttack()
---------------------------------------------------------]]--
function SWEP:CanPrimaryAttack()
    if (self.Weapon:Clip1() <= 0) then
        self:Reload()
        return false
    end
    return true
end

--[[---------------------------------------------------------
--   Name: SWEP:PrimaryAttack()
---------------------------------------------------------]]--
function SWEP:PrimaryAttack()

    if (not self:CanPrimaryAttack()) then return end

    local ply, tr, eyepos = self.Owner, self.Owner:GetEyeTrace(), self.Owner:GetShootPos()
    if (SERVER) then

        if (tr.Entity and IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(1000)
            dmgInfo:SetAttacker(ply)
            dmgInfo:SetInflictor(self)

            if(dmgInfo.SetDamageType) then
                dmgInfo:SetDamagePosition(tr.HitPos)
                dmgInfo:SetDamageType(DMG_DISSOLVE)
            end
            tr.Entity:DispatchTraceAttack(dmgInfo, tr.HitPos, tr.HitPos - (tr.HitPos - ply:GetShootPos()):GetNormal():Angle():Forward() * 20)
        end

        ply:FireBullets({
            Num = 1,
            Src = eyepos,
            Dir = ply:GetAimVector(),
            Spread = Vector(self.Primary.Cone , self.Primary.Cone, 0),
            Tracer = 0,
            TracerName = '',
            Force = 1000,
            Damage = 1000,
            AmmoType = '',
        })

        ply:EmitSound('weapon_lastman_shoot')
    end

    ply:ViewPunch(Angle(math.Rand(-0.4, -0.2) * self.Primary.Recoil, math.Rand(-0.3, 0.2) * self.Primary.Recoil, 0))
    util.ParticleTracerEx('Weapon_LaserP_Beam', eyepos, tr.HitPos, true, self:GetOwner():EntIndex(), 1)
    util.Decal('FadingScorch', tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

--[[---------------------------------------------------------
--   Name: SWEP:Reload()
---------------------------------------------------------]]--
function SWEP:Reload()
    if not ((self:Clip1()) < (self.Primary.ClipSize)) then return end
    self:SetNextPrimaryFire(CurTime() + self.Primary.ReloadTime)
    self:SetClip1(self.Primary.ClipSize)
    if (SERVER) then
        self:GetOwner():EmitSound('weapon_lastman_reload')
    end
end

--[[---------------------------------------------------------
--   Name: SWEP:SecondaryAttack()
---------------------------------------------------------]]--
function SWEP:SecondaryAttack()
    return false
end

--[[---------------------------------------------------------
--   Name: SWEP:HasAmmo()
---------------------------------------------------------]]--
function SWEP:HasAmmo()
    return true
end

if (SERVER) then

    --[[---------------------------------------------------------
    --   Name: SWEP:Deploy()
    ---------------------------------------------------------]]--
    function SWEP:Deploy()
        self:EmitSound('weapon_lastman_deploy')
        return true
    end
else

    --[[---------------------------------------------------------
    --   Name: SWEP:DrawWorldModel()
    ---------------------------------------------------------]]--
    function SWEP:DrawWorldModel()
        return false
    end
end

