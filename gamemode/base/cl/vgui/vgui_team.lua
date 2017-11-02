local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self.panel = vgui.Create('DPanel', self)
    self.panel:Dock(BOTTOM)
    self.panel:DockMargin(15, 0, 15, 20)
    self.panel:SetTall(100)
    self.panel:SetMouseInputEnabled(true)
    self.panel.Paint = function(self,w,h)
        draw.RoundedBox(6, 0, 0, w, h, Color(0,0,0,245))
    end

    self.label = vgui.Create('DLabel', self.panel)
    self.label:DockMargin(10, 10, 10, 10)
    self.label:Dock(FILL)
    self.label.Paint = function(self,w,h) end
    self.label:SetColor(Color(255,255,255))
    self.label:SetWrap(true)
    self.label:SetMouseInputEnabled(true)
    self.label:SetText('No Description Set')
    self.label:SetTall(90)

    self.teamID = 0
    self.backColor = Color(0,0,0)
end

--[[---------------------------------------------------------
--   Name: PANEL:LayoutEntity()
---------------------------------------------------------]]--
function PANEL:LayoutEntity(ent)
    self:RunAnimation()
end

--[[---------------------------------------------------------
--   Name: PANEL:SetTeam()
---------------------------------------------------------]]--
function PANEL:SetTeam(teamID, animation, description)
    self.teamID = teamID
    local class = lps.class:Get(team.GetClass(teamID))
    if (not class or not class.playerModel) then return end
    self:SetModel(player_manager.TranslatePlayerModel(type(class.playerModel) == 'table' and class.playerModel[1] or class.playerModel))
    self:SetCamPos(Vector(80, 0, 30))
    self:SetLookAt(Vector(0, 0, 40))
    self:SetAnimated(true)
    self.Entity:SetSequence(self.Entity:LookupSequence(animation))
    self.label:SetText(class.description)
    self.label:SizeToContentsX()
end

--[[---------------------------------------------------------
--   Name: PANEL:SetColor()
---------------------------------------------------------]]--
function PANEL:SetColor(color)
    self.backColor = color
end

--[[---------------------------------------------------------
--   Name: PANEL:OnMousePressed()
---------------------------------------------------------]]--
function PANEL:OnMousePressed(keyCode)
    if(self.DoClick) then
        self:DoClick(teamID)
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)
    if (self.teamID > 0) then
        local localPlayer = LocalPlayer()
        local class = lps.class:Get(team.GetClass(self.teamID))
        if (not class or not class.playerModel) then return end

        if (self:IsHovered() or self.panel:IsHovered() or self.label:IsHovered()) then
            draw.RoundedBox(8, 0, 0, w, h, util.Lighten(self.backColor, 20))
        else
            draw.RoundedBox(8, 0, 0, w, h, self.backColor)
        end

        self.BaseClass.Paint(self, w, h)

        surface.SetFont('LPS40')
        local text = string.upper(team.GetName(self.teamID))
        local tw, th = surface.GetTextSize(text)
        draw.SimpleText(text, 'LPS40', (w/2) , th, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

derma.DefineControl('DTeamModelPanel', '', PANEL, 'DModelPanel')

local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:ParentToHUD()
    self:SetSize(ScrW(), ScrH())
    self:SetMouseInputEnabled(true)

    local cx, cy =  ScrW()/2, ScrH()/2
    local localPlayer = LocalPlayer()

    self.center = vgui.Create('DPanel', self)
    self.center:SetSize(cx, cy)
    self.center:SetPos(cx/2, cy/2)
    self.center.Paint = function() end

    self.label = vgui.Create('DLabel', self.center)
    self.label:DockMargin(0, 0, 0, 10)
    self.label:Dock(TOP)
    self.label:SetTall(60)
    self.label:SetColor(Color(255,255,255))
    self.label:SetFont('LPS80')
    self.label:SetText('CHOOSE YOUR SIDE')
    self.label:SetContentAlignment(5)

    self.propSelect = vgui.Create('DTeamModelPanel', self.center)
    self.propSelect:SetWide(cx/2 - 5)
    self.propSelect:Dock(LEFT)
    self.propSelect:SetTeam(TEAM.PROPS, 'idle_all_scared')
    self.propSelect.OnMousePressed = function()
        local localPlayer = localPlayer or LocalPlayer()
        if (not IsValid(localPlayer)) then return end
        if (GAMEMODE:PlayerCanJoinTeam(localPlayer, TEAM.PROPS) and localPlayer:Team() ~= TEAM.PROPS) then
            RunConsoleCommand('changeteam', TEAM.PROPS)
            self:Remove()
        end
    end

    self.hunterSelect = vgui.Create('DTeamModelPanel', self.center)
    self.hunterSelect:SetWide(cx/2 - 5)
    self.hunterSelect:Dock(RIGHT)
    self.hunterSelect:SetTeam(TEAM.HUNTERS, 'idle_all_angry')
    self.hunterSelect.OnMousePressed = function()
        local localPlayer = localPlayer or LocalPlayer()
        if (not IsValid(localPlayer)) then return end
        if (GAMEMODE:PlayerCanJoinTeam(localPlayer, TEAM.HUNTERS) and localPlayer:Team() ~= TEAM.HUNTERS) then
            RunConsoleCommand('changeteam', TEAM.HUNTERS)
            self:Remove()
        end
    end

    self.spectateSelect = vgui.Create('DLabel', self)
    self.spectateSelect:SetSize(150, 40)
    self.spectateSelect:SetPos(cx + cx/2 -150, cy + cy/2 + 10)
    self.spectateSelect:SetFont('LPS16')
    self.spectateSelect:SetColor(Color(0, 0, 0))
    self.spectateSelect:SetText('SPECTATE')
    self.spectateSelect:SetContentAlignment(5)
    self.spectateSelect:SetMouseInputEnabled(true)
    self.spectateSelect:SetCursor('hand')
    self.spectateSelect.Paint = function(self,w,h)
        if (self:IsHovered()) then
            draw.RoundedBox(6, 0, 0, w, h, Color(255,255,255,250))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(200,200,200,250))
        end
    end
    self.spectateSelect.OnMousePressed = function()
        local localPlayer = localPlayer or LocalPlayer()
        if (not IsValid(localPlayer)) then return end
        if (GAMEMODE:PlayerCanJoinTeam(localPlayer, TEAM.SPECTATORS) and localPlayer:Team() ~= TEAM.SPECTATORS) then
            RunConsoleCommand('changeteam', TEAM.SPECTATORS)
            self:Remove()
        end
    end

    self.autoSelect = vgui.Create('DLabel', self)
    self.autoSelect:SetSize(150, 40)
    self.autoSelect:SetPos(cx - cx/2, cy + cy/2 + 10)
    self.autoSelect:SetFont('LPS16')
    self.autoSelect:SetColor(Color(0, 0, 0))
    self.autoSelect:SetText('AUTO TEAM')
    self.autoSelect:SetContentAlignment(5)
    self.autoSelect:SetMouseInputEnabled(true)
    self.autoSelect:SetCursor('hand')
    self.autoSelect.Paint = function(self,w,h)
        if (self:IsHovered()) then
            draw.RoundedBox(6, 0, 0, w, h, Color(255,255,255,250))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(200,200,200,250))
        end
    end
    self.autoSelect.OnMousePressed = function()
        RunConsoleCommand('autoteam')
        self:Remove()
    end

    self:SetVisible(true)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)

    self.openTime = SysTime()
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think()
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer) or not self:IsVisible()) then return end

    local plyTeam = localPlayer:Team()
    if (plyTeam == TEAM.UNASSIGNED) then
        self.autoSelect:SetVisible(true)
    else
        self.autoSelect:SetVisible(false)
    end

    if (plyTeam == TEAM.SPECTATORS) then
        self.spectateSelect:SetVisible(false)
    else
        self.spectateSelect:SetVisible(true)
    end

    if (GAMEMODE:PlayerCanJoinTeam(localPlayer, TEAM.PROPS) and plyTeam ~= TEAM.PROPS) then
        self.propSelect:SetCursor('hand')
        self.propSelect:SetColor(team.GetColor(TEAM.PROPS))
    else
        self.propSelect:SetCursor('arrow')
        self.propSelect:SetColor(Color(80,80,80))
    end

    if (GAMEMODE:PlayerCanJoinTeam(localPlayer, TEAM.HUNTERS) and plyTeam ~= TEAM.HUNTERS) then
        self.hunterSelect:SetCursor('hand')
        self.hunterSelect:SetColor(team.GetColor(TEAM.HUNTERS))
    else
        self.hunterSelect:SetCursor('arrow')
        self.hunterSelect:SetColor(Color(80,80,80))
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint()
    Derma_DrawBackgroundBlur(self, self.openTime)
    surface.SetDrawColor(0, 0, 0, 90)
    surface.DrawRect(0, 0, ScrW(), ScrH())
end

--[[---------------------------------------------------------
--   Name: PANEL:OnMousePressed()
---------------------------------------------------------]]--
function PANEL:OnMousePressed(keyCode)
    if (not IsValid(LocalPlayer()) or LocalPlayer():Team() == TEAM.UNASSIGNED) then return end
    self:Remove()
end

--[[---------------------------------------------------------
--   Name: PANEL:OnMousePressed()
---------------------------------------------------------]]--
function PANEL:OnRemove()
    gui.EnableScreenClicker(false)
end

derma.DefineControl('LPSTeamSelect', '', PANEL, 'DPanel')

--[[---------------------------------------------------------
--   Name: GM:ShouldShowTeam()
---------------------------------------------------------]]--
function GM:ShouldShowTeam()
    return true
end

--[[---------------------------------------------------------
--   Name: GM:ShowTeam()
---------------------------------------------------------]]--
local teamSelect
function GM:ShowTeam()
    if (IsValid(teamSelect)) then
        teamSelect:Remove()
    else
        teamSelect = vgui.Create('LPSTeamSelect')
    end
end

--[[---------------------------------------------------------
--   Name: GM:HideTeam()
---------------------------------------------------------]]--
function GM:HideTeam()
    if (IsValid(teamSelect)) then
        teamSelect:Remove()
    end
end

--[[---------------------------------------------------------
--   Hook: IsBusy:ShowTeam
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:ShowTeam', function ()
    if (IsValid(teamSelect) and teamSelect:IsVisible()) then return true end
end)