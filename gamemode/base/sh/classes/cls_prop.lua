local CLASS = {}
CLASS.name = 'Prop'
CLASS.description = 'As a Prop you have hide from Hunters, you can turn into an existing prop on the map and then find a good hiding spot. Press [E] to replicate the prop you are looking at. Your health is scaled based on the size of the prop you replicate, if your become the last prop standing you\'ll get a gun and can hunt down the Hunters!'

CLASS.playerModel = {
    'male01',
    'male02',
    'male03',
    'male04',
    'male05',
    'male06',
    'male07',
    'male08',
    'male09',
    'male10',
    'female01',
    'female02',
    'female03',
    'female04',
    'female05',
    'female06',
    'female07',
    'female08',
    'female09',
    'female10',
    'kleiner',
}

CLASS.suicideStrings  = {
    'died for FREEDOM!',
    'is dead...',
    'fell over and died.',
    'ran into a wall.',
    'became a bomb.',
}

CLASS.killStrings   = {
    'murdered',
    'killed',
    'destroyed',
    'RIPed',
    'redrumed',
    'pooped on',
}

CLASS.walkSpeed            = 250   --
CLASS.crouchedWalkSpeed    = 0.2   --
CLASS.runSpeed             = 350   --
CLASS.duckSpeed            = 0.01  --
CLASS.jumpPower            = 280   --
CLASS.gravity              = 1     --

CLASS.maxHealth            = 100   --
CLASS.startHealth          = 100   --
CLASS.startArmor           = 0     --

CLASS.drawViewModel        = true  --
CLASS.canUseFlashlight     = true  --
CLASS.dropWeaponOnDie      = false --
CLASS.teammateNoCollide    = true  --
CLASS.avoidPlayers         = true  -- Automatically avoid players that we're no colliding
CLASS.fullRotation         = false -- Allow the player's model to rotate upwards, etc etc

--[[---------------------------------------------------------
   CLIENT
---------------------------------------------------------]]--

function CLASS:RegisterBindings()
     lps.bindings:Register('prop', 'tauntLong', KEY_3, INPUT.KEY, 'Taunt Long',  'When pressed you will taunt for 11 to 60 seconds.')
     lps.bindings:Register('prop', 'tauntMedium', KEY_2, INPUT.KEY, 'Taunt Medium',  'When pressed you will taunt for 6 to 10 seconds.')
     lps.bindings:Register('prop', 'tauntShort', KEY_1, INPUT.KEY, 'Taunt Short',  'When pressed you will taunt for 0 to 5 seconds.')
     lps.bindings:Register('prop', 'taunt', KEY_T, INPUT.KEY, 'Taunt',  'When pressed you will random taunt.')
     lps.bindings:Register('prop', 'replace', KEY_LCONTROL, INPUT.KEY, 'Prop Replace',  'When pressed you will replace the prop you want to become.')
     lps.bindings:Register('prop', 'adjust', KEY_LSHIFT, INPUT.KEY, 'Lock Adjust',  'When pressed you can adjust the angle your disguise is locked at by using the mouse wheel.')
     lps.bindings:Register('prop', 'lock', MOUSE_LEFT, INPUT.MOUSE, 'Lock',  'Locks your disguise.')
     lps.bindings:Register('prop', 'unlock', MOUSE_RIGHT, INPUT.MOUSE, 'Unlock',  'Unlocks your disguise.')
     lps.bindings:Register('prop', 'snap', MOUSE_MIDDLE, INPUT.MOUSE, 'Snap Lock',  'Locks your disguise to the nearest flat angle.')
end

function CLASS:PreDrawHalos(ply)
    for _, v in pairs(team.GetPlayers(TEAM.PROPS)) do
        if (IsValid(v) and v:Alive() and v ~= ply) then
            local disguise = v:GetDisguise()
            if (IsValid(disguise)) then
                halo.Add({disguise}, team.GetColor(TEAM.PROPS), 2, 2, 2, true, true)
            end
        end
    end

    local tr = ply:GetEyeTrace()
    if (not IsValid(tr.Entity)) then return end

    if  (ply:CanDisguise() and not ply:DisguiseLocked() and tr.HitPos:Distance(tr.StartPos) < 150) and
        (table.HasValue({'prop_physics', 'prop_physics_multiplayer'}, tr.Entity:GetClass())) then
        if (tr.Entity:IsValidDisguise() and tr.Entity:GetModel() ~= ply:GetVar('disguiseModel', '')) then
            halo.Add({tr.Entity}, Color(50, 220, 50), 2, 2, 2, true, true)
        else
            halo.Add({tr.Entity}, Color(220, 50, 50), 2, 2, 2, true, true)
        end
    end
end

function CLASS:HUDDrawTargetID(ply)
    local tr = ply:GetEyeTrace()
    if (not IsValid(tr.Entity)) then return end

    if (tr.Entity:GetClass() == 'lps_disguise') or
       ((tr.Entity:IsPlayer()) and table.HasValue({TEAM.HUNTERS, TEAM.PROPS}, tr.Entity:Team())) then
        local ply = tr.Entity:GetClass() == 'lps_disguise' and tr.Entity:GetPlayer() or tr.Entity
        if (not IsValid(ply)) then return end
        surface.SetFont('LPS30')
        local text = ply:Nick()
        local w, h = surface.GetTextSize(text)
        local x, y = (ScrW()/2) - (w/2),  (ScrH()/2) + 30
        draw.SimpleText(text, 'LPS30', x + 1, y + 1, Color(0, 0, 0, 120))
        draw.SimpleText(text, 'LPS30', x + 2, y + 2, Color(0, 0, 0, 50))
        draw.SimpleText(text, 'LPS30', x, y, team.GetColor(ply:Team()))
    end
end

function CLASS:HUDShouldDraw(ply, name)
    if (name == 'CHudWeaponSelection' and not IsValid(ply:GetActiveWeapon())) then return false end
end

function CLASS:OnKeyDown(ply, key, keycode, char, keytype, busy, cursor)
    if (busy or cursor or not ply:Alive() or ply:IsLastMan()) then return end

    if (ply:CanTaunt()) then
        local keys = {
            {binding = lps.bindings:GetKey('prop', 'tauntLong'),    length = {11, 60}},
            {binding = lps.bindings:GetKey('prop', 'tauntMedium'),  length = {6, 10}},
            {binding = lps.bindings:GetKey('prop', 'tauntShort'),   length = {0, 5}},
            {binding = lps.bindings:GetKey('prop', 'taunt')},
        }

        for _, data in pairs(keys) do
            if (key == data.binding.key and keytype == data.binding.type) then
                RunConsoleCommand('randomtaunt', data.length and data.length[1] or nil, data.length and data.length[2] or nil)
                break
            end
        end
    end

    if (ply:IsDisguised()) then
        local locked = ply:DisguiseLocked()
        local keys = {
            {binding = lps.bindings:GetKey('prop', 'snap'),   sound = lps.sounds.ui.lock,   cmd = 'locksnap', condition = not locked},
            {binding = lps.bindings:GetKey('prop', 'lock'),   sound = lps.sounds.ui.lock,   cmd = 'lock',     condition = not locked},
            {binding = lps.bindings:GetKey('prop', 'unlock'), sound = lps.sounds.ui.unlock, cmd = 'unlock',   condition = locked}
        }

        for _, data in pairs(keys) do
            if (key == data.binding.key and keytype == data.binding.type and data.condition) then
                RunConsoleCommand(data.cmd)
                ply:LPSPlaySound(data.sound, SOUND.UI)
                break
            end
        end
    end

    local replace = lps.bindings:GetKey('prop', 'replace')
    if (key == replace.key and keytype == replace.type) then
        RunConsoleCommand('+replaceprop')
    end

    local adjust = lps.bindings:GetKey('prop', 'adjust')
    if (key == adjust.key and keytype == adjust.type) then
        ply:SetVar('lockAdjust', true)
    end
end

function CLASS:OnKeyUp(ply, key, keycode, char, keytype, busy, cursor)
    local replace = lps.bindings:GetKey('prop', 'replace')
    if (key == replace.key and keytype == replace.type) then
        RunConsoleCommand('-replaceprop')
    end

    local adjust = lps.bindings:GetKey('prop', 'adjust')
    if (key == adjust.key and keytype == adjust.type) then
        ply:SetVar('lockAdjust', false)
    end
end

function CLASS:CreateMove(ply, cmd)
    if  (ply:IsDisguised()) and
        (ply:DisguiseLocked()) and
        (cmd:GetMouseWheel() ~= 0) and
        (ply:GetVar('lockAdjust', false))
    then
        RunConsoleCommand('lockadjust', (cmd:GetMouseWheel()), 0, 0)
    end
end

function CLASS:ShouldDrawLocalPlayer(ply)
    return GetConVar('lps_tpvp'):GetBool()
end

function CLASS:CalcView(ply, origin, angles, fov)
    if (not IsValid(ply) or ply:IsObserver()) then return end

    local tpv = GetConVar('lps_tpvp'):GetBool()
    local view = {}
    local dist = math.Clamp(GetConVar('lps_tpv_dist'):GetInt(), 0, 100)
    local offset = GetConVar('lps_tpv_offset_on'):GetBool() and math.Clamp(GetConVar('lps_tpv_offset'):GetInt(), 0, 15) or 0

    view.angles  = angles
    view.origin  = ply:IsDisguised() and (ply:GetPos() + Vector(0, 0, ply:GetVar('disguiseHull', {hullz = 72}).hullz)) or origin
    view.fov     = fov

    if (IsValid(ply:GetActiveWeapon()) and not tpv) or (not tpv) then
        return view
    end

    local trData = {
        start  = view.origin,
        endpos = view.origin + ((angles + Angle(offset, offset, 0)):Forward() * -dist),
        filter = function(ent)
            if (table.HasValue({'lps_disguise', 'player'}, ent:GetClass())) then return false end
            return true
        end,
        mins    = Vector(-4, -4, -4),
        maxs    = Vector(4, 4, 4),
    }

    view.origin = util.TraceHull(trData).HitPos

    return view
end

function CLASS:CalcViewModelView(ply, weapon, vm, old_eyepos, old_eyeang, eyepos, eyeang)
    return ply:IsDisguised() and (ply:GetPos() + Vector(0, 0, ply:GetVar('disguiseHull', {hullz = 72}).hullz)) or eyepos, eyeang
end

--[[---------------------------------------------------------
   SERVER
---------------------------------------------------------]]--

function CLASS:Setup(ply)
    self:Cleanup(ply)
end

function CLASS:Cleanup(ply)
    if (not IsValid(ply)) then return end

    if (ply:IsDisguised()) then
        ply:UnDisguise()
    end

    if (ply:IsStuck()) then
        ply:UnStick()
    end

    local trail = ply:GetVar('trail', nil)
    if (IsValid(trail)) then
        SafeRemoveEntity(trail)
        ply:SetVar('trail', nil)
    end
end

function CLASS:PlayerDisconnected(ply)
    self:Cleanup(ply)
end

function CLASS:Loadout(ply)
    timer.Simple(0.1, function ()
        if (not IsValid(ply) and not ply:Alive()) then return end

        local default = ''
        if (GAMEMODE:InPreGame() and GAMEMODE:GetConfig('pregame_deathmatch')) then
            default = GAMEMODE:GiveLoadoutRandom(ply, 'PREGAME')
        end

        if (GAMEMODE:InRound() and ply:IsLastMan()) then
            GAMEMODE:GiveLoadout(ply, TEAM.PROPS)
            default = ply:GetInfo('lps_prop_default')
        end

        timer.Simple(0.4, function ()
            if (not IsValid(ply) or not ply:Alive()) then return end
            if (ply:HasWeapon(default)) then
                ply:SelectWeapon(default)
            end
        end)
    end)
end

function CLASS:Think(ply)
    if (GAMEMODE:GetConfig('prop_jetpack_jump') and ply:KeyDown(IN_JUMP)) then
        ply:SetVelocity(ply:GetUp() * 16)
    end

    local time = CurTime()

    if (not GAMEMODE:InRound()) or
       (not GAMEMODE:GetConfig('prop_autotaunt')) or
       ((GAMEMODE:RoundEndTime() - time) > GAMEMODE:GetConfig('prop_autotaunt_time')) or
       (not ply:IsDisguised()) or
       (ply:GetVar('disguiseVol', 1) > GAMEMODE:GetConfig('prop_autotaunt_size')) or
       (ply:GetVar('tauntCooldown', 0) > time) or
       (ply:GetVar('nextAutoTaunt', 0) > time) then
        return
    end

    if (ply:GetPos():Distance(ply:GetVar('lastAutoTauntPos', ply:GetPos())) < GAMEMODE:GetConfig('prop_autotaunt_rage')) then
        local taunt = true
        if (GAMEMODE:GetConfig('prop_autotaunt_near_hunters')) then
            local hunters = 0
            for _, v in pairs(team.GetPlayers(TEAM.HUNTERS)) do
                if (v:Alive() and ply:GetPos():Distance(v:GetPos()) < GAMEMODE:GetConfig('prop_autotaunt_near_hunters_range')) then
                    taunt = false
                    break
                end
            end
        end

        if (taunt) then
            util.Notify(ply, 'Auto Taunting! Keep moving to avoid auto taunts!')
            ply:RandomTaunt()
        end
    end

    ply:SetVar('lastAutoTauntPos', ply:GetPos())
    ply:SetVar('nextAutoTaunt', time + GAMEMODE:GetConfig('prop_autotaunt_delay'))
end

function CLASS:CanSpawn(ply)
    if (GAMEMODE:InPreRound() and (GAMEMODE:GetConfig('preround_time')/2) > (GAMEMODE:RoundStartTime()-CurTime())) then return false end
    if (GAMEMODE:InRound()) then return false end
    if (GAMEMODE:InPostRound()) then return false end
    if (GAMEMODE:InGame() and not GAMEMODE:InRound() and not GAMEMODE:InPostRound() and not GAMEMODE:InPreRound()) then return false end
    if (GAMEMODE:InPostGame()) then return false end
    return true
end

function CLASS:OnSpawn(ply)
    if (GAMEMODE:InPreRound() and ply:GetInfoNum('lps_klinermode', 0) == 1) then
        ply:Disguise()
    end
end

function CLASS:OnDeath(ply, attacker, dmgInfo)
    self:Cleanup(ply)
    ply:CreateRagdoll()
end

function CLASS:OnSilentDeath(ply)
    self:Cleanup(ply)
end

function CLASS:OnLastMan(ply)
    local disguise = ply:GetDisguise()
    if (IsValid(disguise)) then
        disguise:SetLocked(false)
    end

    ply:StopTaunt()
    hook.Call('PlayerLoadout', GAMEMODE, ply)
    ply:SetVar('trail', util.SpriteTrail(ply, 0, Color(255, 255, 255), false, 15, 1, 1.5, 0.125, 'trails/lastman/rainbow_'..math.Rand(1, 9)..'.vmt'), true)
    ply:RandomTaunt()
end

function CLASS:OnRoundEnd(ply, teamID, num)
    self:Cleanup(ply)

    ply:StripAmmo()
    ply:StripWeapons()

    if (GAMEMODE:GetConfig('postround_deathmatch')) then
        timer.Simple(1, function ()
            if (not IsValid(ply) or not ply:Alive() or not GAMEMODE:InPostRound()) then return end
            GAMEMODE:GiveLoadoutRandom(ply, 'POSTROUND')
        end)
    end
end

function CLASS:PlayerCanPickupWeapon(ply, weapon)
    if (GAMEMODE:InRound() and ply:IsLastMan()) then return true end
    if (GAMEMODE:InPreGame()) then return true end
    if (GAMEMODE:InPostRound()) then return true end
    return false
end

function CLASS:Use(ply, ent)
    if ((ply:GetVar('lastUse', 0) + .5) > CurTime()) then
        return
    else
        ply:SetVar('lastUse', CurTime())
    end

    local canDisguise, reason = ply:CanDisguise(ent)
    if (not canDisguise) then
        if (reason) then  util.Notify(ply, reason) end
        return
    end

    ply:Disguise(ent)

    return false
end

lps.class:Register('prop', CLASS)