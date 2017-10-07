

--[[---------------------------------------------------------
--   Name: GM:TauntMenu()
---------------------------------------------------------]]--
function GM:TauntMenu()
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer) or not localPlayer:GetVar('canTaunt', false)) then return end

    local tauntPack, tauntType = localPlayer:GetTauntPack(), localPlayer:GetTauntType()
    if (not tauntPack) or
       (not tauntType) or
       (not lps.taunts.sounds[tauntPack]) or
       (not lps.taunts.sounds[tauntPack][tauntType]) then
      return
    end

    if (IsValid(self.tauntMenu)) then
        self.tauntMenu:Remove()
        self.tauntMenu = nil
    end

    local letters = {}
    gui.EnableScreenClicker(true)
    self.tauntMenu = DermaMenu()
    self.tauntMenu:ParentToHUD()
    self.tauntMenu:AddOption(tauntType:gsub("^%l", string.upper))
    self.tauntMenu:AddSpacer()
    for _, t in SortedPairs(lps.taunts.sounds[tauntPack][tauntType]) do
        local letter = string.upper(string.sub(t.label, 1, 1))
        if (not letters[letter]) then
            letters[letter] = self.tauntMenu:AddSubMenu(letter)
        end
        letters[letter]:AddOption( string.format('%s (%ss)', t.label,  t.length) , function()
            RunConsoleCommand("taunt", t.name )
        end)
    end
    self.tauntMenu:AddSpacer()
    self.tauntMenu:AddOption('Close')
    self.tauntMenu:Open(gui.MouseX(), gui.MouseY() - ((table.Count(letters) + 1) * 21))
    self.tauntMenu.OnRemove = function()
        gui.EnableScreenClicker(false)
    end
end

--[[---------------------------------------------------------
--   Hook: Think:TauntMenu
---------------------------------------------------------]]--
hook.Add('Think', 'Think:TauntMenu', function()
    local localPlayer = LocalPlayer()
    if ((not IsValid(localPlayer) or not localPlayer:GetVar('canTaunt', false)) and IsValid(GAMEMODE.tauntMenu)) then
        GAMEMODE.tauntMenu:Remove()
        GAMEMODE.tauntMenu = nil
    end
end)

--[[---------------------------------------------------------
--   Hook: IsBusy:TauntMenu
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:TauntMenu', function ()
    if (IsValid(GAMEMODE.tauntMenu) and GAMEMODE.tauntMenu:IsVisible()) then return true end
end)