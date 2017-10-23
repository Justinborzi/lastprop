surface.CreateFont('VoteMap:Countdown', {
    font = 'Tahoma',
    size = 40,
    weight = 800,
    antialias = true,
    shadow = true
})

local PANEL = {}

function PANEL:Init()

    local scale = math.Clamp(ScrW() / 1920.0, 0.5, 1.0)
    local height = ScrH() - 100

    local buttons = math.Round(ScrW() / 200 * scale)
    if buttons > 5 then
        buttons = 5
    end

    local width = buttons * (200 * scale) + buttons * 4

    self:SetSize(width, height)
    self:SetPos(0, 30)
    self:CenterHorizontal()

    self.countdown = vgui.Create('DLabel', self)
    self.countdown:SetText('')
    self.countdown:SetContentAlignment(5)
    self.countdown:SetPos(0, 0)
    self.countdown:SetSize(width, 40)
    self.countdown:SetFont('VoteMap:Countdown')
    self.countdown:SetTextColor(Color(255, 255, 255, 255))

    self.scroll = vgui.Create('DScrollPanel', self)
    self.scroll:SetSize(width, height - 50)
    self.scroll:SetPos(0, 50)

    self.maps = vgui.Create('DIconLayout', self.scroll)
    self.maps:SetSpaceY(4)
    self.maps:SetSpaceX(4)

    local w, h = self.scroll:GetSize()
    self.maps:SetSize(w, h)

    self:SetZPos(-1000)
    self:ParentToHUD()
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)

    for map, votes  in pairs(lps.mapvote.votes) do
        self.maps:Add('MapVote:Button'):Create(map)
    end

    self.openTime = SysTime()
end

function PANEL:UpdateVoters()
    for _, button in pairs(self.maps:GetChildren()) do
        button:UpdateVoters()
    end
end

function PANEL:Finish(map)
    for _, button in pairs(self.maps:GetChildren()) do
        if (button.map == map) then
            button:Blink()
        end
    end
end

function PANEL:Think()
    self.countdown:SetText(math.max(0, math.ceil(lps.mapvote.endTime - CurTime())) .. ' seconds left to vote')
end

function PANEL:Paint()
    Derma_DrawBackgroundBlur(self, self.openTime)
end

vgui.Register('MapVote:Frame', PANEL)