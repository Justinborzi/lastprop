if SERVER then
	hook.Add('PostGamemodeLoaded', 'PostGamemodeLoaded:LPSMap:Underwataaa', function()
        for id, loadout in pairs(GM.loadouts) do
            if (GM.loadouts[id]['weapon_smg1']) then
                GM.loadouts[id]['weapon_smg1_underwata'] = table.Copy(GM.loadouts[id]['weapon_smg1'])
                GM.loadouts[id]['weapon_smg1'] = nil
            end

            if (GM.loadouts[id]['weapon_ar2']) then
                GM.loadouts[id]['weapon_ar2_underwata'] = table.Copy(GM.loadouts[id]['weapon_ar2'])
                GM.loadouts[id]['weapon_ar2'] = nil
            end
        end
	end)
end