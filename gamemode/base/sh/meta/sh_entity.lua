local meta = FindMetaTable('Entity')
if not meta then return end

--[[---------------------------------------------------------
--   Name: meta:IsValidDisguise()
---------------------------------------------------------]]--
function meta:IsValidDisguise()
    return (not table.HasValue(lps.banned, self:GetModel()) and table.HasValue({'prop_physics', 'prop_physics_multiplayer'}, self:GetClass()))
end

--[[---------------------------------------------------------
--   Name: meta:IsDisguise()
---------------------------------------------------------]]--
function meta:IsDisguise()
    return tobool(self:GetClass() == 'disguise')
end

--[[---------------------------------------------------------
--   Name: meta:GetSize()
---------------------------------------------------------]]--
function meta:GetSize()
    local OBBMaxs, OBBMins = self:OBBMaxs(), self:OBBMins()
    local xy = math.Round(math.Max(OBBMaxs.x, OBBMaxs.y))
    local z, dz = math.Round(OBBMaxs.z - OBBMins.z)
    if z > 10 && z <= 30 then
        dz = z-(z*0.5)
    elseif z > 30 && z <= 40 then
        dz = z-(z*0.2)
    elseif z > 40 && z <= 50 then
        dz = z-(z*0.1)
    else
        dz = z
    end
    return xy, xy * -1, z, dz
end