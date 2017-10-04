
--[[---------------------------------------------------------
--   Name: GM:RegisterBindings()
---------------------------------------------------------]]--
function GM:RegisterBindings()
    lps.bindings:Register('global', 'localChat', KEY_Z, INPUT.KEY, 'Local Voice', 'When key is pressed only your team will be able to hear you.')
    lps.bindings:Register('global', 'teamChat', KEY_C, INPUT.KEY, 'Team Chat', 'When key is pressed your voice will emit from you, not globally.')
    lps.bindings:Register('global', 'tpvDistance', KEY_LALT, INPUT.KEY, 'View Adjust', 'When key is pressed you can adjust your view distance in thirdperson using the scroll wheel.')
    lps.bindings:Register('global', 'tpv', KEY_CAPSLOCK, INPUT.KEY, '3rd Person', 'Toggles Thirdperson View.')
    lps.bindings:Register('global', 'tpvoffset', KEY_B, INPUT.KEY, '3rd Person Offset', 'Toggles Thirdperson Offset.')
end

--[[---------------------------------------------------------
--   Name: GM:IsBusy()
---------------------------------------------------------]]--
function GM:IsBusy()
    return false
end

--[[---------------------------------------------------------
--   Name: GM:KeyDown()
---------------------------------------------------------]]--
function GM:KeyDown(key, keycode, char, keytype, busy, cursor)

    local tpv = lps.bindings:GetKey('global', 'tpv')
    if (key == tpv.key and keytype == tpv.type and not busy and not cursor) then
        local teamID = LocalPlayer():Team()
        local convar = (teamID == TEAM.PROPS and 'lps_tpvp') or (teamID == TEAM.HUNTERS and 'lps_tpvh')
        if (GetConVar(convar):GetBool()) then
            RunConsoleCommand(convar, '0')
        else
            RunConsoleCommand(convar, '1')
        end
    end

    local tpvoffset = lps.bindings:GetKey('global', 'tpvoffset')
    if (key == tpvoffset.key and keytype == tpvoffset.type and not busy and not cursor) then
        local teamID = LocalPlayer():Team()
        local convar = (teamID == TEAM.PROPS and 'lps_tpvp') or (teamID == TEAM.HUNTERS and 'lps_tpvh')
        if (GetConVar(convar):GetBool()) then
            if (GetConVar('lps_tpv_offset_on'):GetBool()) then
                RunConsoleCommand('lps_tpv_offset_on', '0')
            else
                RunConsoleCommand('lps_tpv_offset_on', '1')
            end
        end
    end

    local localChat = lps.bindings:GetKey('global', 'localChat')
    if(key == localChat.key and keytype == localChat.type and not busy and not cursor) then
        RunConsoleCommand('+localchat')
        RunConsoleCommand('+voicerecord')
    end

    local teamChat = lps.bindings:GetKey('global', 'teamChat')
    if(key == teamChat.key and keytype == teamChat.type and not busy and not cursor) then
        RunConsoleCommand('+teamchat')
        RunConsoleCommand('+voicerecord')
    end

    local localPlayer = LocalPlayer()
    if (IsValid(localPlayer)) then
        localPlayer:ClassCall('OnKeyDown', key, keycode, char, keytype, busy, cursor)
    end
end

--[[---------------------------------------------------------
--   Name: GM:KeyUp()
---------------------------------------------------------]]--
function GM:KeyUp(key, keycode, char, keytype, busy, cursor)

    local localChat = lps.bindings:GetKey('global', 'localChat')
    if(key == localChat.key and keytype == localChat.type) then
        RunConsoleCommand('-voicerecord')
        RunConsoleCommand('-localchat')
    end

    local teamChat = lps.bindings:GetKey('global', 'teamChat')
    if(key == teamChat.key and keytype == teamChat.type) then
        RunConsoleCommand('-voicerecord')
        RunConsoleCommand('-teamchat')
    end

    local localPlayer = LocalPlayer()
    if (IsValid(localPlayer)) then
        localPlayer:ClassCall('OnKeyUp', key, keycode, char, keytype, busy, cursor)
    end
end


--[[---------------------------------------------------------
--   Name: GM:InputMouseApply()
---------------------------------------------------------]]--
function GM:InputMouseApply(cmd, x, y, angle)
    local localPlayer = LocalPlayer()
    local cls_cmd, cls_x, cls_y, cls_angle
    if (IsValid(localPlayer)) then
        cls_cmd, cls_x, cls_y, cls_angle = localPlayer:ClassCall('InputMouseApply', cmd, x, y, angle)
    end
    return cls_cmd or cmd, cls_x or x, cls_y or y, cls_angle or angle
end
