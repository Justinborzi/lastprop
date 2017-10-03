// Props underwater should die on this level
if SERVER then
	local nextHurt = 0
	hook.Add('Think', 'Think:LPSMap:DePort', function()
		if nextHurt > CurTime() then
			for _, ply in pairs(team.GetPlayers(TEAM.PROPS)) do
				if IsValid(ply) and ply:Alive() and ply:WaterLevel() >= 1 then
                    local dmgInfo = DamageInfo()
                    dmgInfo:SetDamage(25)
                    dmgInfo:SetDamageType(DMG_RADIATION)
                    ply:TakeDamageInfo(dmgInfo)
				end
			end
			nextHurt = CurTime() + 1
		end
	end)
end