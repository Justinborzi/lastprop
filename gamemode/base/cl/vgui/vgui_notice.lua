local PANEL = {}
--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self.m_bHighlight = false
    self.padding = 8
    self.spacing = 8
    self.items = {}
end

--[[---------------------------------------------------------
--   Name: PANEL:AddEntityText()
---------------------------------------------------------]]--
function PANEL:AddEntityText(ent)
    if (type(ent) == 'string') then return false end
    if (type(ent) == 'Player') then
        self:AddText(ent:Nick(), team.GetColor(ent:Team()))
        if (ent == LocalPlayer()) then self.m_bHighlight = true end
        return true
    end

    if(IsValid(ent)) then
        self:AddText(ent:GetClass())
    else
        self:AddText(tostring(ent))
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:AddItem()
---------------------------------------------------------]]--
function PANEL:AddItem(item)
    table.insert(self.items, item)
    self:InvalidateLayout(true)
end

--[[---------------------------------------------------------
--   Name: PANEL:AddText()
---------------------------------------------------------]]--
function PANEL:AddText(txt, color)
    if (self:AddEntityText(txt)) then return end
    local txt = tostring(txt)
    local lbl = vgui.Create('DLabel', self)
    lbl:SetFont('LPS18')
    lbl:SetText(txt)
    lbl:SetTextColor(color or color_black)
    self:AddItem(lbl)
end

--[[---------------------------------------------------------
--   Name: PANEL:AddIcon()
---------------------------------------------------------]]--
function PANEL:AddIcon(txt)
    if (killicon.Exists(txt)) then
        local icon = vgui.Create('DKillIcon', self)
        icon:SetName(txt)
        icon:SizeToContents()
        self:AddItem(icon)
    else
        self:AddText('killed')
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    local x = self.padding
    local height = self.padding * 0.5
    for k, v in pairs(self.items) do
        v:SetPos(x, self.padding * 0.5)
        v:SizeToContents()
        x = x + v:GetWide() + self.spacing
        height = math.max(height, v:GetTall() + self.padding)
    end
    self:SetSize(x + self.padding, height)
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w,h)
    draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 180))
end

derma.DefineControl('GameNotice', '', PANEL, 'DPanel')

--[[---------------------------------------------------------
--   Name: GM:CreateGameNotify()
---------------------------------------------------------]]--
function GM:CreateGameNotify()
    local x, y = ScrW(), ScrH()
    self.notify = vgui.Create('DNotify')
    self.notify:SetPos(0, 25)
    self.notify:SetSize(x - (25), y)
    self.notify:SetAlignment(9)
    self.notify:SetLife(4)
    self.notify:ParentToHUD()
end