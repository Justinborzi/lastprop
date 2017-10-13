local CLASS = {}
CLASS.name                    = 'Default Class'
CLASS.playerModel            = 'models/player.mdl'

CLASS.walkSpeed             = 250   --
CLASS.crouchedWalkSpeed     = 0.4   --
CLASS.runSpeed                = 350   --
CLASS.duckSpeed                = 0.4   --
CLASS.jumpPower                = 200   --
CLASS.gravity                = 0   --

CLASS.maxHealth                = 100   --
CLASS.startHealth            = 100   --
CLASS.startArmor            = 0        --

CLASS.drawViewModel            = true  --
CLASS.canUseFlashlight      = true  --
CLASS.dropWeaponOnDie        = false    --
CLASS.teammateNoCollide     = true    --
CLASS.avoidPlayers            = true     -- Automatically avoid players that we're no colliding
CLASS.fullRotation            = false -- Allow the player's model to rotate upwards, etc etc

--[[---------------------------------------------------------
                        CLIENT HOOKS
---------------------------------------------------------]]--

--[[---------------------------------------------------------
--   Name: CLASS:RegisterBindings()
---------------------------------------------------------]]--
function CLASS:RegisterBindings()

end

--[[---------------------------------------------------------
--   Name: CLASS:PreDrawHalos()
---------------------------------------------------------]]--
function CLASS:PreDrawHalos(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:HUDDrawTargetID()
---------------------------------------------------------]]--
function CLASS:HUDDrawTargetID(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:HUDShouldDraw()
---------------------------------------------------------]]--
function CLASS:HUDShouldDraw(ply, name)

end

--[[---------------------------------------------------------
--   Name: CLASS:HUDPaint()
---------------------------------------------------------]]--
function CLASS:HUDPaint(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnKeyDown()
---------------------------------------------------------]]--
function CLASS:OnKeyDown(ply, key, keycode, char, keytype, busy, cursor)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnKeyUp()
---------------------------------------------------------]]--
function CLASS:OnKeyUp(ply, key, keycode, char, keytype, busy, cursor)

end

--[[---------------------------------------------------------
--   Name: CLASS:InputMouseApply()
---------------------------------------------------------]]--
function CLASS:InputMouseApply(ply, cmd, x, y, angle)

end

--[[---------------------------------------------------------
--   Name: CLASS:CreateMove()
---------------------------------------------------------]]--
function CLASS:CreateMove(ply, cmd)

end

--[[---------------------------------------------------------
--   Name: CLASS:ShouldDrawLocalPlayer()
---------------------------------------------------------]]--
function CLASS:ShouldDrawLocalPlayer(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:CalcView()
---------------------------------------------------------]]--
function CLASS:CalcView(ply, origin, angles, fov)

end

--[[---------------------------------------------------------
--   Name: CLASS:CalcViewModelView()
---------------------------------------------------------]]--
function CLASS:CalcViewModelView(ply, weapon, vm, oldEyePos, oldEyeAng, eyePos, eyeAng)

end

--[[---------------------------------------------------------
                         SERVER HOOKS
---------------------------------------------------------]]--

--[[---------------------------------------------------------
--   Name: CLASS:Setup()
---------------------------------------------------------]]--
function CLASS:Setup(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:Cleanup()
---------------------------------------------------------]]--
function CLASS:Cleanup(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:PlayerDisconnected()
---------------------------------------------------------]]--
function CLASS:PlayerDisconnected(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:PlayerReconnected()
---------------------------------------------------------]]--
function CLASS:PlayerReconnected(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:Loadout()
---------------------------------------------------------]]--
function CLASS:Loadout(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:Think()
---------------------------------------------------------]]--
function CLASS:Think(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:CanSpawn()
---------------------------------------------------------]]--
function CLASS:CanSpawn(ply)
    return true
end

--[[---------------------------------------------------------
--   Name: CLASS:OnSpawn()
---------------------------------------------------------]]--
function CLASS:OnSpawn(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:GetHandsModel()
---------------------------------------------------------]]--
function CLASS:GetHandsModel(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnKill()
---------------------------------------------------------]]--
function CLASS:OnKill(ply, victim, inflictor)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnDeath()
---------------------------------------------------------]]--
function CLASS:OnDeath(ply, attacker, dmgInfo)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnSilentDeath()
---------------------------------------------------------]]--
function CLASS:OnSilentDeath(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnPostDeath()
---------------------------------------------------------]]--
function CLASS:OnPostDeath(ply, attacker, dmgInfo)

end

--[[---------------------------------------------------------
--   Name: CLASS:DeathThink()
---------------------------------------------------------]]--
function CLASS:DeathThink(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnPreRoundStart()
---------------------------------------------------------]]--
function CLASS:OnPreRoundStart(ply, num)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnPreRoundStart()
---------------------------------------------------------]]--
function CLASS:OnPreRoundStart(ply, num)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnRoundStart()
---------------------------------------------------------]]--
function CLASS:OnRoundStart(ply, num)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnLastMan()
---------------------------------------------------------]]--
function CLASS:OnLastMan(ply)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnRoundLastMan()
---------------------------------------------------------]]--
function CLASS:OnRoundLastMan(ply, LastMan)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnRoundEnd()
---------------------------------------------------------]]--
function CLASS:OnRoundEnd(ply, teamID, num)

end

--[[---------------------------------------------------------
--   Name: CLASS:PlayerCanPickupWeapon()
---------------------------------------------------------]]--
function CLASS:PlayerCanPickupWeapon(ply, weapon)

end

--[[---------------------------------------------------------
--   Name: CLASS:AllowPlayerPickup()
---------------------------------------------------------]]--
function CLASS:AllowPlayerPickup(ply, ent)

end

--[[---------------------------------------------------------
--   Name: CLASS:Use()
---------------------------------------------------------]]--
function CLASS:Use(ply, ent)

end

--[[---------------------------------------------------------
--   Name: CLASS:CanHear()
---------------------------------------------------------]]--
function CLASS:CanHear(ply, speaker)

end

--[[---------------------------------------------------------
--   Name: CLASS:CanSpeak()
---------------------------------------------------------]]--
function CLASS:CanSpeak(ply, listener)

end

--[[---------------------------------------------------------
--   Name: CLASS:CanSeeChat()
---------------------------------------------------------]]--
function CLASS:CanSeeChat(ply, speaker)

end

--[[---------------------------------------------------------
--   Name: CLASS:CanChat()
---------------------------------------------------------]]--
function CLASS:CanChat(ply, listener)

end

--[[---------------------------------------------------------
--   Name: CLASS:ShouldTakeDamage()
---------------------------------------------------------]]--
function CLASS:ShouldTakeDamage(ply, attacker)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnCausedDamage()
---------------------------------------------------------]]--
function CLASS:OnCausedDamage(ply, ent, dmgInfo)

end

--[[---------------------------------------------------------
                        SHARED HOOKS
---------------------------------------------------------]]--

--[[---------------------------------------------------------
--   Name: CLASS:Move()
---------------------------------------------------------]]--
function CLASS:Move(ply, mv)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnKeyPress()
---------------------------------------------------------]]--
function CLASS:OnKeyPress(ply, key)

end

--[[---------------------------------------------------------
--   Name: CLASS:OnKeyRelease()
---------------------------------------------------------]]--
function CLASS:OnKeyRelease(ply, key)

end

--[[---------------------------------------------------------
--   Name: CLASS:PlayerFootstep()
---------------------------------------------------------]]--
function CLASS:PlayerFootstep(ply, pos, foot, sound, volume, rf)

end

lps.class:Register('default', CLASS)

local CLASS = {}
CLASS.name            = 'Spectator Class'
CLASS.playerModel    = 'models/player.mdl'

lps.class:Register('spectator', CLASS)