--[[---------------------------------------------------------
--   Name: GM:PropBreak()
---------------------------------------------------------]]--
function GM:PropBreak( attacker, prop )
    --todo: maybe a perk of some kind
end

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
