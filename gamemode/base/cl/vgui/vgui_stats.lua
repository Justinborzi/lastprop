local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:SetSize(600, 500)
    self:Center()
    self:SetTitle('LPS Stats')
    self:SetDraggable(true)
    self:SetSizable(true)
    self:SetDeleteOnClose(true)
    self:MakePopup()
end

--[[---------------------------------------------------------
--   Name: PANEL:Show()
---------------------------------------------------------]]--
function PANEL:Show(stats, top)

    if (not stats or not top) then return end --just incase

    local columns = {
        ['name'] = 'Name',
        ['wins'] = 'Rounds Won',
        ['losses'] = 'Rounds Lost',
        ['prop_kills'] = 'Prop Kills',
        ['hunter_kills'] = 'Hunter Kills',
        ['lastman_kills'] = 'Last Prop Kills',
        ['suicides'] = 'Suicides',
        ['deaths'] = 'Deaths',
    }

    local order = {
        'name',
        'wins',
        'losses',
        'suicides',
        'deaths',
        'prop_kills',
        'hunter_kills',
        'lastman_kills',
    }

    local orderKeys = {
        ['name'] = 1,
        ['wins'] = 2,
        ['losses'] = 3,
        ['suicides'] = 4,
        ['deaths'] = 5,
        ['prop_kills'] = 6,
        ['hunter_kills'] = 7,
        ['lastman_kills'] = 8,
    }

    self.name = vgui.Create('DLabel', self)
    self.name:SetWide(100)
    self.name:DockMargin(5, 5, 5, 5)
    self.name:Dock(TOP)
    self.name:SetText(LocalPlayer():Nick())
    self.name:SetColor(Color(0,0,0))
    self.name:SetFont('LPS24')
    self.name:SetTall(28)
    self.name.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, h-2, w, 2, Color(41, 128, 185))
    end

    self.stats = vgui.Create('Panel', self)
    self.stats:Dock(TOP)
    self.stats:SetSize(180, 180)

    self.left = vgui.Create('Panel', self.stats)
    self.left:Dock(LEFT)
    self.left:SetSize(180, 180)

    self.right = vgui.Create('Panel', self.stats)
    self.right:DockMargin(10, 10, 10, 10)
    self.right:Dock(FILL)
    self.right:SetSize(180, 180)

    self.info = vgui.Create('Panel', self.right)
    self.info:Dock(FILL)
    self.info:SetSize(180, 180)
    self.info:DockPadding(0, 6, 0, 6)
    self.info.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(255, 255, 255))
    end

    for i, id in pairs(order) do
        if (stats[id] and id ~= 'name') then
            local panel = vgui.Create('Panel', self.info)
            panel:SetTall(20)
            panel:Dock(TOP)
            panel:DockPadding(10, 0, 10, 0)
            panel.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, (i % 2 == 0) and Color(255, 255, 255) or Color(235, 235, 235))
            end

            local col = vgui.Create('DLabel', panel)
            col:SetWide(100)
            col:Dock(LEFT)
            col:SetText(columns[id])
            col:SetColor(Color(0,0,0))
            col:SetFont('LPS16')

            local value = vgui.Create('DLabel', panel)
            value:Dock(FILL)
            value:SetText(stats[id])
            value:SetColor(Color(0,0,0))
            value:SetFont('LPS16')
        end
    end

    self.avi = vgui.Create('AvatarMask', self.left)
    self.avi:SetSize(120, 120)
    self.avi:SetPlayer(LocalPlayer(), 184)
    self.avi:SetPos(32,32)

    self.top = vgui.Create('DLabel', self)
    self.top:SetWide(100)
    self.top:DockMargin(5, 5, 5, 5)
    self.top:Dock(TOP)
    self.top:SetText('Top Ten Players')
    self.top:SetColor(Color(0,0,0))
    self.top:SetFont('LPS24')
    self.top:SetTall(28)
    self.top.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, h-2, w, 2, Color(41, 128, 185))
    end

    self.list = vgui.Create('DListView', self)
    self.list.VBar:Remove()
    self.list.VBar = vgui.Create('LPSScrollBar', self.list)
    self.list.PerformLayout = function(self)
        -- Do Scrollbar
        local Wide = self:GetWide()
        local YPos = 0

        if (IsValid(self.VBar)) then
            self.VBar:SetPos(self:GetWide() - 6, 0)
            self.VBar:SetSize(6, self:GetTall())
            self.VBar:SetUp(self.VBar:GetTall() - self:GetHeaderHeight(), self.pnlCanvas:GetTall())
            YPos = self.VBar:GetOffset()
            if (self.VBar.Enabled) then Wide = Wide - 6 end
        end

        if (self.m_bHideHeaders) then
            self.pnlCanvas:SetPos(0, YPos)
        else
            self.pnlCanvas:SetPos(0, YPos + self:GetHeaderHeight())
        end

        self.pnlCanvas:SetSize(Wide, self.pnlCanvas:GetTall())
        self:FixColumnsLayout()

        --
        -- If the data is dirty, re-layout
        --
        if (self:GetDirty(true)) then
            self:SetDirty(false)
            local y = self:DataLayout()
            self.pnlCanvas:SetTall(y)
            -- Layout again, since stuff has changed..
            self:InvalidateLayout(true)
        end
    end

    self.list:Dock(FILL)
    self.list:DockMargin(5, 5, 5, 5)
    self.list:SetDataHeight(16)
    self.list:SetHeaderHeight(20)
    self.list.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255))
    end

    for _, id in pairs(order) do
        local col = self.list:AddColumn(columns[id])
        col.Header:SetColor(Color(255,255,255))
        col.Header.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(41, 128, 185))
        end
    end

    for _, data in pairs(top) do
        local line = self.list:AddLine()
        line.count = table.Count(self.list.Lines)
        line.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self.m_bAlt and Color(235, 235, 235) or Color(255, 255, 255))
        end

        for id, stat in pairs(data) do
            if (orderKeys[id]) then
                line:SetColumnText(orderKeys[id], stat)
            end
        end
    end

end

vgui.Register('LPSStats', PANEL, 'LPSFrame')

local playerStats
lps.net.Hook('ShowStats', function(data)
    if (IsValid(playerStats)) then
        playerStats:Remove()
    end

    playerStats = vgui.Create('LPSStats')
    playerStats:Show(data[1], data[2])
end)

--[[---------------------------------------------------------
--   Hook: IsBusy:PlayerStats
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:PlayerStats', function ()
    if (IsValid(playerStats) and playerStats:IsVisible()) then return true end
end)