local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:SetMouseInputEnabled(true)

    self.teamID = 0
    self.columns = {}

    self.header = vgui.Create('Panel', self)
    self.header:DockMargin(30, 10, 30, 10)
    self.header:Dock(TOP)
    self.header:SetTall(40)

    self.teamLabel = vgui.Create('DLabel', self.header)
    self.teamLabel:Dock(LEFT)
    self.teamLabel:SetColor(Color(255,255,255))
    self.teamLabel:SetFont('LPS40')
    self.teamLabel:SetContentAlignment(4)
    self.teamLabel:SizeToContents()
    self.teamLabel.Paint = function(self,w,h) end

    self.scoreLabel = vgui.Create('DLabel', self.header)
    self.scoreLabel:Dock(RIGHT)
    self.scoreLabel:SetColor(Color(255,255,255))
    self.scoreLabel:SetFont('LPS40')
    self.scoreLabel:SizeToContents()
    self.scoreLabel:SetContentAlignment(4)
    self.scoreLabel.Paint = function(self,w,h) end

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

    self.list:DockMargin(15, 0, 15, 20)
    self.list:Dock(FILL)
    self.list:SetDataHeight(32)
    self.list:SetHeaderHeight(20)
    self.list.Paint = function(self,w,h)
        draw.RoundedBox(6, 0, 0, w, h, Color(255,255,255))
    end

end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, team.GetColor(self.teamID))
end

--[[---------------------------------------------------------
--   Name: PANEL:SetTeam()
---------------------------------------------------------]]--
function PANEL:SetTeam(teamID)
    self.teamID = teamID
end

--[[---------------------------------------------------------
--   Name: PANEL:AddColumn()
---------------------------------------------------------]]--
function PANEL:AddColumn(col)

    local column = self.list:AddColumn(col.name)
    if (col.fixedSize) then column:SetMinWidth(col.fixedSize) column:SetMaxWidth(col.fixedSize) end
    if (col.headerAlign) then column.Header:SetContentAlignment(col.headerAlign) end

    col.teamColor = team.GetColor(self.teamID)
    col.teamID = self.teamID
    table.insert(self.columns, col)

    local first = table.Count(self.list.Columns) == 1
    column.Header.Paint = function(self, w, h)

        if (first) then
            draw.RoundedBox(6, 0, 0, w, h, Color(255,255,255))
            draw.RoundedBox(0, w - 6, 0, 6, h, Color(255,255,255))
        else
            draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255))
        end
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:SetSortColumns()
---------------------------------------------------------]]--
function PANEL:SetSortColumns(...)
    self.sortArgs = ...
end

--[[---------------------------------------------------------
--   Name: PANEL:FindPlayerLine()
---------------------------------------------------------]]--
function PANEL:FindPlayerLine(ply)
    for _, line in pairs(self.list.Lines) do
        if (line.player == ply) then return line end
    end

    local line = self.list:AddLine()
    line.player = ply
    line.updateTime = {}
    line.count = table.Count(self.list.Lines)

    line.Paint = function(self, w, h)
         if (self.player:Alive()) then
            draw.RoundedBox(0, 0, 0, w, h, (self.count % 2 == 0) and Color(255, 255, 255) or util.Darken(Color(255, 255, 255), 20))
        else
            draw.RoundedBox(0, 0, 0, w, h, (self.count % 2 == 0) and Color(255, 204, 204) or util.Darken(Color(255, 204, 204), 20))
        end
    end

    line.SetSelected = function(self, b) end

    return line
end

--[[---------------------------------------------------------
--   Name: PANEL:UpdateColumn()
---------------------------------------------------------]]--
function PANEL:UpdateColumn(i, col, line)

    if (!col.value) then return end

    line.updateTime[i] = line.updateTime[i] or 0

    if (col.updateRate == 0 && line.updateRate[i] != 0) then return end // 0 = only update once
    if (line.updateTime[i] > RealTime()) then return end

    line.updateTime[i] = RealTime() + col.updateRate

    local value = col.value(line.player)
    if (value == nil) then return end

    local lbl = line:SetColumnText(i, value)

    if (IsValid(lbl)) then
        if (col.valueAlign) then lbl:SetContentAlignment(col.valueAlign) end
        if (col.font) then lbl:SetFont(col.font) end
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:UpdateLine()
---------------------------------------------------------]]--
function PANEL:UpdateLine(line)
    for i, col in pairs(self.columns) do
        self:UpdateColumn(i, col, line)
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:CleanLines()
---------------------------------------------------------]]--
function PANEL:CleanLines()
    for k, line in pairs(self.list.Lines) do
        if (not IsValid(line.player) or line.player:Team() ~= self.teamID) then
            self.list:RemoveLine(k)
        end
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think()
    self.teamLabel:SetText(team.GetName(self.teamID))
    self.teamLabel:SizeToContents()

    self.scoreLabel:SetText(string.format('Wins: %s/%s', team.GetScore(self.teamID), GAMEMODE:GetConfig('round_limit')))
    self.scoreLabel:SizeToContents()

    self:CleanLines()

    local players = team.GetPlayers(self.teamID)
    for _, player in pairs(players) do
        local line = self:FindPlayerLine(player)
        self:UpdateLine(line)
    end

    if (self.sortArgs) then
        self.list:SortByColumns(unpack(self.sortArgs))
    end
end

derma.DefineControl('LPSTeamScore', '', PANEL, 'DPanel')

local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:ParentToHUD()
    self:SetMouseInputEnabled(true)
    self:SetSize(ScrW(), ScrH())

    local cx, cy =  ScrW()/2, ScrH()/2
    local localPlayer = LocalPlayer()

    self.center = vgui.Create('DPanel', self)
    self.center:SetSize(cx, cy)
    self.center:SetPos(cx/2, cy/2)
    self.center.Paint = function() end

    self.spectators = vgui.Create('DLabel', self.center)
    self.spectators:SetTall(30)
    self.spectators:Dock(BOTTOM)
    self.spectators:SetContentAlignment(5)
    self.spectators:SetColor(Color(255,255,255))
    self.spectators:SetFont('LPS14')
    self.spectators:SetText(string.format('Spectators: %s', util.SpectatorNames()))

    self.propScore = vgui.Create('LPSTeamScore', self.center)
    self.propScore:SetWide(cx/2 - 5)
    self.propScore:Dock(LEFT)
    self.propScore:SetTeam(TEAM.PROPS)

    self.hunterScore = vgui.Create('LPSTeamScore', self.center)
    self.hunterScore:SetWide(cx/2 - 5)
    self.hunterScore:Dock(RIGHT)
    self.hunterScore:SetTeam(TEAM.HUNTERS)

    self:SetVisible(true)
    self:SetKeyboardInputEnabled(false)
    self:MakePopup()
end


--[[---------------------------------------------------------
--   Name: PANEL:AddColumn()
---------------------------------------------------------]]--
function PANEL:SetSortColumns(...)
    self.propScore:SetSortColumns(...)
    self.hunterScore:SetSortColumns(...)
end

--[[---------------------------------------------------------
--   Name: PANEL:AddColumn()
---------------------------------------------------------]]--
function PANEL:AddColumn(name, fixedSize, value, updateRate, headerAlign, valueAlign)
    local column = {}

    column.name = name
    column.fixedSize = fixedSize
    column.value = value
    column.updateRate = updateRate
    column.valueAlign = valueAlign
    column.headerAlign = headerAlign

    self.propScore:AddColumn(column)
    self.hunterScore:AddColumn(column)

    return column
end


--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)

end

derma.DefineControl('LPSScoreBoard', '', PANEL, 'DPanel')

--[[---------------------------------------------------------
--   Name: GAMEMODE:GetPlayerScoreboardColor()
---------------------------------------------------------]]--
function GM:GetPlayerScoreboardColor(ply)
    if (not IsValid(ply)) then return end

    if (lps.support[ply:SteamID()]) then
         return util.Rainbow(nil, nil, 180)
    end

    return team.GetColor(ply:Team())
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardAvatar()
---------------------------------------------------------]]--
function GM:AddScoreboardAvatar(score)
    local f = function(ply)

        local panel = vgui.Create('Panel', score)
        panel:DockPadding(2, 2, 2, 2)

        local subpanel = vgui.Create('Panel', panel)
        subpanel:Dock(FILL)
        subpanel:DockPadding(2, 2, 2, 2)
        subpanel.Paint = function(self, w, h)
            util.DrawSimpleCircle(w/2, w/2, w/2, hook.Call('GetPlayerScoreboardColor', GAMEMODE, ply) or color_white)
        end

        local av = vgui.Create('AvatarMask', subpanel)
        av:Dock(FILL)
        av:SetPlayer(ply)

        return panel
    end

    score:AddColumn('', 32, f, 360)
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardSpacer()
---------------------------------------------------------]]--
function GM:AddScoreboardSpacer(score)
    score:AddColumn('', 16, nil, 360)
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardName()
---------------------------------------------------------]]--
function GM:AddScoreboardName(score)
    local f = function(ply) return ply:Name() end
    score:AddColumn('Name', nil, f, 30, 5, 4)
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardKills()
---------------------------------------------------------]]--
function GM:AddScoreboardKills(score)
    local f = function(ply) return ply:Frags() end
    score:AddColumn('Frags', 40, f, 1, 5, 5)
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardDeaths()
---------------------------------------------------------]]--
function GM:AddScoreboardDeaths(score)
    local f = function(ply) return ply:Deaths() end
    score:AddColumn('Deaths', 40, f, 1, nil, 5, 5)
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardPing()
---------------------------------------------------------]]--
function GM:AddScoreboardPing(score)
    local f = function(ply) return ply:Ping() end
    score:AddColumn('Ping', 30, f, 5, 5, 5)
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:GetPlayerScoreboardIcon()
---------------------------------------------------------]]--
function GM:GetPlayerScoreboardIcon(ply)
    if (not IsValid(ply)) then return end

    if (lps.support[ply:SteamID()]) then
        return 'icon16/color_wheel.png'
    end
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:GetPlayerScoreboardIconText()
---------------------------------------------------------]]--
function GM:GetPlayerScoreboardIconText(ply)
    if (not IsValid(ply)) then return end

    if (lps.support[ply:SteamID()]) then
        return lps.support[ply:SteamID()]
    end
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardIcon()
---------------------------------------------------------]]--
function GM:AddScoreboardIcon(score)
    local f = function(ply)

        local panel = vgui.Create('Panel', score)

        local icon = vgui.Create('LPSInfoBox', panel)
        icon:SetImage(hook.Call('GetPlayerScoreboardIcon', self, ply) or  'icon16/user.png')
        icon:SetInfo(hook.Call('GetPlayerScoreboardIconText', self, ply) or '')
        icon:SetInfoSize(120, 40)
        icon:SetPos(8, 8)
        icon:SetSize(16, 16)

        return panel
    end
    score:AddColumn('', 32, f, 360, 4, 4)
end

--[[---------------------------------------------------------
--   Name: GAMEMODE:AddScoreboardMute()
---------------------------------------------------------]]--
function GM:AddScoreboardMute(score)
    local function doMute(panel, ply)
        if (not IsValid(panel) or not IsValid(LocalPlayer()) or not IsValid(ply)) then return end
        local muted = LocalPlayer():GetVar('muted', {})
        if (muted[ply:UniqueID()]) then
            panel:SetImage('icon16/sound_none.png')
            panel:SetPos(9, 7)
        else
            panel:SetImage('icon16/sound_mute.png')
            panel:SetPos(5, 7)
        end
        RunConsoleCommand('playermute', ply:UniqueID())
    end

    local f = function(ply)

        local panel = vgui.Create('Panel', score)
        panel:DockPadding(2, 2, 2, 2)

        if (ply == LocalPlayer()) then
            return panel
        end

        local subpanel = vgui.Create('Panel', panel)
        subpanel:Dock(FILL)
        subpanel:DockPadding(2, 2, 2, 2)
        subpanel.Paint = function(self, w, h)
            util.DrawSimpleCircle(w/2, w/2, w/2, util.SetAlpha(color_white, 190))
        end

        local mute = vgui.Create('DImageButton', subpanel)
        mute:SetSize(16, 16)
        mute.DoClick = function(self)
            doMute(self, ply)
        end

        local muted = LocalPlayer():GetVar('muted', {})
        if (muted[ply:UniqueID()]) then
            mute:SetImage('icon16/sound_mute.png')
            mute:SetPos(5, 7)
        else
            mute:SetImage('icon16/sound_none.png')
            mute:SetPos(9, 7)
        end

        return panel
    end
    score:AddColumn('', 32, f, 360, 4, 4)
end

--[[---------------------------------------------------------
--   Name: GM:CreateScoreboard()
---------------------------------------------------------]]--
function GM:CreateScoreboard(scores)

    self:AddScoreboardAvatar(scores)    // 1
    self:AddScoreboardName(scores)      // 2
    self:AddScoreboardKills(scores)     // 3
    self:AddScoreboardDeaths(scores)    // 4
    self:AddScoreboardPing(scores)      // 5
    self:AddScoreboardIcon(scores)      // 6
    self:AddScoreboardMute(scores)      // 7

    scores:SetSortColumns({2, true, 3, false, 4, false, 5, false})
end

--[[---------------------------------------------------------
--   Name: GM:ScoreboardShow()
---------------------------------------------------------]]--
local scores
function GM:ScoreboardShow()
    if (IsValid(scores)) then
        scores:Remove()
    end
    scores = vgui.Create('LPSScoreBoard')
    self:CreateScoreboard(scores)
end

--[[---------------------------------------------------------
--   Name: GM:ScoreboardHide()
---------------------------------------------------------]]--
function GM:ScoreboardHide()
    if (IsValid(scores)) then
        scores:Remove()
    end
end

--[[---------------------------------------------------------
--   Hook: IsBusy:ShowTeam
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:ShowTeam', function ()
    if (IsValid(scores) and scores:IsVisible()) then return true end
end)