local CLASS = {}
CLASS.name = 'Hunter'
CLASS.description = 'As a Hunter you will be blindfolded for the first part of the round, while the Props hide. When your blindfold is taken off, you will need to find props controlled by players and kill them. Damaging non-player props will lower your health significantly. However, killing a Prop will increase your health by points.'

CLASS.playerModel = {
    'combine',
    'combineprison',
    'combineelite',
    'police'
}

CLASS.suicideString = {
    'suicided!',
    'died mysteriously!',
    'no-scoped themself!',
    'rage quit!',
    'died...',
    'slapped themself!',
    'tripped on a bottle!',
    'died by the force!',
    'died of guilt, poor props...'
}

CLASS.killString = {
    'murdered',
    'killed',
    'destroyed',
    'RIPed',
    'redrumed',
    'pooped on',
}

CLASS.walkSpeed             = 280   --
CLASS.crouchedWalkSpeed     = 0.4   --
CLASS.runSpeed              = 300   --
CLASS.duckSpeed             = 0.4   --
CLASS.jumpPower             = 280   --
CLASS.gravity               = 1     --

CLASS.maxHealth             = 100   --
CLASS.startHealth           = 100   --
CLASS.startArmor            = 0     --

CLASS.drawViewModel         = true  --
CLASS.canUseFlashlight      = true  --
CLASS.dropWeaponOnDie       = false --
CLASS.teammateNoCollide     = true  --
CLASS.avoidPlayers          = true  -- Automatically avoid players that we're no colliding
CLASS.fullRotation          = false -- Allow the player's model to rotate upwards, etc etc

--[[---------------------------------------------------------
   CLIENT
---------------------------------------------------------]]--

function CLASS:RegisterBindings()
    lps.bindings:Register('hunter', 'taunt', KEY_T, INPUT.KEY, 'Taunt', 'Hunter Taunt.')
end

function CLASS:PreDrawHalos(ply)
    if (ply:GetVar('blinded', false)) then return end
    local tr = ply:GetEyeTrace()
    if (not IsValid(tr.Entity)) then return end
    if (tr.HitPos:Distance(tr.StartPos) < 150) then
        if (tr.Entity:IsPlayer() and (tr.Entity:Team() == TEAM.PROPS) and tr.Entity:IsDisguised()) then
            local disguise = tr.Entity:GetDisguise()
            if (IsValid(disguise)) then
                halo.Add({disguise}, util.Rainbow(0.3), 2, 2, 2, true, true)
            end
        elseif(tr.Entity:IsValidDisguise() or tr.Entity:GetClass() == 'lps_disguise') then
            halo.Add({tr.Entity}, util.Rainbow(0.3), 2, 2, 2, true, true)
        end
    end
end

function CLASS:HUDDrawTargetID(ply)
    if (ply:GetVar('blinded', false)) then return end
    local tr = ply:GetEyeTrace()
    if (not IsValid(tr.Entity)) then return end
    if (tr.Entity:IsPlayer()) and ((tr.Entity:Team() == TEAM.HUNTERS) or (tr.Entity:Team() == TEAM.PROPS and not tr.Entity:IsDisguised())) then
        surface.SetFont('LPS30')
        local text = tr.Entity :Nick()
        local w, h = surface.GetTextSize(text)
        local x, y = (ScrW()/2) - (w/2),  (ScrH()/2) + 30
        draw.SimpleText(text, 'LPS30', x + 1, y + 1, Color(0, 0, 0, 120))
        draw.SimpleText(text, 'LPS30', x + 2, y + 2, Color(0, 0, 0, 50))
        draw.SimpleText(text, 'LPS30', x, y, team.GetColor(tr.Entity :Team()))
    end
end

function CLASS:HUDShouldDraw(ply, name)
    if (name == 'CHudWeaponSelection' and not IsValid(ply:GetActiveWeapon())) then return false end
end

function CLASS:OnKeyDown(ply, key, keycode, char, keytype, busy, cursor)
    if (busy or cursor or not ply:Alive()) then return end

    local taunt = lps.bindings:GetKey('hunter', 'taunt')
    if (key == taunt.key and keytype == taunt.type) then
        if (ply:GetVar('canTaunt', false)) then
            RunConsoleCommand('randomtaunt')
        else
            util.Notify(ply, 'You can\'t taunt right now!')
        end
    end
end

function CLASS:ShouldDrawLocalPlayer(ply)
    return GetConVar('lps_tpvh'):GetBool()
end

function CLASS:CalcView(ply, origin, angles, fov)
    if (not IsValid(ply) or ply:IsObserver()) then return end

    local view = {}

    if (ply:GetVar('blinded', false) and ply:IsFrozen()) then
        view.origin = Vector(20000, 0, 0)
        view.angles = Angle(0, 0, 0)
        view.fov    = fov
        return view
    end

    if (GetConVar('lps_tpvh'):GetBool()) then
        view.angles = angles
        view.origin = origin
        view.fov    = fov

        local dist = math.Clamp(GetConVar('lps_tpv_dist'):GetInt(), 80, 150)
        local offset = GetConVar('lps_tpv_offset_on'):GetBool() and math.Clamp(GetConVar('lps_tpv_offset'):GetInt(), 0, 15) or 0
        local trData = {
            start   = origin,
            endpos  = origin + ((angles + Angle(offset, offset, 0)):Forward() * -dist),
            filter  = player.GetAll(),
            mins    = Vector(-4, -4, -4),
            maxs    = Vector(4, 4, 4)
        }

        view.origin = util.TraceHull(trData).HitPos

        return view
    end
end

--[[---------------------------------------------------------
   SERVER
---------------------------------------------------------]]--
function CLASS:Setup(ply)
    self:Cleanup(ply)
end

function CLASS:Cleanup(ply)

    if (not IsValid(ply)) then return end

    if (ply:GetVar('blinded', false)) then
        ply:SetVar('blinded', false, true)
    end

    if (ply:GetVar('canTaunt', false)) then
        ply:SetVar('canTaunt', false, true)
    end

    if (ply:IsFrozen()) then
        ply:Freeze(false)
    end
end

function CLASS:PlayerDisconnected(ply)
    self:Cleanup(ply)
end

function CLASS:Loadout(ply)
    timer.Simple(0.1, function ()
        if (not IsValid(ply) and not ply:Alive()) then return end
        if (GAMEMODE:InPreGame() and GAMEMODE:GetConfig('pregame_deathmatch')) then
            GAMEMODE:GiveLoadoutRandom(ply, 'PREGAME')
        elseif (GAMEMODE:InRound()) then
            GAMEMODE:GiveLoadout(ply, TEAM.HUNTERS)
            local defult = ply:GetInfo('lps_hunter_default')
            if ply:HasWeapon(defult) then
                ply:SelectWeapon(defult)
            elseif ply:HasWeapon('weapon_smg1') then
                ply:SelectWeapon('weapon_smg1')
            end
        end
    end)
end

function CLASS:Think(ply)
    if (GAMEMODE:GetConfig('hunter_jetpack_jump') and ply:KeyDown(IN_JUMP)) then
        ply:SetVelocity(ply:GetUp() * 16)
    end
end

function CLASS:CanSpawn(ply)
    if (GAMEMODE:InPreRound() and (GAMEMODE:GetConfig('preround_time')-(GAMEMODE:GetConfig('preround_time')/4)) > (GAMEMODE:RoundStartTime()-CurTime())) then return false end
    if (GAMEMODE:InRound()) then return false end
    if (GAMEMODE:InPostRound()) then return false end
    if (GAMEMODE:InGame() and not GAMEMODE:InRound() and not GAMEMODE:InPostRound() and not GAMEMODE:InPreRound()) then return false end
    if (GAMEMODE:InPostGame()) then return false end
    return true
end

function CLASS:OnSpawn(ply)
    if (GAMEMODE:InPreRound()) then
        if (not ply:GetVar('blinded', false)) then
            ply:SetVar('blinded', true, true)
        end

        if (not ply:IsFrozen()) then
            ply:Freeze(true)
        end
    end
end

function CLASS:OnKill(ply, victim, inflictor)
    if (not ply:Alive() or not GAMEMODE:InRound()) then return end
    if (GAMEMODE:GetConfig('hunter_kill_bonus_health') > 0 and not GAMEMODE:GetConfig('hunter_steal_health')) then
        ply:SetHealth(math.Clamp(ply:Health() + GAMEMODE:GetConfig('hunter_kill_bonus_health'), 10, ply:GetMaxHealth()))
    end
    if (victim:IsPlayer() and victim:Team() == TEAM.PROPS and GAMEMODE:GetConfig('hunter_kill_bonus_nade') > 0) then
        ply:GiveAmmo(GAMEMODE:GetConfig('hunter_kill_bonus_nade'), 'SMG1_Grenade', true)
        util.Notify(ply, string.format('You caught %s, you get a free SMG Grenade!', victim:Nick()))
    end
end

function CLASS:OnDeath(ply, attacker, dmgInfo)
    self:Cleanup(ply)
    ply:CreateRagdoll()
end

function CLASS:OnSilentDeath(ply)
    self:Cleanup(ply)
end

function CLASS:OnPreRoundStart(ply, num)
    if (not ply:GetVar('blinded', false)) then
        ply:SetVar('blinded', true, true)
        ply:Freeze(true)
    end
end

function CLASS:OnRoundStart(ply, num)
    if (not ply:GetVar('canTaunt', false)) then
        ply:SetVar('canTaunt', true, true)
    end

    if (ply:GetVar('blinded', false)) then
        ply:SetVar('blinded', false, true)
    end

    if (ply:IsFrozen()) then
        ply:Freeze(false)
    end
end

function CLASS:OnLastMan(ply)
    if (GAMEMODE:GetConfig('hunter_lastman_bonus_nade') and ply:GetAmmoCount('SMG1_Grenade') < 1) then
        ply:GiveAmmo(1, 'SMG1_Grenade', true)
        util.Notify(ply, 'You\'re the last man standing! You get a free SMG Grenade!')
    end
end

function CLASS:OnRoundEnd(ply, teamID, num)
    self:Cleanup(ply)
    if (ply:Alive()) then
        ply:StripWeapons()
        ply:StripAmmo()
    end

    if (GAMEMODE:GetConfig('postround_deathmatch')) then
        timer.Simple(2, function ()
            if (IsValid(ply) and ply:Alive()) then
                GAMEMODE:GiveLoadoutRandom(ply, 'POSTROUND')
            end
        end)
    end
end

function CLASS:PlayerCanPickupWeapon(ply, weapon)
    if (GAMEMODE:InPreGame() and GAMEMODE:GetConfig('pregame_deathmatch')) then return true end
    if (GAMEMODE:InPostRound() and GAMEMODE:GetConfig('postround_deathmatch')) then return true end
    return GAMEMODE:InRound()
end

function CLASS:ShouldTakeDamage(ply, attacker)
    if (IsValid(attacker) and attacker:IsPlayer() and ply ~= attacker and attacker:Team() == TEAM.HUNTERS and not GAMEMODE:GetConfig('hunter_friendlyfire') and GAMEMODE:InRound()) then return false end
end

function CLASS:OnCausedDamage(ply, ent, dmgInfo)
    if (not IsValid(ent) or (ent == ply) or not GAMEMODE:InRound()) then return end

    if (GAMEMODE:GetConfig('hunter_steal_health') and ((ent:GetClass() == 'lps_disguise') or (ent:IsPlayer() and ent:Team() == TEAM.PROPS))) then
        local damage = math.Round(dmgInfo:GetDamage()/2)
        local health = math.Clamp(ply:Health() + damage, ply:Health(), GAMEMODE:GetConfig('hunter_steal_maxhealth'))
        if (health > ply:GetMaxHealth()) then
            ply:SetMaxHealth(health)
        end
        ply:SetHealth(health)
    end

    if (GAMEMODE:GetConfig('hunter_crowbar_nopenalty')) then
        local swep = ply:GetActiveWeapon()
        if ( IsValid(swep) and swep:GetClass() == 'weapon_crowbar') then return end
    end

    if (GAMEMODE:GetConfig('hunter_damage_penalty') > 0 and table.HasValue({'prop_physics', 'prop_physics_multiplayer'}, ent:GetClass())) then
        local dmgInfo = DamageInfo()
        dmgInfo:SetAttacker(ply)
        dmgInfo:SetDamage(GAMEMODE:GetConfig('hunter_damage_penalty'))
        dmgInfo:SetDamageType(DMG_GENERIC)
        ply:TakeDamageInfo(dmgInfo)
    end
end

lps.class:Register('hunter', CLASS)