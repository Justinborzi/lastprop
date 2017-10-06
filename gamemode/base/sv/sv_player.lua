
--[[---------------------------------------------------------
--   Name: GM:PlayerDisconnected()
---------------------------------------------------------]]--
function GM:PlayerDisconnected(ply)
    ply:SetVar('disconnected', true)
    ply:ClassCall('PlayerDisconnected')
    self.BaseClass:PlayerDisconnected(ply)

    if (player.GetCount() == 1) then
        self:Pause()
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerReconnected()
---------------------------------------------------------]]--
function GM:PlayerReconnected(ply)
    ply:ClassCall('PlayerReconnected')
end

--[[---------------------------------------------------------
--   Name: GM:PlayerInitialSpawn()
---------------------------------------------------------]]--
function GM:PlayerInitialSpawn(ply)
    if (player.GetCount() == 1) then
        self:Resume()
    end

    self:PlayerSetTeam(ply, ply:IsBot() and team.BestAutoJoinTeam() or ply:GetVar('team', TEAM.UNASSIGNED))

    if (not ply:IsBot()) then
        lps.net.Start(ply, 'Initialize', {lps.banned, lps.support, lps.version})
        if ply:GetVar('disconnected', false) then
            hook.Call('PlayerReconnected', self, ply)
            ply:SetVar('disconnected', false)
        end
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerSpawn()
---------------------------------------------------------]]--
function GM:PlayerSpawn(ply)

    if (ply:ClassCall('CanSpawn') == false) then
        ply:KillSilent()
        self:BecomeObserver(ply)
        return
    elseif (ply:IsSpec()) then
        self:PlayerSpawnAsSpectator(ply)
        return
    end

    ply:UnSpectate()

    local class = ply:Class()
    if (not class) then
        lps.Warning('Can\'t find class for team %s!', team.GetName(ply:Team()))
        return
    end

    hook.Call( "PlayerSetModel", GAMEMODE, ply )

    ply:SetupHands()

    ply:ClassCall('Loadout')

    if (class.duckSpeed) then ply:SetDuckSpeed(class.duckSpeed) end
    if (class.walkSpeed) then ply:SetWalkSpeed(class.walkSpeed) end
    if (class.runSpeed) then ply:SetRunSpeed(class.runSpeed) end
    if (class.gravity) then ply:SetGravity(class.gravity) end
    if (class.crouchedWalkSpeed) then ply:SetCrouchedWalkSpeed(class.crouchedWalkSpeed) end
    if (class.jumpPower) then ply:SetJumpPower(class.jumpPower) end
    if (class.drawViewModel == false) then ply:DrawViewModel(false) else ply:DrawViewModel(true) end
    if (class.canUseFlashlight ~= nil) then ply:SetVar('allowFlashlight', class.canUseFlashlight, true) end
    if (class.startHealth) then ply:SetHealth(class.startHealth) end
    if (class.maxHealth) then ply:SetMaxHealth(class.maxHealth) end
    if (class.startArmor) then ply:SetArmor(class.startArmor) end
    if (class.respawnTime) then ply:SetRespawnTime(class.respawnTime) end
    if (class.dropWeaponOnDie ~= nil) then ply:ShouldDropWeapon(class.dropWeaponOnDie) end
    if (class.teammateNoCollide ~= nil) then ply:SetNoCollideWithTeammates(class.teammateNoCollide) end
    if (class.avoidPlayers ~= nil) then ply:SetAvoidPlayers(class.avoidPlayers) end
    if (class.fullRotation ~= nil) then ply:SetAllowFullRotation(class.fullRotation) end

    ply:ClassCall('OnSpawn')

end

--[[---------------------------------------------------------
	Name: gamemode:PlayerSetModel( )
	Desc: Set the player's model
-----------------------------------------------------------]]
function GM:PlayerSetModel( ply )
        local models = {
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
    }

    local class = ply:Class()
    if (class and class.playerModel) then
        if (type(class.playerModel) == 'table') then
            models = class.playerModel
        else
            models = {class.playerModel}
        end
    end

    local mdl = player_manager.TranslatePlayerModel(table.Random(models))
    util.PrecacheModel(mdl)
    ply:SetModel(mdl)
end

--[[---------------------------------------------------------
    Name: gamemode:PlayerSetHandsModel( )
    Desc: Sets the player's view model hands model
-----------------------------------------------------------]]
function GM:PlayerSetHandsModel( ply, ent )
    local info = ply:ClassCall('GetHandsModel')
    if (not info) then
        info = player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(ply:GetModel()))
    end
    if (info) then
        ent:SetModel( info.model )
        ent:SetSkin( info.skin )
        ent:SetBodyGroups( info.body )
    end
end

--[[---------------------------------------------------------
--   Name: GM:DoPlayerDeath()
---------------------------------------------------------]]--
function GM:DoPlayerDeath(ply, attacker, dmgInfo)
    ply:SetVar('deathTime', CurTime())
    ply:SetVar('killer', attacker)

    ply:ClassCall('OnDeath', attacker, dmgInfo)

    ply:StripAmmo()
    ply:StripWeapons()

    if (self:InRound()) then
        ply:AddDeaths(1)
        if (attacker:IsValid() and attacker:IsPlayer()) then
            if (attacker == ply) then
                attacker:AddFrags(-1)
            else
                attacker:AddFrags(1)
            end
        end
    end

end

--[[---------------------------------------------------------
--   Name: GM:PlayerDeath()
---------------------------------------------------------]]--
function GM:PlayerDeath(ply, inflictor, attacker)
    if (IsValid(attacker) && attacker:GetClass() == 'trigger_hurt') then attacker = ply end

    if (IsValid(attacker) && attacker:IsVehicle() && IsValid(attacker:GetDriver())) then
        attacker = attacker:GetDriver()
    end

    if (!IsValid(inflictor) && IsValid(attacker)) then
        inflictor = attacker
    end

    if (IsValid(inflictor) && inflictor == attacker && (inflictor:IsPlayer() || inflictor:IsNPC())) then
        inflictor = inflictor:GetActiveWeapon()
        if (!IsValid(inflictor)) then inflictor = attacker end
    end

    lps.net.Start(nil, 'PlayerDeath', {ply, inflictor, attacker})

    if (IsValid(attacker) and attacker:IsPlayer()) then
        attacker:ClassCall('OnKill', ply, inflictor)
    end

    if (attacker == ply) then
        lps.Log('%s suicided!', attacker:Nick())
        return
    end

    if (attacker:IsPlayer()) then
        lps.Log('%s killed %s using %s', attacker:Nick(), ply:Nick(), inflictor:GetClass())
        return
    end

    lps.Log('%s was killed by %s', ply:Nick(), attacker:GetClass())
end

--[[---------------------------------------------------------
--   Name: GM:PlayerSilentDeath()
---------------------------------------------------------]]--
function GM:PlayerSilentDeath(ply)
    ply:ClassCall('OnSilentDeath')
end

--[[---------------------------------------------------------
--   Name: GM:PlayerDeathSound()
---------------------------------------------------------]]--
function GM:PlayerDeathSound()
    return false
end

--[[---------------------------------------------------------
--   Name: GM:PostPlayerDeath()
---------------------------------------------------------]]--
function GM:PostPlayerDeath(ply)
    ply:ClassCall('OnPostDeath')
    local killer = ply:GetVar('killer', nil)
    if (self:GetConfig('death_freezecam') and IsValid(killer) and killer:IsPlayer() and killer ~= ply) then
        ply:SpectateEntity(killer)
        ply:Spectate(OBS_MODE_FREEZECAM)
    elseif (ply:GetObserverMode() == OBS_MODE_NONE) then
        ply:Spectate(OBS_MODE_DEATHCAM)
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerDeathThink()
---------------------------------------------------------]]--
function GM:PlayerDeathThink(ply)
    ply:ClassCall('DeathThink')
    local timeDead = CurTime() - ply:GetVar('deathTime', CurTime())
    if (timeDead > self:GetConfig('death_linger_time') and (table.HasValue({OBS_MODE_FREEZECAM, OBS_MODE_DEATHCAM}, ply:GetObserverMode()))) then
        self:BecomeObserver(ply)
    end

    if (ply:ClassCall('CanSpawn') and (ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP))) then
        ply:Spawn()
    end
end

--[[---------------------------------------------------------
--   Name: GM:CanPlayerSuicide()
---------------------------------------------------------]]--
function GM:CanPlayerSuicide(ply)
    if (ply:IsSpec()) then
        return false
    end
    return true
end

--[[---------------------------------------------------------
--   Name: GM:PlayerSwitchFlashlight()
---------------------------------------------------------]]--
function GM:PlayerSwitchFlashlight(ply, on)
    if (ply:IsSpec()) then
        return not on
    end
    return ply:GetVar('allowFlashlight', false)
end

--[[---------------------------------------------------------
--   Name: GM:PlayerUse()
---------------------------------------------------------]]--
function GM:PlayerUse(ply, ent)
    -- Prevent dead or spectating players from being able to use stuff.
    if (not ply:Alive() or ply:IsSpec()) then
        return false
    elseif (table.HasValue({'func_door', 'prop_door_rotating', 'func_door_rotating'}, ent:GetClass())) then
        if ((ply:GetVar('lastDoor', 0) + .75) >= CurTime()) then
            return false
        else
            ply:SetVar('lastDoor', CurTime())
            return true
        end
    elseif (ent:IsPlayerHolding()) then
        return false
    end

    local use = ply:ClassCall('Use', ent)
    if(use ~= nil) then
        return use
    end

    return true
end

--[[---------------------------------------------------------
--   Name: GM:GetFallDamage()
---------------------------------------------------------]]--
function GM:GetFallDamage(ply, fallSpeed)
    if (not self:GetConfig('falldamage')) then
        return 0
    elseif (self:GetConfig('falldamage_realistic')) then
        return fallSpeed / 8
    else
        return 10
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerShouldTakeDamage()
---------------------------------------------------------]]--
function GM:PlayerShouldTakeDamage(ply, attacker)
    local shouldTakeDamage = ply:ClassCall('ShouldTakeDamage', attacker)
    if(shouldTakeDamage ~= nil) then
        return shouldTakeDamage
    end
    return true
end

--[[---------------------------------------------------------
--   Name: GM:PlayerCanPickupWeapon()
---------------------------------------------------------]]--
function GM:PlayerCanPickupWeapon(ply, weapon)
    if (ply:IsSpec()) then
        return false
    end

    local canPickupWeapon = ply:ClassCall('PlayerCanPickupWeapon', weapon)
    if(canPickupWeapon ~= nil) then
        return canPickupWeapon
    end
    return true
end

--[[---------------------------------------------------------
--   Name: GM:AllowPlayerPickup()
---------------------------------------------------------]]--
function GM:AllowPlayerPickup(ply, ent)
    if (ply:IsSpec()) then
        return false
    end

    local allowPickup = ply:ClassCall('AllowPlayerPickup', ent)
    if(allowPickup ~= nil) then
        return allowPickup
    end
    return true
end

--[[---------------------------------------------------------
--   Name: GM:MutePlayer()
---------------------------------------------------------]]--
function GM:MutePlayer(listener, speaker, mute)
    if (IsValid(speaker) and IsValid(listener)) and (speaker:IsPlayer() and listener:IsPlayer()) then
        local muted = listener:GetVar('muted', {})
        if (mute == nil) then
            if (muted[speaker:UniqueID()] ~= nil) then
                muted[speaker:UniqueID()] = not muted[speaker:UniqueID()]
            else
                muted[speaker:UniqueID()] = true
            end
        else
            muted[speaker:UniqueID()] = mute
        end
        listener:SetVar('muted', muted, true)
    end
end

--[[---------------------------------------------------------
--   Name: GM:PlayerCanHearPlayersVoice()
---------------------------------------------------------]]--
function GM:PlayerCanHearPlayersVoice(listener, speaker)

    -- Generic Checks
    if (not IsValid(speaker) or not IsValid(listener)) then return end

    -- Team Chat
    if (speaker:GetVar('teamChat', false) and speaker:Team() ~= listener:Team()) then return false end

    -- Admins
    if (speaker:IsAdmin() or speaker:IsSuperAdmin()) then return true end

    -- Muted players
    if (listener:GetVar('muted', {})[speaker:UniqueID()]) then
        return false
    end

    -- Let people talk if not in round
    if (not self:InRound()) then return true end

    -- Spectators can't talk to players
    if (speaker:IsSpec() and not listener:IsSpec()) then
        return false
    end

    -- Dead people can't talk
    if (not speaker:Alive() and listener:Alive()) then return false end

    --Team Chat
    if (speaker:GetVar('teamChat', false) and speaker:Team() ~= listener:Team()) then return false end

    -- Class hooks
    local canHear, canTalk = listener:ClassCall('CanHear', speaker), speaker:ClassCall('CanSpeak', listener)
    if (canHear == false) or (canSpeak == false) then
        return false
    end

    return true, (speaker:GetVar('localChat', false))
end

--[[---------------------------------------------------------
--   Name: GM:PlayerCanSeePlayersChat()
---------------------------------------------------------]]--
function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, speaker )

    -- Generic Checks
    if (not IsValid(speaker) or not IsValid(listener)) then return end

    --Team Chat
    if (teamOnly and listener:Team() ~= speaker:Team()) then return false end

    -- Admins
    if (speaker:IsAdmin() or speaker:IsSuperAdmin()) then return true end

    -- Muted players
    if (listener:GetVar('muted', {})[speaker:UniqueID()]) then return false end

    -- Let people talk if not in round
    if (not self:InRound()) then return true end

    -- Spectators can't talk to players
    if (speaker:IsSpec() and not listener:IsSpec()) then
        return false
    end

    -- Dead people can't talk
    if (not speaker:Alive() and listener:Alive()) then return false end

    -- Class hooks
    local canSeeChat, canChat = listener:ClassCall('CanSeeChat', speaker), speaker:ClassCall('CanChat', listener)
    if (canSeeChat == false) or (canChat == false) then
        return false
    end

    return true
end

--[[---------------------------------------------------------
--   Name: GM:PlayerSay()
---------------------------------------------------------]]--
function GM:PlayerSay(ply, text, teamChat)
    if table.HasValue({'stuck', '!stuck', '/stuck', 'unstuck', '!unstuck', '/unstuck', 'unstick', '!unstick', '/unstick'}, string.lower(text)) then
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
        return ''
    end
    if table.HasValue({'settings', '!settings', '/settings', 'options', '!options', '/options'}, string.lower(text)) then
        ply:ConCommand('lps_show_options')
        return ''
    end
    if table.HasValue({'bindings', '!bindings', '/bindings'}, string.lower(text)) then
        ply:ConCommand('lps_show_bindings')
        return ''
    end
    return text
end

--[[---------------------------------------------------------
--   Name: GM:PlayerDisguise()
---------------------------------------------------------]]--
function GM:PlayerDisguise(ply, ent)

end

--[[---------------------------------------------------------
--   Name:  GM:PlayerUnDisguise()
---------------------------------------------------------]]--
function GM:PlayerUnDisguise(ply)

end

--[[---------------------------------------------------------
--   Name: GM:PlayerTaunt()
---------------------------------------------------------]]--
function GM:PlayerTaunt(taunt, min, max)

end