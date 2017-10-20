--[[---------------------------------------------------------
--   Name: GM:PlayerDeath()
---------------------------------------------------------]]--
function GM:PlayerDeath(ply, inflictor, attacker)
    if (GetConVar('lps_hidehud'):GetBool()) then return end

    if (not self.notify or not IsValid(self.notify)) then
        self:CreateGameNotify()
    end

    if (ply == LocalPlayer() and (not IsValid(attacker) or attacker ~= LocalPlayer())) then
        self:PlaySound(lps.sounds.sfx.death, SOUND.SFX)
    end

    if (self:InRound()) then

        if (not IsValid(ply) or not ply:IsPlayer()) then return end
        local pnl = vgui.Create('GameNotice', g_DeathNotify)
        if (attacker == ply) then
            local class = ply:Class()
            local deathText = 'suicided!'
            if (class and class.suicideStrings) then
                deathText = table.Random(class.suicideStrings)
            end
            pnl:AddEntityText(ply)
            pnl:AddText(deathText)
            self.notify:AddItem(pnl)
            return
        end

        if (not IsValid(attacker)) then return end
        if (attacker:IsPlayer()) then
            local class = ply:Class()
            local deathText = 'killed!'
            if (class and class.killStrings) then
                deathText = table.Random(class.killStrings)
            end
            pnl:AddEntityText(attacker)
            pnl:AddText(deathText)
            pnl:AddEntityText(ply)
            self.notify:AddItem(pnl)
            return
        end
    end
end
lps.net.Hook('PlayerDeath', function(data) hook.Call('PlayerDeath', GAMEMODE, data[1], data[2], data[3]) end)


local binds = {
    '+forward',
    '+back',
    '+moveleft',
    '+moveright',
    '+lookup',
    '+lookdown',
    '+left',
    '+right',
    '+jump',
    '+duck',
    '+showscores',
    '+speed',
    '+attack',
    'lastinv',
    '+attack',
    '+attack2',
    'invprev',
    'invnext',
    'pause',
    'cancelselect',
    'toggleconsole',
    'gm_showhelp',
    'gm_showteam',
    'gm_showspare1',
    'gm_showspare2',
    'jpeg',
    'save quick',
    'load quick',
    'toggleconsole',
    'slot1',
    'slot2',
    'slot3',
    'slot4',
    'slot5',
    'slot6',
    'slot7',
    'slot8',
    'slot9',
    'slot0',
    '+menu',
    '+use',
    '+reload',
    'impulse 201',
    'messagemode',
    'messagemode2',
    'impulse 100',
    'gmod_undo',
    '+voicerecord',
    '+menu_context',
    'noclip',
    '+zoom'
}

--[[---------------------------------------------------------
--   Name: GM:PlayerBindPress()
---------------------------------------------------------]]--
function GM:PlayerBindPress(ply, bind, down)
    -- Redirect binds to the spectate system
    if (ply:IsObserver() and down) then
        if (bind == '+jump') then RunConsoleCommand('specmode') end
        if (bind == '+attack') then RunConsoleCommand('specnext') end
        if (bind == '+attack2') then RunConsoleCommand('specprev') end
    end

    if (not table.HasValue(binds, bind)) then
        for _, setting in pairs(lps.bindings.settings) do
            for class, data in pairs(setting) do
                if (input.LookupKeyBinding(data.key) == bind) then
                    return true
                end
            end
        end
    end

    return false
end

--[[---------------------------------------------------------
--   Name: GM:ShouldDrawLocalPlayer()
---------------------------------------------------------]]--
function GM:ShouldDrawLocalPlayer(ply)
    if (IsValid(ply)) then
        local shouldDrawLocalPlayer = ply:ClassCall('ShouldDrawLocalPlayer')
        if (shouldDrawLocalPlayer ~= nil) then
            return shouldDrawLocalPlayer
        end
    end
    return false
end

--[[---------------------------------------------------------
--   Name: GM:CreateMove()
---------------------------------------------------------]]--
function GM:CreateMove(cmd)
    if (cmd:GetMouseWheel() ~= 0) and (input.IsKeyDown(lps.bindings:GetKey('global', 'tpvDistance').key)) then
        RunConsoleCommand('lps_tpv_dist', tostring(math.Clamp(GetConVar('lps_tpv_dist'):GetInt()-(cmd:GetMouseWheel()*5), 0, 150)))
    end

    local localPlayer = LocalPlayer()
    if (IsValid(localPlayer)) then
        localPlayer:ClassCall('CreateMove', cmd)
    end
end

--[[---------------------------------------------------------
--   Name: GM:CalcView(Player ply, Vector origin, Angles angles, Number fov)
--   Desc: Calculates the players view. Also calls the players class
--           CalcView function, as well as GetViewModelPosition and CalcView
--           on the current weapon. Returns a table.
---------------------------------------------------------]]--
function GM:CalcView(ply, origin, angles, fov)

    local view = ply:ClassCall('CalcView', origin, angles, fov) or {['origin'] = origin, ['angles'] = angles, ['fov'] = fov}
    origin = view.origin or origin
    angles = view.angles or angles
    fov = view.fov or fov

    local wep = ply:GetActiveWeapon()

    if (IsValid(wep)) then
        local func = wep.GetViewModelPosition
        if (func) then view.vm_origin,  view.vm_angles = func(wep, origin*1, angles*1) end
        local func = wep.CalcView
        if (func) then view.origin, view.angles, view.fov = func(wep, ply, origin*1, angles*1, fov) end
    end

    return view
end

--[[---------------------------------------------------------
--   Name: GM:CalcViewModelView()
---------------------------------------------------------]]--
function GM:CalcViewModelView(weapon, vm, old_eyepos, old_eyeang, eyepos, eyeang)

    if (not IsValid(weapon)) then return end

    local vm_origin, vm_angles = eyepos, eyeang

    -- Controls the position of all viewmodels
    local func = weapon.GetViewModelPosition
    if (func) then
        local pos, ang = func(weapon, eyepos * 1, eyeang * 1)
        vm_origin = pos or vm_origin
        vm_angles = ang or vm_angles
    end

    -- Controls the position of individual viewmodels
    func = weapon.CalcViewModelView
    if (func) then
        local pos, ang = func(weapon, vm, old_eyepos * 1, old_eyeang * 1, eyepos * 1, eyeang * 1)
        vm_origin = pos or vm_origin
        vm_angles = ang or vm_angles
    end

    local ply = weapon.Owner
    if (IsValid(ply)) then
        local ply_origin, ply_angles = ply:ClassCall('CalcViewModelView', weapon, vm, old_eyepos, old_eyeang, vm_origin, vm_angles)
        if (ply_origin and ply_angles) then
            vm_origin = ply_origin
            vm_angles = ply_angles
        end
    end

    return vm_origin, vm_angles
end

function GM:OnPlayerChat(ply, text, teamChat, dead)
    local tab = {}
    if (IsValid(ply)) then
        if (dead) then
            table.insert(tab, Color(255, 30, 40))
            table.insert(tab, '*DEAD* ')
        end

        table.insert(tab, team.GetColor(ply:Team()))

        if (teamChat) then
            table.insert(tab, '(TEAM) ')
        end

        if (lps.support[ply:SteamID()]) then
            table.insert(tab, Color(252, 249, 53))
            table.insert(tab, string.format('%s ', lps.support[ply:SteamID()]))
            table.insert(tab, team.GetColor(ply:Team()))
        end
        table.insert(tab, ply)
    else
        table.insert(tab, 'Console')
    end

    table.insert(tab, Color(255, 255, 255))
    table.insert(tab, string.format(': %s', text))

    chat.AddText(unpack(tab))

    return true
end

