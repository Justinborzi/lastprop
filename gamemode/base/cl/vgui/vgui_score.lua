local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:SetMouseInputEnabled(true)

    self.teamID = 0

    self.label = vgui.Create('DLabel', self)
    self.label:DockMargin(30, 10, 30, 10)
    self.label:Dock(TOP)
    self.label:SetTall(40)
    self.label:SetColor(Color(255,255,255))
    self.label:SetFont('LPS40')
    self.label:SetText(string.format('%s %s/%s', team.GetName(self.teamID), team.GetScore(self.teamID), GAMEMODE:GetConfig('round_limit')))
    self.label:SetContentAlignment(4)
    self.label.Paint = function(self,w,h) end
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
    self:CreateScores()
end

--[[---------------------------------------------------------
--   Name: PANEL:CreateScores()
---------------------------------------------------------]]--
function PANEL:CreateScores()

    self.label:SetText(string.format('%s %s/%s', team.GetName(self.teamID), team.GetScore(self.teamID), GAMEMODE:GetConfig('round_limit')))

    if (IsValid(self.scroll)) then
        self.scroll:Remove()
    end

    self.scroll = vgui.Create('LPSScroll', self)
    self.scroll:DockMargin(15, 0, 15, 20)
    self.scroll:Dock(FILL)
    self.scroll.Paint = function(self,w,h)
        draw.RoundedBox(8, 0, 0, w, h, Color(255,255,255))
    end

    local panel = vgui.Create('DPanel', self.scroll)
    panel:Dock(TOP)
    panel.Paint = function(self,w,h) end

    local name = vgui.Create('DLabel', panel)
    name:DockMargin(15, 0, 15, 0)
    name:SetColor(Color(0,0,0))
    name:SetText('Player:')
    name:Dock(LEFT)

    local mute = vgui.Create('DLabel', panel)
    mute:SetColor(Color(0,0,0))
    mute:SetContentAlignment(5)
    mute:SetWide(40)
    mute:SetText('Mute:')
    mute:Dock(RIGHT)

    local ping = vgui.Create('DLabel', panel)
    ping:SetColor(Color(0,0,0))
    ping:SetContentAlignment(5)
    ping:SetWide(40)
    ping:SetText('Ping:')
    ping:Dock(RIGHT)

    local frags = vgui.Create('DLabel', panel)
    frags:SetColor(Color(0,0,0))
    frags:SetContentAlignment(5)
    frags:SetWide(40)
    frags:SetText('Frags:')
    frags:Dock(RIGHT)

    for i, v in pairs(team.GetPlayers(self.teamID)) do

        if (not IsValid(v)) then continue end

        local panel = vgui.Create('DPanel', self.scroll)
        panel.player = v
        panel:Dock(TOP)
        panel:DockPadding(5, 2, 5, 2)
        panel.Paint = function(panel,w,h)
            if (not IsValid(v)) then return end
            if (v:Alive()) then
                draw.RoundedBox(0, 0, 0, w, h, (i % 2 == 0) and Color(255, 255, 255) or util.Darken(Color(255, 255, 255), 20))
            else
                draw.RoundedBox(0, 0, 0, w, h, (i % 2 == 0) and Color(255, 204, 204) or util.Darken(Color(255, 204, 204), 20))
            end

            if (IsValid(panel.player)) then
                if (v:IsAdmin() or v:IsSuperAdmin()) then
                    panel.info:SetColor(Color(47, 119, 88))
                elseif (lps.support[panel.player:SteamID()]) then
                    panel.info:SetColor(util.Rainbow())
                end
            else
                panel:Remove()
            end
        end

        panel.icon = vgui.Create('AvatarImage', panel)
        panel.icon:DockMargin(5, 0, 5, 0)
        panel.icon:SetPlayer(v, 32)
        panel.icon:SetSize(20, 20)
        panel.icon:Dock(LEFT)

        panel.name = vgui.Create('DLabel', panel)
        panel.name:DockMargin(0, 0, 5, 0)
        panel.name:SetColor(Color(0,0,0))
        panel.name:SetText(v:Nick())
        panel.name:SizeToContents()
        panel.name:Dock(LEFT)

        panel.info = vgui.Create('DLabel', panel)
        panel.info:SetColor(Color(0,0,0))
        if (v:IsAdmin() or v:IsSuperAdmin()) then
            panel.info:SetText('[Admin]')
        elseif (lps.support[v:SteamID()]) then
            panel.info:SetText(lps.support[v:SteamID()])
        else
            panel.info:SetText('')
        end
        panel.info:SizeToContents()
        panel.info:Dock(LEFT)

        panel.mute = vgui.Create('DImageButton', panel)
        panel.mute:SetImage('icon16/sound_none.png')
        panel.mute:SetKeepAspect(true)
        panel.mute:DockMargin(10, 0, 10, 0)
        panel.mute:SetSize(16, 16)
        panel.mute:SetContentAlignment(5)
        panel.mute:Dock(RIGHT)
        panel.mute.DoClick = function()
            if (not IsValid(v)) then return end
            local muted = LocalPlayer():GetVar('muted', {})
            if(muted[v:UniqueID()]) then
                panel.mute:SetImage('icon16/sound_none.png')
            else
                panel.mute:SetImage('icon16/sound_mute.png')
            end
            RunConsoleCommand('playermute', v:UniqueID())
        end

        local muted = LocalPlayer():GetVar('muted', {})
        if(muted[v:UniqueID()]) then
            panel.mute:SetImage('icon16/sound_mute.png')
        else
            panel.mute:SetImage('icon16/sound_none.png')
        end

        panel.ping = vgui.Create('DLabel', panel)
        panel.ping:SetWide(40)
        panel.ping:SetContentAlignment(5)
        panel.ping:SetColor(Color(0,0,0))
        panel.ping:SetText(v:Ping())
        panel.ping:Dock(RIGHT)

        panel.frags = vgui.Create('DLabel', panel)
        panel.frags:SetWide(40)
        panel.frags:SetContentAlignment(5)
        panel.frags:SetColor(Color(0,0,0))
        panel.frags:SetText(v:Frags())
        panel.frags:Dock(RIGHT)
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:Think()
---------------------------------------------------------]]--
function PANEL:Think()

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

    self.propScore = vgui.Create('LPSTeamScore', self.center)
    self.propScore:SetWide(cx/2 - 5)
    self.propScore:Dock(LEFT)
    self.propScore:SetTeam(TEAM.PROPS)

    self.hunterScore = vgui.Create('LPSTeamScore', self.center)
    self.hunterScore:SetWide(cx/2 - 5)
    self.hunterScore:Dock(RIGHT)
    self.hunterScore:SetTeam(TEAM.HUNTERS)

    self.propScore:CreateScores()
    self.hunterScore:CreateScores()
    self:SetVisible(true)
    self:SetKeyboardInputEnabled(false)
    self:MakePopup()
end


--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w, h)
end

derma.DefineControl('LPSScoreBoard', '', PANEL, 'DPanel')

--[[---------------------------------------------------------
--   Name: GM:ScoreboardShow()
---------------------------------------------------------]]--
local scoreBoard
function GM:ScoreboardShow()
    if (IsValid(scoreBoard)) then
        scoreBoard:Remove()
    end
    scoreBoard = vgui.Create('LPSScoreBoard')
end

--[[---------------------------------------------------------
--   Name: GM:ScoreboardHide()
---------------------------------------------------------]]--
function GM:ScoreboardHide()
    if (IsValid(scoreBoard)) then
        scoreBoard:Remove()
    end
end

--[[---------------------------------------------------------
--   Hook: IsBusy:ShowTeam
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:ShowTeam', function ()
    if (IsValid(scoreBoard) and scoreBoard:IsVisible()) then return true end
end)