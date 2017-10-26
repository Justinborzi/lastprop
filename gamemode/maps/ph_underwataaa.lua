if SERVER then
	hook.Add('Initialize', 'Initialize:LPSMap:Underwataaa', function()
        for id, loadout in pairs(GAMEMODE.loadouts) do
            if (GAMEMODE.loadouts[id]['weapon_smg1']) then
                GAMEMODE.loadouts[id]['weapon_smg1_underwata'] = table.Copy(GAMEMODE.loadouts[id]['weapon_smg1'])
                GAMEMODE.loadouts[id]['weapon_smg1'] = nil
            end
            if (GAMEMODE.loadouts[id]['weapon_ar2']) then
                GAMEMODE.loadouts[id]['weapon_ar2_underwata'] = table.Copy(GAMEMODE.loadouts[id]['weapon_ar2'])
                GAMEMODE.loadouts[id]['weapon_ar2'] = nil
            end
        end
	end)
end