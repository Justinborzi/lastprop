--[[---------------------------------------------------------
--   Name: BUTTON:Init()
---------------------------------------------------------]]--
local BUTTON = {}
function BUTTON:Init()
    self:SetTall(30)
    self.text = ''
    self.enabled = true
    self:SetCursor('hand')
    self:SetMouseInputEnabled(true)
    self.backColor = Color(41, 128, 185)
end

--[[---------------------------------------------------------
--   Name: BUTTON:Paint()
---------------------------------------------------------]]--
function BUTTON:Paint()
    if self.enabled then
        surface.SetDrawColor(self:IsHovered() and util.Lighten(self.backColor, 20) or self.backColor)
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
        draw.DrawText(self.text, 'LPS16', self:GetWide() / 2, self:GetTall() / 2 - 9, Color(236, 240, 241), TEXT_ALIGN_CENTER)
    else
        surface.SetDrawColor(60, 60, 60)
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
        draw.DrawText(self.text, 'LPS16', self:GetWide() / 2, self:GetTall() / 2 - 9, Color(236, 240, 241), TEXT_ALIGN_CENTER)
    end
end

--[[---------------------------------------------------------
--   Name: BUTTON:OnMousePressed()
---------------------------------------------------------]]--
function BUTTON:OnMousePressed()
    if(self.DoClick) then
        self:DoClick()
    end
end

--[[---------------------------------------------------------
--   Name: BUTTON:SetText()
---------------------------------------------------------]]--
function BUTTON:SetText(text)
    self.text = text
end

--[[---------------------------------------------------------
--   Name: BUTTON:SetBackgroundColor()
---------------------------------------------------------]]--
function BUTTON:SetBackgroundColor(color)
    self.backColor = color
end

--[[---------------------------------------------------------
--   Name: BUTTON:Disable()
---------------------------------------------------------]]--
function BUTTON:Disable(bool)
    if bool then
        self.enabled = false
    else
        self.enabled = true
    end
end

vgui.Register('LPSButton', BUTTON, 'DPanel')

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
local PANEL = {}
function PANEL:Init()

    self:SetFocusTopLevel(true)
    self:SetPaintShadow(true)

    self.lblTitle:Remove()
    self.btnClose:Remove()
    self.btnMaxim:Remove()
    self.btnMinim:Remove()

    self.btnClose = vgui.Create('DImageButton', self)
    self.btnClose:SetText('')
    self.btnClose:SetImage('icon16/circlecross.png')
    self.btnClose:SetStretchToFit(false)
    self.btnClose.DoClick = function (button)
        surface.PlaySound('ui/buttonclickrelease.wav')
        self:Remove()
    end
    self.btnClose.Paint = function(panel, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(124, 51, 50))
    end

    self.lblTitle = vgui.Create('DLabel', self)
    self.lblTitle:SetFont('LPS18')
    self.lblTitle:SetColor(Color(236, 240, 241))

    self:SetDraggable(true)
    self:SetSizable(true)
    self:SetScreenLock(false)
    self:SetDeleteOnClose(true)
    self:SetMinWidth(50)
    self:SetMinHeight(50)

    -- This turns off the engine drawing
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
    self.m_fCreateTime = SysTime()
    self:DockPadding(0, 32, 0, 5)
end

--[[---------------------------------------------------------
--   Name: PANEL:ShowCloseButton()
---------------------------------------------------------]]--
function PANEL:ShowCloseButton(show)
    self.btnClose:SetVisible(show)
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(236, 240, 241))
    draw.RoundedBox(0, 0, 0, w, 32, Color(41, 128, 185))
    draw.RoundedBox(0, 0, h-5, w, 5, Color(41, 128, 185))
    return true
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    self.btnClose:SetPos(self:GetWide() - 60, 0)
    self.btnClose:SetSize(60, 32)

    self.lblTitle:SetPos(8, 7)
    self.lblTitle:SetSize(self:GetWide() - 25, 20)
end

derma.DefineControl('LPSFrame', 'LPS DFrame', PANEL, 'DFrame')

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
local PANEL = {}
function PANEL:Init()
    self.Offset = 0
    self.Scroll = 0
    self.CanvasSize = 1
    self.BarSize = 1
    self.btnGrip = vgui.Create('DScrollBarGrip', self)
    self.btnGrip.Paint = function(self)
        draw.RoundedBox(6, 1, 1, self:GetWide()-2, self:GetTall()-2, Color(90,90,90))
    end
    self:SetSize(6, 6)
end

--[[---------------------------------------------------------
--   Name: PANEL:SetEnabled()
---------------------------------------------------------]]--
function PANEL:SetEnabled(b)
    if (not b) then
        self.Offset = 0
        self:SetScroll(0)
        self.HasChanged = true
    end
    self:SetMouseInputEnabled(b)
    self:SetVisible(b)

    if (self.Enabled ~= b) then
        self:GetParent():InvalidateLayout()
        if (self:GetParent().OnScrollbarAppear) then
            self:GetParent():OnScrollbarAppear()
        end
    end
    self.Enabled = b
end

--[[---------------------------------------------------------
--   Name: PANEL:Value()
---------------------------------------------------------]]--
function PANEL:Value()
    return self.Pos
end

--[[---------------------------------------------------------
--   Name: PANEL:BarScale()
---------------------------------------------------------]]--
function PANEL:BarScale()
    if (self.BarSize == 0) then return 1 end
    return self.BarSize / (self.CanvasSize + self.BarSize)
end

--[[---------------------------------------------------------
--   Name: PANEL:SetUp()
---------------------------------------------------------]]--
function PANEL:SetUp(_barsize_, _canvassize_)
    self.BarSize = _barsize_
    self.CanvasSize = math.max(_canvassize_ - _barsize_, 1)
    self:SetEnabled(_canvassize_ > _barsize_)
    self:InvalidateLayout()
end

--[[---------------------------------------------------------
--   Name: PANEL:OnMouseWheeled()
---------------------------------------------------------]]--
function PANEL:OnMouseWheeled(delta)
    if (not self:IsVisible()) then return false end
    return self:AddScroll(delta * -2)
end

--[[---------------------------------------------------------
--   Name: PANEL:AddScroll()
---------------------------------------------------------]]--
function PANEL:AddScroll(delta)
    local OldScroll = self:GetScroll()
    delta = delta * 25
    self:SetScroll(self:GetScroll() + delta)
    return OldScroll ~= self:GetScroll()
end

--[[---------------------------------------------------------
--   Name: PANEL:SetScroll()
---------------------------------------------------------]]--
function PANEL:SetScroll(scroll)
    if (not self.Enabled) then self.Scroll = 0 return end
    self.Scroll = math.Clamp(scroll, 0, self.CanvasSize)
    self:InvalidateLayout()
    local func = self:GetParent().OnVScroll
    if (func) then
        func(self:GetParent(), self:GetOffset())
    else
        self:GetParent():InvalidateLayout()
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:AnimateTo()
---------------------------------------------------------]]--
function PANEL:AnimateTo(scroll, length, delay, ease)
    local anim = self:NewAnimation(length, delay, ease)
    anim.StartPos = self.Scroll
    anim.TargetPos = scroll
    anim.Think = function(anim, pnl, fraction)
        pnl:SetScroll(Lerp(fraction, anim.StartPos, anim.TargetPos))
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:GetScroll()
---------------------------------------------------------]]--
function PANEL:GetScroll()
    if (not self.Enabled) then self.Scroll = 0 end
    return self.Scroll
end

--[[---------------------------------------------------------
--   Name: PANEL:GetOffset()
---------------------------------------------------------]]--
function PANEL:GetOffset()
    if (not self.Enabled) then return 0 end
    return self.Scroll * -1
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think() end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h) end

--[[---------------------------------------------------------
--   Name: PANEL:OnMousePressed()
---------------------------------------------------------]]--
function PANEL:OnMousePressed()
    local x, y = self:CursorPos()
    local PageSize = self.BarSize
    if (y > self.btnGrip.y) then
        self:SetScroll(self:GetScroll() + PageSize)
    else
        self:SetScroll(self:GetScroll() - PageSize)
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:OnMouseReleased()
---------------------------------------------------------]]--
function PANEL:OnMouseReleased()
    self.Dragging = false
    self.DraggingCanvas = nil
    self:MouseCapture(false)
    self.btnGrip.Depressed = false
end

--[[---------------------------------------------------------
--   Name: PANEL:OnCursorMoved()
---------------------------------------------------------]]--
function PANEL:OnCursorMoved(x, y)
    if (not self.Enabled) then return end
    if (not self.Dragging) then return end
    local x, y = self:ScreenToLocal(0, gui.MouseY())
    y = y - self.HoldPos
    local TrackSize = self:GetTall() - self.btnGrip:GetTall()
    y = y / TrackSize
    self:SetScroll(y * self.CanvasSize)
end

--[[---------------------------------------------------------
--   Name: PANEL:Grip()
---------------------------------------------------------]]--
function PANEL:Grip()
    if (not self.Enabled) then return end
    if (self.BarSize == 0) then return end
    self:MouseCapture(true)
    self.Dragging = true
    local x, y = self.btnGrip:ScreenToLocal(0, gui.MouseY())
    self.HoldPos = y
    self.btnGrip.Depressed = true
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    local Wide = self:GetWide()
    local Scroll = self:GetScroll() / self.CanvasSize
    local BarSize = math.max(self:BarScale() * self:GetTall(), 10)
    local Track = self:GetTall() - BarSize
    Track = Track + 1
    Scroll = Scroll * Track
    self.btnGrip:SetPos(0, Scroll)
    self.btnGrip:SetSize(Wide, BarSize)
end

derma.DefineControl('LPSScrollBar', 'A Scrollbar', PANEL, 'Panel')

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
local PANEL = {}

AccessorFunc(PANEL, 'Padding', 'Padding')
AccessorFunc(PANEL, 'pnlCanvas', 'Canvas')

function PANEL:Init()
    self.pnlCanvas = vgui.Create('Panel', self)
    self.pnlCanvas.OnMousePressed = function(self, code) self:GetParent():OnMousePressed(code) end
    self.pnlCanvas:SetMouseInputEnabled(true)
    self.pnlCanvas.PerformLayout = function(pnl)
        self:PerformLayout()
        self:InvalidateParent()
    end

    -- Create the scroll bar
    self.VBar = vgui.Create('LPSScrollBar', self)
    self.VBar:Dock(RIGHT)

    self:SetPadding(0)
    self:SetMouseInputEnabled(true)

    -- This turns off the engine drawing
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
    self:SetPaintBackground(false)
end

--[[---------------------------------------------------------
--   Name: PANEL:AddItem()
---------------------------------------------------------]]--
function PANEL:AddItem(pnl)
    pnl:SetParent(self:GetCanvas())
end

--[[---------------------------------------------------------
--   Name: PANEL:OnChildAdded()
---------------------------------------------------------]]--
function PANEL:OnChildAdded(child)
    self:AddItem(child)
end

--[[---------------------------------------------------------
--   Name: PANEL:SizeToContents()
---------------------------------------------------------]]--
function PANEL:SizeToContents()
    self:SetSize(self.pnlCanvas:GetSize())
end

--[[---------------------------------------------------------
--   Name: PANEL:GetVBar()
---------------------------------------------------------]]--
function PANEL:GetVBar()
    return self.VBar
end

--[[---------------------------------------------------------
--   Name: PANEL:GetCanvas()
---------------------------------------------------------]]--
function PANEL:GetCanvas()
    return self.pnlCanvas
end

--[[---------------------------------------------------------
--   Name: PANEL:InnerWidth()
---------------------------------------------------------]]--
function PANEL:InnerWidth()
    return self:GetCanvas():GetWide()
end

--[[---------------------------------------------------------
--   Name: PANEL:Rebuild()
---------------------------------------------------------]]--
function PANEL:Rebuild()
    self:GetCanvas():SizeToChildren(false, true)
    -- Although this behaviour isn't exactly implied, center vertically too
    if (self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall()) then
        self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5)
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:OnMouseWheeled()
---------------------------------------------------------]]--
function PANEL:OnMouseWheeled(delta)
    return self.VBar:OnMouseWheeled(delta)
end

--[[---------------------------------------------------------
--   Name: PANEL:OnVScroll()
---------------------------------------------------------]]--
function PANEL:OnVScroll(iOffset)
    self.pnlCanvas:SetPos(0, iOffset)
end

--[[---------------------------------------------------------
--   Name: PANEL:ScrollToChild()
---------------------------------------------------------]]--
function PANEL:ScrollToChild(panel)
    self:PerformLayout()
    local x, y = self.pnlCanvas:GetChildPosition(panel)
    local w, h = panel:GetSize()
    y = y + h * 0.5
    y = y - self:GetTall() * 0.5
    self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    local Tall = self.pnlCanvas:GetTall()
    local Wide = self:GetWide()
    local YPos = 0
    self:Rebuild()
    self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
    YPos = self.VBar:GetOffset()
    if (self.VBar.Enabled) then Wide = Wide - self.VBar:GetWide() end
    self.pnlCanvas:SetPos(0, YPos)
    self.pnlCanvas:SetWide(Wide)
    self:Rebuild()
    if (Tall ~= self.pnlCanvas:GetTall()) then
        self.VBar:SetScroll(self.VBar:GetScroll()) -- Make sure we are not too far down!
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:Clear()
---------------------------------------------------------]]--
function PANEL:Clear()
    return self.pnlCanvas:Clear()
end

derma.DefineControl('LPSScroll', '', PANEL, 'DPanel')

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
local PANEL = {}

AccessorFunc(PANEL, 'info', 'Info', FORCE_STRING)

function PANEL:Init()
    self:SetImage('icon16/help.png')
    self:SetMouseInputEnabled(true)

    self.infoW = 200
    self.infoH = 90
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:SetInfoSize(w, h)
    self.infoW = w
    self.infoH = h
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think()
    local info = self:GetInfo()
    if (info and info ~= '' and self:IsHovered() and not IsValid(self.infobox)) then

        local x, y = self:LocalToScreen(8,8)
        local w, h = self.infoW, self.infoH
        local text = util.textWrap(info, 'LPS14', w - 10)

        self.infobox = vgui.Create('DPanel')
        self.infobox:SetSize(w, h)
        self.infobox.Paint = function(self)
            local ts = 8
            local w, h = self:GetWide(), self:GetTall()
            local triangle = {
                { x = (w / 2), y = h },
                { x = (w / 2) - ts, y = h -ts},
                { x = (w / 2) + ts , y = h -ts}
            }
            local color = Color(0, 0, 0, 250)
            draw.RoundedBox(4, 0, 0, w, h - ts, color)
            surface.SetDrawColor(color)
            draw.NoTexture()
            surface.DrawPoly(triangle)
            surface.SetFont('LPS14')
            local tw, th = surface.GetTextSize(text)
            draw.DrawText(text, 'LPS14', w/2, ((h - ts)/2) - (th/2), Color(255,255,255), TEXT_ALIGN_CENTER)
        end

        self.infobox:SetPos(x - (w/2), y - (h + (self:GetTall() / 2)))
        self.infobox:MakePopup()
    else
        if (not self:IsHovered() and IsValid(self.infobox)) then
            self.infobox:Remove()
        end
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:Remove()
---------------------------------------------------------]]--
function PANEL:OnRemove()
    if (IsValid(self.infobox)) then
        self.infobox:Remove()
    end
end

derma.DefineControl('LPSInfoBox', '', PANEL, 'DImage')

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
local PANEL = {}

function PANEL:Init()
    self.Avatar = vgui.Create('AvatarImage', self)
    self.Avatar:SetPaintedManually(true)
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    self.Avatar:SetSize(self:GetWide(), self:GetTall())
end

--[[---------------------------------------------------------
--   Name: PANEL:SetPlayer()
---------------------------------------------------------]]--
function PANEL:SetPlayer(ply)
    self.Avatar:SetPlayer(ply)
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)
    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)

    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)

    util.DrawSimpleCircle(w/2, w/2, w/2, color_white)

    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)

    self.Avatar:SetPaintedManually(false)
    self.Avatar:PaintManual()
    self.Avatar:SetPaintedManually(true)

    render.SetStencilEnable(false)
    render.ClearStencil()
end

vgui.Register('AvatarMask', PANEL)