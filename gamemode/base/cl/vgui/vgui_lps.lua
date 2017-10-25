local PANEL = {}

function PANEL:Init()

    local scale = math.Clamp(ScrW() / 1920.0, 0.5, 1.0)

    self:SetSize(1024 * scale, 256 * scale )
    self:SetImage('vgui/lps/banner')
    self:SetKeepAspect(true)
    self:SetVisible(false)
    self:ParentToHUD()

    self.frame = vgui.Create('Panel', self)
    self.frame:SetSize(300 * scale, 256 * scale)
    self.frame:Dock(LEFT)

    self.avi = vgui.Create('AvatarMask', self.frame)
    self.avi:SetSize(150 * scale, 150 * scale)
    self.avi:SetPos((self.frame:GetWide()/2) - 75 * scale, (self.frame:GetTall()/2) - 75 * scale)

    self.label = vgui.Create('DLabel', self)
    self.label:SetFont('LPSNotice')
    self.label:SetContentAlignment(5)
    self.label:DockMargin(0, 50 * scale, 0, 0)
    self.label:Dock(FILL)

    self.speed = 0.3
    self.delay = 0
    self.ease = 1.1
    self.expire = 10
end

function PANEL:Show(ply)
    if (not IsValid(ply)) then return end

    self.avi:SetPlayer(ply, 184)

    GAMEMODE:PlaySound('lps/sounds/sfx/lps.mp3', SOUND.SFX)

    local str
    if (ply:IsBot()) then
        str = 'A bot'
    elseif (ply == LocalPlayer()) then
        str = 'You!'
    else
        str = ply:Nick()
    end
    self.label:SetText(string.upper(str))
    self.label:SizeToContents()

    local w, h = self:GetWide(), self:GetTall()

    self:SetPos((ScrW()/2)- (w/2), -h)
    self:SetVisible(true)
    self:MoveTo((ScrW()/2)- (w/2), 0, self.speed, self.delay, self.ease)

    timer.Simple(self.expire, function()
        if (IsValid(self)) then
            self:Hide()
        end
    end)
end

function PANEL:Hide()
    self:MoveTo((ScrW()/2)- (self:GetWide()/2), -self:GetTall(), self.speed, self.delay, self.ease)
    timer.Simple(self.speed + self.delay + self.ease, function()
        self:Remove()
    end)
end

function PANEL:Think()
    if (self:IsVisible()) then
        self.label:SetColor(util.Rainbow())
    end
end

derma.DefineControl('LPSLastManNotice', '', PANEL, 'DImage')