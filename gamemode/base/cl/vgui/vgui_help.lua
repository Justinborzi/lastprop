
--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
local PANEL = {}
function PANEL:Init()
    self:SetSize(600, 400)
    self:Center()
    self:SetTitle('LPS Help')
    self:SetDraggable(true)
    self:SetSizable(true)
    self:SetDeleteOnClose(true)
    self:MakePopup()
    self:DrawFrame()
end

--[[---------------------------------------------------------
--   Name: PANEL:DrawFrame()
---------------------------------------------------------]]--
function PANEL:DrawFrame()
    local bottom = vgui.Create('DPanel', self)
    bottom:SetTall(38)
    bottom:Dock(BOTTOM)
    bottom:DockMargin(0, 0, 0, 0)
    bottom.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(149, 165, 166))
    end

    local options = vgui.Create('LPSButton', bottom)
    options:SetWide(120)
    options:Dock(RIGHT)
    options:SetText('Client Settings')
    options:DockMargin(4, 4, 4, 4)
    options.DoClick = function(button)
        RunConsoleCommand('lps_show_options')
        surface.PlaySound('ui/buttonclickrelease.wav')
        self:Remove()
    end

    local bindings = vgui.Create('LPSButton', bottom)
    bindings:SetWide(120)
    bindings:Dock(RIGHT)
    bindings:SetText('Key Bindings')
    bindings:DockMargin(4, 4, 4, 4)
    bindings.DoClick = function(button)
        RunConsoleCommand('lps_show_bindings')
        surface.PlaySound('ui/buttonclickrelease.wav')
        self:Remove()
    end

    local loading = vgui.Create('DLabel', self)
    loading:SetText('Loading...')
    loading:SetColor(Color(0,0,0))
    loading:SetFont('LPS16')
    loading:Dock(FILL)
    loading:SetContentAlignment(5)

    http.Fetch('https://raw.githubusercontent.com/gluaws/lastprop/info/info.html',
    function(body, len, headers, code)
        if (code ~= 200) then
            loading:SetText('Error Loading Info...')
            return
        end
        loading:Remove()
        local html = vgui.Create('DHTML' , self)
        html:Dock(FILL)
        html:SetScrollbars(true)
        html:SetAllowLua(true)
        html:SetHTML(body)
    end,
    function(error)
        loading:SetText('Error Loading Info...')
    end)
end

vgui.Register('LPSHelpMenu', PANEL, 'LPSFrame')


--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
local PANEL = {}
function PANEL:Init()
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer)) then
        self:Remove()
        return
    end

    self.items = {}
    self.spacers = {}
    self:SetWide(250)

    self:AddSpacer()
    self:AddBindings('global')

    if (localPlayer:Team() == TEAM.PROPS) then
        self:AddSpacer()
        self:AddBindings('prop')
    end

    if (localPlayer:Team() == TEAM.HUNTERS) then
        self:AddSpacer()
        self:AddBindings('hunter')
    end
    self:AddSpacer()

    self:SetTall(#self.items * 20 + #self.spacers * 10)

    self:SetPos(-10, (ScrH()/2) - (self:GetTall()/2))
end

--[[---------------------------------------------------------
--   Name: PANEL:AddSpacer()
---------------------------------------------------------]]--
function PANEL:AddSpacer()
    local spacer = vgui.Create('DPanel', self)
    spacer:SetTall(10)
    spacer:Dock(TOP)
    spacer:DockMargin(10, 0, 10, 0)
    spacer.Paint = function(self, w, h) end
    table.insert(self.spacers, spacer)
end

--[[---------------------------------------------------------
--   Name: PANEL:AddBindings()
---------------------------------------------------------]]--
function PANEL:AddBindings(item)
    local default, settings = lps.bindings:GetClass(item)
    for i, var in SortedPairs(default) do
        local panel = vgui.Create('DPanel', self)
        panel:SetTall(20)
        panel:Dock(TOP)
        panel:DockMargin(20, 0, 10, 0)
        panel.Paint = function(self, w, h) end

        local name = vgui.Create('DLabel', panel)
        name:SetText(var.name)
        name:SetColor(Color(0,0,0))
        name:SetFont('LPS16')
        name:SizeToContents()
        name:SetTall(20)
        name:Dock(LEFT)

        local key = vgui.Create('DLabel', panel)
        key:SetText('[' .. lps.input:KeyData(settings[i].key, settings[i].type)[4] .. ']')
        key:SetColor(Color(0,0,0))
        key:SetFont('LPS16')
        key:SizeToContents()
        key:SetTall(20)
        key:Dock(RIGHT)
        table.insert(self.items, panel)
    end
end

--[[---------------------------------------------------------
--   Name: PANEL:Paint()
---------------------------------------------------------]]--
function PANEL:Paint(w,h)
    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 200))
end

vgui.Register('LPSHintPanel', PANEL, 'Panel')


--[[---------------------------------------------------------
--   Name: concommand lps_showhelp
---------------------------------------------------------]]--
local help
concommand.Add('lps_showhelp', function(ply, cmd, args, arg_str)
    if (IsValid(help)) then
        help:Remove()
    end
    help = vgui.Create('LPSHelpMenu')
end)

--[[---------------------------------------------------------
--   Name: hook IsBusy:ShowHelp
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:ShowHelp', function ()
    if (IsValid(help) and help:IsVisible()) then return true end
end)

--[[---------------------------------------------------------
--   Name: GM:OnSpawnMenuOpen()
---------------------------------------------------------]]--
local hint
function GM:OnSpawnMenuOpen()
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer) or localPlayer:IsSpec()) then return end

    if (IsValid(hint)) then
        hint:Remove()
    end
    hint = vgui.Create('LPSHintPanel')
end

--[[---------------------------------------------------------
--   Name: GM:OnSpawnMenuClose()
---------------------------------------------------------]]--
function GM:OnSpawnMenuClose()
    if (IsValid(hint)) then
        hint:Remove()
    end
end

