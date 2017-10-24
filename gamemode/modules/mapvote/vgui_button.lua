
surface.CreateFont('MapVote:MapName', {
    font = 'Tahoma',
    size = 17,
    weight = 300,
    antialias = true
})

local PANEL = {}

function PANEL:Init()
    self.voters = {}

    self:SetMouseInputEnabled(true)

    self.image = vgui.Create('DImage', self)
    self.image:SetMouseInputEnabled(true)
    self.image:DockPadding(2, 2, 2, 2)
    self.image.OnMousePressed = function()
        self:DoClick()
    end

    if (lps.mapvote.config.allowForce and LocalPlayer():IsAdmin() ) then
        self.force = vgui.Create('LPSButton', self.image)
        self.force:SetText('Force Map')
        self.force:Dock(BOTTOM)
        self.force.DoClick = function()
            lps.net.Start('Mapvote:Force', {self.map})
        end
    end

    self.votes = vgui.Create('DIconLayout', self.image)
    self.votes:Dock(FILL)
    self.votes:SetSpaceY(4)
    self.votes:SetSpaceX(4)

    self.label = vgui.Create('DLabel', self)
    self.label:SetFont('MapVote:MapName')
    self.label:SetTextColor(Color(30, 30, 30, 255))
    self.label:SetContentAlignment(5)

    self.color = Color(255, 255, 255, 180)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.color)
end

function PANEL:DoClick()
    if (IsValid(self.force) and self.force:IsHovered()) then return end
    lps.net.Start('Mapvote:Vote', {self.map})
end

function PANEL:Create(map)
    self.label:SetText(map)

    if file.Exists('maps/thumb/'..map..'.png', 'GAME') then
        self.image:SetImage('maps/thumb/'..map..'.png')
    elseif file.Exists('maps/'..map..'.png', 'GAME') then
        self.image:SetImage('maps/'..map..'.png')
    else
        self.image:SetImage('maps/thumb/noicon.png')
    end

    self.map = map

    local scale = math.Clamp(ScrW() / 1920.0, 0.5, 1.0)
    local w, h = (200 * scale), (250 * scale)
    local size = w - (2 * 4)

    self:SetSize(w, h)

    self.label:SetPos(4, size + 4)
    self.label:SetSize(size, h - (size + 4))

    self.image:SetSize(size, size)
    self.image:SetPos(4, 2 * 4)
end

function PANEL:AddVoter(id)
    if (not IsValid(Player(id))) then return end

    local scale = math.Clamp(ScrW() / 1920.0, 0.5, 1.0)
    self.voters[id] = self.votes:Add('Panel')
    self.voters[id]:SetSize(32 * scale, 32 * scale)
    self.voters[id]:DockPadding(2, 2, 2, 2)
    self.voters[id].Paint = function(self, w, h)
        util.DrawSimpleCircle(w/2, w/2, w/2, lps.mapvote:VotePower(Player(id)) > 1 and util.Rainbow(nil, nil, 180) or Color(255, 255, 255, 180))
    end

    local icon = vgui.Create('AvatarMask', self.voters[id])
    icon:Dock(FILL)
    icon:SetPlayer(Player(id))
end

function PANEL:RemoveVoter(id)
    if (not self.voters[id]) then return end
    self.voters[id]:Remove()
    self.voters[id] = nil
end

function PANEL:UpdateVoters()
    for id, icon in pairs(self.voters) do
        if (not IsValid(Player(id)) or not table.HasValue(lps.mapvote.votes[self.map], id)) then
            self:RemoveVoter(id)
        end
    end

    for _, id in pairs(lps.mapvote.votes[self.map]) do
        if (not self.voters[id]) then
            self:AddVoter(id)
        end
    end
end

function PANEL:OnRemove()
    for id, icon in pairs(self.voters) do
        self:RemoveVoter(id)
    end
end

function PANEL:Blink()
    local blinks = 0
    timer.Create('WinnerBlinkTimer', 0.3, 7, function()
        if (blinks % 2 == 0) then
            surface.PlaySound('buttons/blip1.wav')
            self.color = Color(0, 155, 200, 180)
        else
            self.color = Color(255, 255, 255, 180)
        end
        blinks = blinks + 1
    end)
end

vgui.Register('MapVote:Button', PANEL, 'DButton')
