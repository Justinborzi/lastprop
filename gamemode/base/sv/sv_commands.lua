
--[[---------------------------------------------------------
--   concommand: changeteam
---------------------------------------------------------]]--
concommand.Add('changeteam', function(pl, cmd, args) hook.Call('PlayerRequestTeam', GAMEMODE, pl, tonumber(args[1])) end)

--[[---------------------------------------------------------
--   concommand: autoteam
---------------------------------------------------------]]--
concommand.Add('autoteam', function(pl, cmd, args) hook.Call('PlayerRequestTeam', GAMEMODE, pl, team.BestAutoJoinTeam()) end)

--[[---------------------------------------------------------
--   concommand: playermute
---------------------------------------------------------]]--
concommand.Add('playermute', function(pl, cmd, args) hook.Call('MutePlayer', GAMEMODE, pl, player.GetByUniqueID(args[1])) end)

--[[---------------------------------------------------------
--   concommand: stuck
---------------------------------------------------------]]--
concommand.Add('stuck', function(ply, cmd, args)
    if (ply:IsStuck()) then
        util.Notify(ply, '[STUCK] Attempting to unstick you!')
        if(ply:UnStick()) then
            util.Notify(ply, '[STUCK] You should be unstuck!')
        else
            util.Notify(ply, '[STUCK] Unable to find a suitable spot!')
        end
    else
        util.Notify(ply, '[STUCK] You\'re not stuck!')
    end
end)

--[[---------------------------------------------------------
--   concommand: stats
---------------------------------------------------------]]--
concommand.Add('stats', function(ply, cmd, args)
    GAMEMODE:ShowStats(ply)
end)

--[[---------------------------------------------------------
--   concommand: options
---------------------------------------------------------]]--
concommand.Add('options', function(ply, cmd, args)
    ply:ConCommand('lps_show_options')
end)

--[[---------------------------------------------------------
--   concommand: bindings
---------------------------------------------------------]]--
concommand.Add('bindings', function(ply, cmd, args)
    ply:ConCommand('lps_show_bindings')
end)

--[[---------------------------------------------------------
--   concommand: togglelock
---------------------------------------------------------]]--
concommand.Add('togglelock', function(ply, cmd, args)
    local disguise = ply:GetDisguise()
    if (IsValid(disguise)) then
        if(disguise:GetLocked()) then
            disguise:SetLocked(false)
        else
            disguise:SetLocked(true)
        end
    end
end)

--[[---------------------------------------------------------
--   concommand: lock
---------------------------------------------------------]]--
concommand.Add('lock', function(ply, cmd, args)
    local disguise = ply:GetDisguise()
    if (IsValid(disguise) and not disguise:GetLocked()) then
        disguise:SetLocked(true)
    end
end)

--[[---------------------------------------------------------
--   concommand: unlock
---------------------------------------------------------]]--
concommand.Add('unlock', function(ply, cmd, args)
    local disguise = ply:GetDisguise()
    if (IsValid(disguise) and disguise:GetLocked()) then
        disguise:SetLocked(false)
    end
end)

--[[---------------------------------------------------------
--   concommand: locksnap
---------------------------------------------------------]]--
concommand.Add('locksnap', function(ply, cmd, args)
    local disguise = ply:GetDisguise()
    if (IsValid(disguise) and not disguise:GetLocked()) then
        local angles = ply:EyeAngles()
        if (angles.p > 45) then
            disguise:SetLocked(Angle(90, angles.y, 0))
        elseif (angles.p < -45) then
            disguise:SetLocked(Angle(-90, angles.y, 0))
        else
            disguise:SetLocked(Angle(0, angles.y, 0))
        end
    end
end)

--[[---------------------------------------------------------
--   concommand: lockadjust
---------------------------------------------------------]]--
concommand.Add('lockadjust', function(ply, cmd, args)
    local disguise = ply:GetDisguise()
    if (IsValid(disguise) and disguise:GetLocked()) then
        disguise:AdjustLockedAngles(Angle(table.concat(args, ' ')))
    end
end)

--[[---------------------------------------------------------
--   concommand: taunt
---------------------------------------------------------]]--
concommand.Add('taunt', function(ply, cmd, args)
    if(ply:CanTaunt()) then
        ply:PlayTaunt(args[1], args[2])
    end
end)

--[[---------------------------------------------------------
--   concommand: randomtaunt
---------------------------------------------------------]]--
concommand.Add('randomtaunt', function(ply, cmd, args)
    if(ply:CanTaunt()) then
        ply:RandomTaunt(tonumber(args[1]), tonumber(args[2]))
    end
end)

--[[---------------------------------------------------------
--   concommand: +replaceprop
---------------------------------------------------------]]--
concommand.Add('+replaceprop', function(ply, cmd, args)
    ply:SetVar('replaceProp', true)
end)

--[[---------------------------------------------------------
--   concommand: -replaceprop
---------------------------------------------------------]]--
concommand.Add('-replaceprop', function(ply, cmd, args)
    ply:SetVar('replaceProp', false)
end)


--[[---------------------------------------------------------
--   concommand: +teamchat
---------------------------------------------------------]]--
concommand.Add('+teamchat', function(ply, cmd, args)
    ply:SetVar('teamChat', true)
end)

--[[---------------------------------------------------------
--   concommand: -teamchat
---------------------------------------------------------]]--
concommand.Add('-teamchat', function(ply, cmd, args)
    ply:SetVar('teamChat', false)
end)

--[[---------------------------------------------------------
--   concommand: +localchat
---------------------------------------------------------]]--
concommand.Add('+localchat', function(ply, cmd, args)
    ply:SetVar('localChat', true)
end)

--[[---------------------------------------------------------
--   concommand: -localchat
---------------------------------------------------------]]--
concommand.Add('-localchat', function(ply, cmd, args)
    ply:SetVar('localChat', false)
end)

--[[---------------------------------------------------------
--   concommand: banprop
---------------------------------------------------------]]--
concommand.Add('banprop', function(ply, cmd, args)
    if (ply:IsAdmin() or ply:IsSuperAdmin()) then
        local tr = ply:GetEyeTrace()
        if (not IsValid(tr.Entity)) then return end
        if (table.HasValue({'prop_physics', 'prop_physics_multiplayer', 'lps_disguise'}, tr.Entity:GetClass())) then
            local model = tr.Entity:GetModel()
            if (table.HasValue(lps.banned, model)) then
                util.Notify(ply, 'That prop is already banned.')
            else
                util.Notify(ply, string.format('Added \'%s\' to the banned props list.', model))
                table.insert(lps.banned, model)
                lps.fs:Save(string.format('%s/%s', lps.paths.data, 'banned_props.txt'), lps.banned)
            end
        end
    end
end)
