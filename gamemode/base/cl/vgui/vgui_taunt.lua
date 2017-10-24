

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

    gui.EnableScreenClicker(true)
    self.tauntMenu = DermaMenu()
    self.tauntMenu:ParentToHUD()
    self.tauntMenu:AddOption(tauntType:gsub('^%l', string.upper), function() RunConsoleCommand('randomtaunt') end)
    self.tauntMenu:AddSpacer()

    local function addPack(menu, tPack, tType)

        local letters = {}
        for _, t in pairs(lps.taunts.sounds[tPack][tType]) do
            local letter = string.upper(string.sub(t.label, 1, 1))
            if (not letters[letter]) then
                letters[letter] = {}
            end
            table.insert(letters[letter], t)
        end

        local menus = {}
        for letter, taunts in SortedPairs(letters) do
            if (not menus[letter]) then
                menus[letter] = menu:AddSubMenu(letter)
            end
            for _, t in SortedPairs(taunts) do
                menus[letter]:AddOption(string.format('%s (%ss)', t.label, math.Round(t.length, 1)) , function()
                    RunConsoleCommand('taunt', t.name, tPack)
                end)
            end
        end

        return table.Count(letters)
    end

    local count
    if (GetConVar('lps_tauntpack'):GetString() == 'any' and #lps.taunts.packs > 1) then
        count = #lps.taunts.packs
        for _, pack in SortedPairs(lps.taunts.packs) do
            addPack(self.tauntMenu:AddSubMenu(pack), pack, tauntType)
        end
    else
        count = addPack(self.tauntMenu, tauntPack, tauntType)
    end


    self.tauntMenu:AddSpacer()
    self.tauntMenu:AddOption('Close')
    self.tauntMenu:Open(gui.MouseX(), gui.MouseY() - ((count + 1) * 21))
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