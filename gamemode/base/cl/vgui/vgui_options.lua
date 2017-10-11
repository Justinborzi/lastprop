
local PANEL = {}

--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:SetSize(400, 500)
    self:Center()
    self:SetTitle('LPS Key Bindings')
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

    local bindings = {
        {
            name = 'Global Keybinds',
            class = 'global'
        },
        {
            name = 'Hunter Keybinds',
            class = 'hunter'
        },
        {
            name = 'Prop Keybinds',
            class = 'prop'
        },
    }


    local scroll = vgui.Create('LPSScroll', self)
    scroll:Dock(FILL)
    scroll:DockMargin(0, 10, 0, 0)
    scroll.Paint = function() end

    for _, data in pairs(bindings) do
        local category = vgui.Create('DCollapsibleCategory', scroll)
        category:Dock(TOP)
        category:DockMargin(4, 0, 4, 3)
        category:SetExpanded(0)
        category:SetLabel(data.name)
        category.Header:SetFont('LPS16')
        category.Header:SetColor(Color(236, 240, 241))
        category.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(41, 128, 185))
        end

        local categoryPanel = vgui.Create('DPanel')
        categoryPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
        end
        category:SetContents(categoryPanel)

        local default, settings = lps.bindings:GetClass(data.class)

        for i, key in SortedPairs(default) do

            local panel = vgui.Create('DPanel', categoryPanel)
            panel:SetTall(28)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 0)
            panel.Paint = function(self, w, h) end

            local info = vgui.Create('LPSInfoButton', panel)
            info:SetSize(16,16)
            info:SetInfo(key.desc)
            info:DockMargin(4, 6, 4, 6)
            info:Dock(LEFT)

            local name = vgui.Create('DLabel', panel)
            name:SetText(key.name)
            name:SetColor(Color(0,0,0))
            name:SetFont('LPS16')
            name:SetContentAlignment(6)
            name:DockMargin(4, 4, 4, 4)
            name:SizeToContents()
            name:Dock(LEFT)

            local set
            local reset = vgui.Create('LPSButton', panel)
            reset:SetWide(20)
            reset:Dock(RIGHT)
            reset:DockMargin(4, 4, 4, 4)
            reset:SetText('R')
            reset.DoClick = function(button)
                lps.bindings:ResetKey(data.class, i)
                set:SetText('[' .. lps.input:KeyData(settings[i].key, settings[i].type)[4] .. ']')
                surface.PlaySound('ui/buttonclickrelease.wav')
            end

            set = vgui.Create('LPSButton', panel)
            set:SetWide(90)
            set:Dock(RIGHT)
            set:DockMargin(4, 4, 4, 4)
            set:SetText('[' .. lps.input:KeyData(settings[i].key, settings[i].type)[4]  .. ']')
            set.DoClick = function(button)
                button:SetText('[..]')
                timer.Simple(.1, function()
                    hook.Add('KeyDown', 'BindingsInput', function(key, keycode, char, keytype, busy, cursor)
                        if (key == KEY_ESCAPE and keytype == INPUT.KEY) then
                            gui.HideGameUI()
                            button:SetText('[' .. lps.input:KeyData(settings[i].key, settings[i].type)[4]  .. ']')
                            surface.PlaySound('ui/buttonclick.wav')
                            hook.Remove('KeyDown', 'BindingsInput')
                        else
                            lps.bindings:SetKey(data.class, i, key, keytype)
                            button:SetText('[' .. lps.input:KeyData(key, keytype)[4]  .. ']')
                            hook.Remove('KeyDown', 'BindingsInput')
                            surface.PlaySound('ui/buttonclickrelease.wav')
                        end
                    end)
                end)
            end
        end
    end
end

vgui.Register('LPSBindingsMenu', PANEL, 'LPSFrame')


local PANEL = {}
--[[---------------------------------------------------------
--   Name: PANEL:Init()
---------------------------------------------------------]]--
function PANEL:Init()
    self:SetSize(300, 400)
    self:Center()
    self:SetTitle('LPS Client Options')
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
    local settings = {
        taunt = {
            name = 'Taunt Settings',
            settings = {
                {
                    convar = 'lps_tauntpack',
                    type = 'list',
                    name = 'Taunt Pack',
                    func = function()
                        return lps.taunts.packs
                    end
                },
            }
        },
        loadout = {
            name = 'Loadout Settings',
            settings = {
                {
                    convar = 'lps_defaultswep',
                    type = 'list',
                    name = 'Hunter Default Weapon',
                    func = function()
                        return table.GetKeys(GAMEMODE:GetLoadout(LocalPlayer(), TEAM.HUNTERS))
                    end
                },
                {
                    convar = 'lps_lastmanswep',
                    type = 'list',
                    name = 'Last Prop Weapon',
                    func = function()
                        return table.GetKeys(GAMEMODE:GetLoadout(LocalPlayer(), TEAM.PROPS))
                    end
                },
            }
        },
        volume = {
            name = 'Volume Settings',
            settings = {
                {
                    convar = 'lps_vol_ui',
                    type = 'float',
                    name = 'UI Volume',
                    max = 1,
                    min = 0
                },
                {
                    convar = 'lps_vol_sfx',
                    type = 'float',
                    name = 'SFX Volume',
                    max = 1,
                    min = 0
                },
                {
                    convar = 'lps_vol_music',
                    type = 'float',
                    name = 'Music Volume',
                    max = 1,
                    min = 0
                },
            }
        },
        tpv = {
            name = '3rd Person Settings',
            settings = {
                {
                    convar = 'lps_tpvh',
                    type = 'bool',
                    name = 'Hunter 3rd Person Enabled',
                },
                {
                    convar = 'lps_tpvp',
                    type = 'bool',
                    name = 'Prop 3rd Person Enabled',
                },
                {
                    convar = 'lps_tpv_dist',
                    type = 'int',
                    name = 'View Distance',
                    max = 100,
                    min = 0
                },
                {
                    convar = 'lps_tpv_offset_on',
                    type = 'int',
                    name = 'Shoulder View Enabled',
                    type = 'bool',
                },
                {
                    convar = 'lps_tpv_offset',
                    type = 'int',
                    name = 'Shoulder Offset',
                    max = 15,
                    min = 0
                },
            }
        },
        xhair = {
            name = 'Crosshair Settings',
            settings = {
                {
                    convar = 'lps_xhair',
                    type = 'color',
                    name = 'Color',
                },
                {
                    convar = 'lps_xhair_l',
                    type = 'int',
                    name = 'Crosshair Length',
                    max = 15,
                    min = 5
                },
            }
        },
        minigames = {
            name = 'Minigame Settings',
            settings = {
                {
                    convar = 'lps_minigame',
                    type = 'list',
                    name = 'Minigame',
                    func = function()
                        return lps.minigames
                    end
                },
            }
        },
        visuals = {
            name = 'Visuals Settings',
            settings = {
                {
                    convar = 'lps_noglow',
                    type = 'bool',
                    name = 'Disable Glow',
                },
                {
                    convar = 'lps_hidehud',
                    type = 'bool',
                    name = 'Hide HUD',
                },
            }
        },
    }

    settings = table.Merge(settings, hook.Call('GetGameOptions', GAMEMODE, settings))

    local bottom = vgui.Create('DPanel', self)
    bottom:SetTall(38)
    bottom:Dock(BOTTOM)
    bottom:DockMargin(0, 0, 0, 0)
    bottom.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(149, 165, 166))
    end

    local reset = vgui.Create('LPSButton', bottom)
    reset:SetWide(120)
    reset:Dock(LEFT)
    reset:SetText('Reset')
    reset:DockMargin(4, 4, 4, 4)
    reset.DoClick = function(button)
        RunConsoleCommand('lps_reset')
        surface.PlaySound('ui/buttonclickrelease.wav')
        self:Remove()
    end

    local scroll = vgui.Create('LPSScroll', self)
    scroll:Dock(FILL)
    scroll:DockMargin(0, 10, 0, 0)
    scroll.Paint = function() end

    for _, data in pairs(settings) do
        local category = vgui.Create('DCollapsibleCategory', scroll)
        category:Dock(TOP)
        category:DockMargin(4, 0, 4, 3)
        category:SetExpanded(0)
        category:SetLabel(data.name)
        category.Header:SetFont('LPS16')
        category.Header:SetColor(Color(236, 240, 241))
        category.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(41, 128, 185))
        end

        local categoryPanel = vgui.Create('DPanel')
        categoryPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
        end
        category:SetContents(categoryPanel)

        for _, var in pairs(data.settings) do

            local panel = vgui.Create('DPanel', categoryPanel)
            panel:SetTall(28)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 0)
            panel.Paint = function(self, w, h) end

            if (var.type == 'bool') then
                local lblName = vgui.Create('DLabel', panel)
                lblName:SetText(var.name)
                lblName:SetColor(Color(0,0,0))
                lblName:SetFont('LPS16')
                lblName:SetContentAlignment(6)
                lblName:DockMargin(4, 4, 4, 4)
                lblName:SizeToContents()
                lblName:Dock(LEFT)

                local bool = vgui.Create('DCheckBoxLabel', panel)
                bool:Dock(LEFT)
                bool:SetText('')
                bool:SetConVar(var.convar)
                bool:SetValue(GetConVar(var.convar):GetInt())
                bool:SizeToContents()
            end
            if (var.type == 'float') then
                local slider = vgui.Create('DNumSlider', panel)
                slider.Label:SetFont('LPS16')
                slider.Label:SetColor(Color(0, 0, 0))
                slider:Dock(FILL)
                slider:DockMargin(5, 0, 5, 0)
                slider:SetText(var.name)
                slider:SetMin(var.min)
                slider:SetMax(var.max)
                slider:SetDecimals(1)
                slider:SetValue(GetConVar(var.convar):GetFloat())
                slider:SetConVar(var.convar)
            end
            if (var.type == 'int') then
                local slider = vgui.Create('DNumSlider', panel)
                slider.Label:SetFont('LPS16')
                slider.Label:SetColor(Color(0, 0, 0))
                slider:Dock(FILL)
                slider:DockMargin(5, 0, 5, 0)
                slider:SetText(var.name)
                slider:SetMin(var.min)
                slider:SetMax(var.max)
                slider:SetDecimals(0)
                slider:SetValue(GetConVar(var.convar):GetInt())
                slider:SetConVar(var.convar)
            end
            if (var.type == 'list') then
                local list = vgui.Create('DListView', panel)
                list:Dock(FILL)
                list:SetMultiSelect(false)
                list:AddColumn(var.name)

                for i, line in pairs(var.func()) do
                    list:AddLine(line)
                    if (line == GetConVar(var.convar):GetString()) then
                        list:SelectItem(list:GetLine(i))
                    end
                end
                panel:SetTall(100)

                list.OnRowSelected = function(lst, index, pnl)
                    RunConsoleCommand(var.convar, pnl:GetColumnText(1))
                end
            end
            if (var.type == 'color') then
                local mixer = vgui.Create('DColorMixer', panel)
                mixer:Dock(FILL)
                mixer:DockMargin(5, 5, 5, 5)
                mixer:SetAlphaBar(false)
                mixer:SetPalette(true)
                mixer:SetWangs(true)
                mixer:SetColor(util.GetConsoleColor(var.convar))
                mixer.Think = function()
                    if(util.GetConsoleColor(var.convar) ~= mixer:GetColor()) then
                        util.SetConsoleColor(var.convar, mixer:GetColor())
                    end
                end
                panel:SetTall(200)
            end
        end
    end
end

vgui.Register('LPSOptionsMenu', PANEL, 'LPSFrame')

--[[---------------------------------------------------------
--   Name: GM:PlayingSoundsThink()
---------------------------------------------------------]]--
function GM:GetGameOptions(options)
    return options
end

--[[---------------------------------------------------------
--   concommand: lps_show_options
---------------------------------------------------------]]--
local options
concommand.Add('lps_show_options', function(ply, cmd, args, arg_str)
    if (IsValid(options)) then
        options:Remove()
    end
    options = vgui.Create('LPSOptionsMenu')
end)

--[[---------------------------------------------------------
--   Hook: IsBusy:ShowOptions
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:ShowOptions', function ()
    if (IsValid(options) and options:IsVisible()) then return true end
end)

--[[---------------------------------------------------------
--   concommand: lps_show_bindings
---------------------------------------------------------]]--
local bindings
concommand.Add('lps_show_bindings', function(ply, cmd, args, arg_str)
    if (IsValid(bindings)) then
        bindings:Remove()
    end
    bindings = vgui.Create('LPSBindingsMenu')
end)

--[[---------------------------------------------------------
--   hook: IsBusy:ShowBindings
---------------------------------------------------------]]--
hook.Add('IsBusy', 'IsBusy:ShowBindings', function ()
    if (IsValid(bindings) and bindings:IsVisible()) then return true end
end)