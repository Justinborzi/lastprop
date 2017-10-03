if (SERVER) then AddCSLuaFile() end

--[[---------------------------------------------------------
--   Name: EFFECT:Init()
---------------------------------------------------------]]--
function EFFECT:Init(data)
    self.StartTime = CurTime()
    self.NextFlame = CurTime()
    self.pos = data:GetOrigin()
    self.Scale = data:GetScale()
    self.Mag = data:GetMagnitude()
    self.Emitter = ParticleEmitter(self.pos)
    for i = 1, 17 do
        local t = Vector(math.Rand(-self.Scale, self.Scale), math.Rand(-self.Scale, self.Scale), math.Rand(0, self.Mag))
        local particle = self.Emitter:Add('particle/smokesprites_000' .. math.random(1, 9), self.pos + t)
        particle:SetVelocity(t:GetNormal())
        particle:SetDieTime(5.2)
        particle:SetStartAlpha(20)
        particle:SetEndAlpha(0)
        particle:SetStartSize(self.Scale * 2)
        particle:SetEndSize(self.Scale * 2)
        particle:SetRoll(math.random(0, 360))
        local i = math.random(50, 150)
        particle:SetColor(i, i, i)
    end
end

--[[---------------------------------------------------------
--   Name: EFFECT:Think()
---------------------------------------------------------]]--
function EFFECT:Think()
    self.Emitter:Finish()
    return false
end

--[[---------------------------------------------------------
--   Name: EFFECT:Render()
---------------------------------------------------------]]--
function EFFECT:Render()

end

