local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    local localPlayer = LocalPlayer()

    self:ParentToHUD()
    self:SetSize(350, 120)

    self.armor = 0
    self.heath = 0

    self.model = vgui.Create('DModelPanel', self)
    self.model:SetPos(18, 18)
    self.model:SetSize(80, 80)
    self.model:SetFOV(90)
    self.model:SetVisible(true)
    self.model:SetAnimated(false)
    self.model:SetAnimSpeed(false)
    self.model.LayoutEntity = function(self, ent) return end
    self.model.PaintModel = self.model.Paint
    self.model.Paint = function(self, w, h)
        local localPlayer = localPlayer or LocalPlayer()
        if (not IsValid(localPlayer)) then return end
        util.StencilStart()
        util.DrawSimpleCircle(w/2, w/2, w/2, team.GetColor(localPlayer:Team()))
        util.StencilReplace()
        self:PaintModel(w, h)
        util.DrawCircleGradient(w/2, w/2, w/2, 1)
        util.StencilEnd()
    end
    self.model.Think = function(self)
        local localPlayer = localPlayer or LocalPlayer()
        if (not IsValid(localPlayer)) then return end
        if (localPlayer:IsDisguised()) then
            local disguise = localPlayer:GetDisguise()
            if (IsValid(disguise)) then
                local model = disguise:GetModel()
                if self:GetModel() ~= model then
                    local hull = localPlayer:GetVar('disguiseHull', {hullxy_max = 16, hullxy_min = 16, hullz = 72, duck = (72 / 2)})
                    self:SetModel(model)
                    self.Entity:SetPos(Vector(0,0,0))
                    self:SetLookAt(Vector(0, 0, 0))
                    self:SetCamPos(Vector(hull.hullz + hull.hullxy_max, 0, hull.hull))
                end
            end
        elseif self:GetModel() ~= localPlayer:GetModel() then
            self:SetModel(localPlayer:GetModel())
            local bone = self.Entity:LookupBone('ValveBiped.Bip01_Head1')
            if bone then
                local headPos = self.Entity:GetBonePosition(bone)
                self:SetLookAt(headPos)
                self:SetCamPos(headPos - Vector(-15, 0, 0))
                self.Entity:SetEyeTarget(headPos - Vector(-12, 0, 0))
            end
        end
    end

    self.panel = vgui.Create('Panel', self)
    self.panel:Dock(RIGHT)
    self.panel:SetWide(self:GetWide() - (self:GetWide()/3))
    self.panel:DockPadding(15, 20, 15, 10)

    self.header = vgui.Create('Panel', self.panel)
    self.header:Dock(TOP)

    self.info = vgui.Create('Panel', self.panel)
    self.info:Dock(FILL)
    self.info.Paint = function(self, w, h)
        local localPlayer = localPlayer or LocalPlayer()
        if (not IsValid(localPlayer)) then return end

        local swep = localPlayer:GetActiveWeapon()
        if (IsValid(swep)) then
            local clip = swep:Clip1()
            local clipMax = swep:GetMaxClip1()
            local ammo
            if (swep:GetPrimaryAmmoType() ~= -1) then
                ammo = localPlayer:GetAmmoCount(swep:GetPrimaryAmmoType())
            else
                ammo = clipMax > 0 and clipMax or 0
            end

            surface.SetFont('LPS80')

            local t1, t2 = string.format('%02d', clip), string.format(' / %02d', ammo or clipMax)
            local tw, th = surface.GetTextSize(t1)
            draw.SimpleText(t1, 'LPS80', tw, -5, Color(0,0,0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText(t2, 'LPS30', tw, 7, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            local p = 10
            draw.RoundedBox(4, tw + p, th-32, (w-tw)-p, 8, Color(190, 190, 190))

            if (ammo > 0) then
                local width = (((w-tw)-p)*(clip/clipMax))
                draw.RoundedBox(4, tw + p, th-32, width, 8, team.GetColor(localPlayer:Team()))
            end
        elseif (localPlayer:IsDisguised()) then
            local disguise = localPlayer:GetDisguise()
            surface.SetFont('LPS40')
            local t1 = disguise:GetLocked() and 'Locked' or 'Unlocked'
            local tw, th = surface.GetTextSize(t1)
            draw.SimpleText(t1, 'LPS40', tw, 15, Color(0,0,0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
        end
    end

    self.team = vgui.Create('DLabel', self.header)
    self.team:Dock(RIGHT)
    self.team:DockMargin(0, 3, 0, 0)
    self.team:SetFont('LPS14')
    self.team:SetTextInset(10, 0)
    self.team:SetText(team.GetName(localPlayer:Team()))
    self.team:SizeToContentsX(10)
    self.team:SetColor(color_white)
    self.team.Paint = function(self, w, h)
        local localPlayer = localPlayer or LocalPlayer()
        if (not IsValid(localPlayer)) then return end
        draw.RoundedBox(3, 0, 0, w, h, team.GetColor(localPlayer:Team()))
    end

    self.name = vgui.Create('DLabel', self.header)
    self.name:Dock(LEFT)
    self.name:SetFont('LPS30')
    self.name:SetColor(Color(0,0,0))
    self.name:DockMargin(0, 0, 8, 0)
    self.name:SetWide((self.panel:GetWide()-self.team:GetWide()) - 30)
    self.name:SetText(LocalPlayer():Nick())
end

--[[---------------------------------------------------------
--   Name: PANEL:GetMargins()
---------------------------------------------------------]]--
function PANEL:GetMargins()
    return 20, 0, 0, 32
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)
    local localPlayer = localPlayer or LocalPlayer()
    if (not IsValid(localPlayer)) then return end
    local teamID = localPlayer:Team()
    local x, y = 0, 0
    local d = 3
    local maxHealth, health = localPlayer:GetMaxHealth(), localPlayer:Health()

    -- DrawBack
    draw.RoundedBox(8, x, y, w, h, Color(255, 255, 255, 190))
    draw.RoundedBox(8, x, y, w/d, h, Color(255, 255, 255))
    draw.RoundedBox(0, w/d - d, y, 4, h, Color(255, 255, 255))

    -- Background
    local cw, cxy = 50, (w/d)/2
    util.DrawSimpleCircle(cxy, cxy, cw, Color(190, 190, 190))

    -- Heath
    util.DrawCircle(cxy, cxy, cw, math.Clamp(self.heath/maxHealth, 0, 1), Color(140, 198, 63))

    -- Armor
    util.DrawCircle(cxy, cxy, cw, math.Clamp(self.armor/100, 0, 1), team.GetColor(localPlayer:Team()))

    self.armor = Lerp(0.3, self.armor, localPlayer:Armor())
    self.heath = Lerp(0.3, self.heath, health)

    surface.SetFont('LPS14')
    local hp = string.format('%s/%s', math.Round(self.heath), maxHealth)
    local tw, th = surface.GetTextSize(hp)
    draw.RoundedBox(4, ((w/d)/2)-(tw/2)-6, (h-5)-th-2, tw+12, th+4, Color(140, 198, 63))
    draw.DrawText(hp, 'LPS14', ((w/d)/2)-(tw/2), (h-5)-th, Color(0,0,0), TEXT_ALIGN_LEFT)

    self.name:SetText(localPlayer:Nick())
    self.team:SetText(team.GetName(localPlayer:Team()))
end

derma.DefineControl('DInfoPlayer', 'A Player HUD', PANEL, 'DPanel')

--[[---------------------------------------------------------
--   Hook: PlayerHUDHide
---------------------------------------------------------]]--
hook.Add('Initialize', 'PlayerHUDHide', function(ply)
    GAMEMODE:AddShouldDraw('CHudBattery', false)
    GAMEMODE:AddShouldDraw('CHudHealth', false)
    GAMEMODE:AddShouldDraw('CHudAmmo', false)
    GAMEMODE:AddShouldDraw('CHudSecondaryAmmo', false)
end)

--[[---------------------------------------------------------
--   Hook: HUDShouldUpdate:PlayerHUD
---------------------------------------------------------]]--
local alive, teamID, isObserver, observeMode, observeTarget, inPreRound, inRound = false, 0, false, OBS_MODE_ROAMING, nil, false, false
hook.Add('HUDShouldUpdate', 'HUDShouldUpdate:PlayerHUD', function(ply)
    if (ply:Alive() ~= alive) then return true end
    if (ply:Team() ~= teamID) then return true end
    if (ply:IsObserver() ~= isObserver) then return true end
    if (ply:GetObserverMode() ~= observeMode) then return true end
    if (ply:GetObserverTarget() ~= observeTarget) then return true end
    if (GAMEMODE:InPreRound() ~= inPreRound) then return true end
    if (GAMEMODE:InRound() ~= inRound) then return true end
end)

--[[---------------------------------------------------------
--   Hook: HUDUpdate:PlayerHUD
---------------------------------------------------------]]--
hook.Add('HUDUpdate', 'HUDUpdate:PlayerHUD', function(ply, hud)

    if (not ply:Alive()) then
        local lbl = nil
        local txt = nil
        local col = Color(255, 255, 255)

        local target, mode = ply:GetObserverTarget(), ply:GetObserverMode()
        if (IsValid(target) and target:IsPlayer() and target ~= ply and mode ~= OBS_MODE_ROAMING) then
            lbl = 'SPECTATING'
            txt = target:Nick()
            col = team.GetColor(target:Team())
        end

        if (table.HasValue({OBS_MODE_DEATHCAM, OBS_MODE_FREEZECAM}, mode)) then
            if (IsValid(target) and target:IsPlayer() and target ~= ply) then
                lbl = 'MURDERER'
                txt = target:Nick()
                col = team.GetColor(target:Team())
            else
                txt = 'You Died!'
            end
        end

        if (txt) then
            local txtLabel = vgui.Create('DHudElement')
            txtLabel:SetText(txt)
            txtLabel:SetColor(Color(255, 255, 255))
            txtLabel:SetShowBackground(false)
            if (lbl) then
                txtLabel:SetLabel(lbl)
                txtLabel:SetColor(Color(0,0,0))
                txtLabel:SetLabelColor(col)
                txtLabel:SetShowBackground(true)
            end

            if (table.HasValue({OBS_MODE_DEATHCAM, OBS_MODE_FREEZECAM}, mode)) then
                    hud:AddItem(txtLabel, 2)
            else
                    hud:AddItem(txtLabel, 3)
            end
        end
    end

    if (not table.HasValue({TEAM.PROPS, TEAM.HUNTERS}, ply:Team())) then return end

    if (ply:Alive()) then
        if ((GAMEMODE:InPreRound() and ply:Team() ~= TEAM.HUNTERS) or GAMEMODE:InRound()) then
            hud:AddItem(vgui.Create('DInfoPlayer'), 1)
        end
    end

end)

--[[---------------------------------------------------------
--   hook: UDOnUpdate:PlayerHUD
---------------------------------------------------------]]--
hook.Add('HUDOnUpdate', 'HUDOnUpdate:PlayerHUD', function(ply)
    alive = ply:Alive()
    teamID = ply:Team()
    isObserver = ply:IsObserver()
    observeMode = ply:GetObserverMode()
    observeTarget = ply:GetObserverTarget()
    inPreRound = GAMEMODE:InPreRound()
    inRound = GAMEMODE:InRound()
end)

