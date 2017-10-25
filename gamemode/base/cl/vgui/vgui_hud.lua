--[[---------------------------------------------------------
--   Name: DHudLayout
---------------------------------------------------------]]--

local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self.items = {}
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
    self:ParentToHUD()
end

--[[---------------------------------------------------------
--   Name: PANEL:ChooseParent()
---------------------------------------------------------]]--
function PANEL:ChooseParent()
    -- This makes it so that it's behind chat & hides when you're in the menu
    -- But it also removes the ability to click on it. So override it if you want to.
    self:ParentToHUD()
end

--[[---------------------------------------------------------
--   Name: PANEL:Clear()
---------------------------------------------------------]]--
function PANEL:Clear(delete)
    for _, panel in pairs(self.items) do
        if (panel and panel:IsValid()) then
            panel:SetParent(panel)
            panel:SetVisible(false)
            if (delete) then
                panel:Remove()
            end
        end
    end
    self.items = {}
end

--[[---------------------------------------------------------
--   Name: PANEL:AddItem()
---------------------------------------------------------]]--
function PANEL:AddItem(item, pos, relative)
    if not item or not item:IsValid() then return end
    item.pos = pos
    item.relative = relative
    item:SetVisible(true)
    item:SetParent(self)
    table.insert(self.items, item)
    self:InvalidateLayout()
end

--[[---------------------------------------------------------
--   Name: PANEL:PositionItem()
---------------------------------------------------------]]--
function PANEL:PositionItem(item)
    if (item.positioned) then return end
    if (IsValid(item.relative) and item ~= item.relative) then self:PositionItem(item.relative) end

    local l, t, r, b
    if (item.GetMargins) then
         l, t, r, b = item:GetMargins()
    else
        l, t, r, b = 0, 0, 0, 0
    end

    item:InvalidateLayout(true)

    if (item.pos == 7 or item.pos == 8 or item.pos == 9) then
        if (IsValid(item.relative)) then
            item:MoveAbove(item.relative, t)
        else
            item:AlignTop(t)
        end
    end

    if (item.pos == 4 or item.pos == 5 or item.pos == 6) then
        if (IsValid(item.relative)) then
            item.y = item.relative.y + t
        else
            item:CenterVertical()
        end
    end

    if (item.pos == 1 or item.pos == 2 or item.pos == 3) then
        if (IsValid(item.relative)) then
            item:MoveBelow(item.relative, b)
        else
            item:AlignBottom(b)
        end
    end

    if (item.pos == 7 or item.pos == 4 or item.pos == 1) then
        if (IsValid(item.relative)) then
            item.x = item.relative.x + l
        else
            item:AlignLeft(l)
        end
    end

    if (item.pos == 8 or item.pos == 5 or item.pos == 2) then
        if (IsValid(item.relative)) then
            item.x = (item.relative.x + (item.relative:GetWide() - item:GetWide()) / 2)
        else
            item:CenterHorizontal()
        end
    end

    if (item.pos == 9 or item.pos == 6 or item.pos == 3) then
        if (IsValid(item.relative)) then
            item.x = (item.relative.x + item.relative:GetWide() - item:GetWide()) + r
        else
            item:AlignRight(r)
        end
    end

    if (item.pos == 4 and IsValid(item.relative)) then
        item:MoveLeftOf(item.relative, r)
    end

    if (item.pos == 6 and IsValid(item.relative)) then
        item:MoveRightOf(item.relative, l)
    end

    item.positioned = true
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think()
    self:InvalidateLayout()
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    self:SetPos(0, 0)
    self:SetWide(ScrW())
    self:SetTall(ScrH())
    for _, item in pairs(self.items) do
        item.positioned = false
    end
    for _, item in pairs(self.items) do
        self:PositionItem(item)
    end
end

derma.DefineControl("DHudLayout", "A HUD Layout Base", PANEL, "Panel")

--[[---------------------------------------------------------
--   Name: HudBase
---------------------------------------------------------]]--
local PANEL = {}

AccessorFunc(PANEL, "partOfBar",     "PartOfBar")
AccessorFunc(PANEL, "showBack",     "ShowBackground")

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:SetText("-")
    self:SetTextColor(self:GetDefaultTextColor())
    self:SetFont("LPS30")
    self:ChooseParent()
    self:SetShowBackground(true)
    self.margins = {10, 10, 10, 10}
end

--[[---------------------------------------------------------
--   Name: PANEL:SetMargins()
---------------------------------------------------------]]--
function PANEL:SetMargins(marginLeft, marginTop, marginRight, marginBottom)
    self.margins = {marginLeft, marginTop, marginRight, marginBottom}
end

--[[---------------------------------------------------------
--   Name: PANEL:GetMargins()
---------------------------------------------------------]]--
function PANEL:GetMargins()
    return self.margins[1], self.margins[2], self.margins[3], self.margins[4]
end

--[[---------------------------------------------------------
--   Name: PANEL:ChooseParent()
---------------------------------------------------------]]--
function PANEL:ChooseParent()
    -- This makes it so that it's behind chat & hides when you're in the menu
    -- But it also removes the ability to click on it. So override it if you want to.
    self:ParentToHUD()
end

--[[---------------------------------------------------------
--   Name: PANEL:GetPadding()
---------------------------------------------------------]]--
function PANEL:GetPadding()
    return 10
end

--[[---------------------------------------------------------
--   Name: PANEL:GetDefaultTextColor()
---------------------------------------------------------]]--
function PANEL:GetDefaultTextColor()
    return Color(0, 0, 0, 255)
end

--[[---------------------------------------------------------
--   Name: PANEL:GetTextLabelColor()
---------------------------------------------------------]]--
function PANEL:GetTextLabelColor()
    return Color(255, 255, 255)
end

--[[---------------------------------------------------------
--   Name: PANEL:GetTextLabelFont()
---------------------------------------------------------]]--
function PANEL:GetTextLabelFont()
    return "LPS16"
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)
    if (self.showBack and not self.partOfBar) then
        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255, 180))
    end
end

derma.DefineControl("HudBase", "A HUD Base Element (override to change the style)", PANEL, "DLabel")


local PANEL = {}

AccessorFunc(PANEL, "items",     "Items")
AccessorFunc(PANEL, "horizontal","Horizontal")
AccessorFunc(PANEL, "spacing",     "Spacing")
AccessorFunc(PANEL, "alignBottom", "AlignBottom")
AccessorFunc(PANEL, "alignCenter", "AlignCenter")

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self.items = {}
    self:SetHorizontal(true)
    self:SetText("")
    self:SetAlignCenter(true)
    self:SetSpacing(8)
    self.margins = { 10, 10, 10, 10}
end

--[[---------------------------------------------------------
--   Name: PANEL:SetMargins()
---------------------------------------------------------]]--
function PANEL:SetMargins(marginLeft, marginTop, marginRight, marginBottom)
    self.margins = {marginLeft, marginTop, marginRight, marginBottom}
end

--[[---------------------------------------------------------
--   Name: PANEL:GetMargins()
---------------------------------------------------------]]--
function PANEL:GetMargins()
    return self.margins[1], self.margins[2], self.margins[3], self.margins[4]
end

--[[---------------------------------------------------------
--   Name: PANEL:AddItem()
---------------------------------------------------------]]--
function PANEL:AddItem(item)
    item:SetParent(self)
    table.insert(self.items, item)
    self:InvalidateLayout()
    item:SetPaintBackgroundEnabled(false)
    item.partOfBar = true
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    if (self.horizontal) then
        local x = 0
        local tallest = 0
        for _, v in pairs(self.items) do
            v:SetPos(x, 0)
            x = x + v:GetWide()
            tallest = math.max(tallest, v:GetTall())
            if (self.alignBottom) then v:AlignBottom() end
            if (self.alignCenter) then v:CenterVertical() end
        end
        self:SetSize(x, tallest)
    else
        -- todo:
    end
end

derma.DefineControl("DHudBar", "", PANEL, "HudBase")

--[[---------------------------------------------------------
--   Name: DHudElement
---------------------------------------------------------]]--

local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self.margins = {10, 10, 10, 10}
end

--[[---------------------------------------------------------
--   Name: PANEL:SetMargins()
---------------------------------------------------------]]--
function PANEL:SetMargins(marginLeft, marginTop, marginRight, marginBottom)
    self.margins = {marginLeft, marginTop, marginRight, marginBottom}
end

--[[---------------------------------------------------------
--   Name: PANEL:GetMargins()
---------------------------------------------------------]]--
function PANEL:GetMargins()
    return self.margins[1], self.margins[2], self.margins[3], self.margins[4]
end

--[[---------------------------------------------------------
--   Name: PANEL:SetLabelColor()
---------------------------------------------------------]]--
function PANEL:SetLabelColor(color)
    self.labelColor = color
end

--[[---------------------------------------------------------
--   Name: PANEL:GetLabelColor()
---------------------------------------------------------]]--
function PANEL:GetLabelColor()
    if (self.labelColor) then
        return self.labelColor
    end
    local localPlayer = LocalPlayer()
    if (IsValid(localPlayer) and table.HasValue({TEAM.PROPS, TEAM.HUNTERS}, localPlayer:Team())) then
        return team.GetColor(localPlayer:Team())
    else
        return Color(0,0,0)
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:SetLabel()
---------------------------------------------------------]]--
function PANEL:SetLabel(text)
    self.labelPanel = vgui.Create("DLabel", self)
    self.labelPanel:SetText(text)
    self.labelPanel:SetTextColor(self:GetTextLabelColor())
    self.labelPanel:SetFont(self:GetTextLabelFont())
    self.labelPanel.Paint = function(label, w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:GetLabelColor())
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:PerformLayout()
---------------------------------------------------------]]--
function PANEL:PerformLayout()
    self:SetContentAlignment(5)
    if (self.labelPanel) then
        self.labelPanel:Dock(TOP)
        self.labelPanel:SizeToContents()
        self.labelPanel:SetSize(self.labelPanel:GetWide() + self:GetPadding() * 2, self.labelPanel:GetTall() + self:GetPadding()/2)
        self.labelPanel:SetContentAlignment(5)
        self:SetTextInset(self.labelPanel:GetTall() + self:GetPadding(), 0)
        self:SetContentAlignment(2)
        self:SizeToContents()

        if (self.labelPanel:GetWide() > self:GetWide()) then
            self:SetSize(self.labelPanel:GetWide() + self:GetPadding(), self:GetTall() + (self:GetPadding() * 2))
        else
            self:SetSize(self:GetWide() + self:GetPadding() * 2, self:GetTall() + (self:GetPadding() * 2))
        end

    else
        self:SizeToContents()
        self:SetSize(self:GetWide() + self:GetPadding() * 2, self:GetTall() + self:GetPadding())
    end
end

derma.DefineControl("DHudElement", "A HUD Element", PANEL, "HudBase")

--[[---------------------------------------------------------
--   Name: DHudUpdater
---------------------------------------------------------]]--

local PANEL = {}

AccessorFunc(PANEL, "valueFunction",     "ValueFunction")
AccessorFunc(PANEL, "colorFunction",     "ColorFunction")

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self.margins = {10, 10, 10, 10}
end

--[[---------------------------------------------------------
--   Name: PANEL:SetMargins()
---------------------------------------------------------]]--
function PANEL:SetMargins(marginLeft, marginTop, marginRight, marginBottom)
    self.margins = {marginLeft, marginTop, marginRight, marginBottom}
end

--[[---------------------------------------------------------
--   Name: PANEL:GetMargins()
---------------------------------------------------------]]--
function PANEL:GetMargins()
    return self.margins[1], self.margins[2], self.margins[3], self.margins[4]
end

--[[---------------------------------------------------------
--   Name: PANEL:GetTextValueFromFunction()
---------------------------------------------------------]]--
function PANEL:GetTextValueFromFunction()
    if (not self.valueFunction) then return "-" end
    return tostring(self:valueFunction())
end

--[[---------------------------------------------------------
--   Name: PANEL:GetColorFromFunction()
---------------------------------------------------------]]--
function PANEL:GetColorFromFunction()
    if (not self.colorFunction) then return self:GetDefaultTextColor() end
    return self:colorFunction()
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think()
    self:SetTextColor(self:GetColorFromFunction())
    self:SetText(self:GetTextValueFromFunction())
end

derma.DefineControl("DHudUpdater", "A HUD Element", PANEL, "DHudElement")

--[[---------------------------------------------------------
--   Name: DHudCountdown
---------------------------------------------------------]]--

local PANEL = {}

AccessorFunc(PANEL, "m_Function",     "Function")

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self.BaseClass:Init()
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think()

    if (not self.valueFunction) then return end

    self:SetTextColor(self:GetColorFromFunction())

    local endTime = self:valueFunction()
    if (endTime == -1) then return end

    if (not endTime or endTime < CurTime()) then
        self:SetText("00:00")
        return
    end

    local time = util.ToMinutes(endTime - CurTime())
    self:SetText(time)

end

derma.DefineControl("DHudCountdown", "A HUD Element", PANEL, "DHudUpdater")
