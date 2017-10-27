--[[---------------------------------------------------------
--   Name: GM:EntityTakeDamage()
---------------------------------------------------------]]--
function GM:EntityTakeDamage(ent, dmgInfo)
    if (dmgInfo) then
        local attacker = dmgInfo:GetAttacker()
        if (IsValid(attacker) and attacker:IsPlayer() and attacker:Alive())  then
            attacker:ClassCall('OnCausedDamage', ent, dmgInfo)
        end
    end
end

--[[---------------------------------------------------------
--   Name: GM:FindUseEntity()
---------------------------------------------------------]]--
function GM:FindUseEntity(ply, ent)
    if (ply:Team() ~= TEAM.PROPS) then return ent end
    local tr = ply:GetEyeTrace()
    if (not IsValid(tr.Entity) or ent == tr.Entity) then return ent end
    if (tr.Entity:IsValidDisguise()) then return tr.Entity end
end