
--[[---------------------------------------------------------
   Include client
---------------------------------------------------------]]--
include('cl_util.lua')
include('cl_fonts.lua')
include('vgui/vgui_derma.lua')
include('vgui/vgui_hud.lua')
include('vgui/vgui_player.lua')
include('vgui/vgui_team.lua')
include('vgui/vgui_score.lua')
include('vgui/vgui_help.lua')
include('vgui/vgui_notice.lua')
include('vgui/vgui_options.lua')
include('vgui/vgui_taunt.lua')
include('cl_hud.lua')
include('cl_minigame.lua')
include('cl_player.lua')
include('cl_round.lua')
include('cl_input.lua')

--[[---------------------------------------------------------
--   Misc Convars
---------------------------------------------------------]]--
CreateClientConVar('lps_specmode', '6', true, true)         -- Spectator mode
CreateClientConVar('lps_tauntpack', 'any', true, true)      -- Taunt pack
CreateClientConVar('lps_hidehud', '0', true, true)          -- Hide HUD
CreateClientConVar('lps_glow', '1', true, true)             -- Glow/Halos
CreateClientConVar('lps_minigame', 'Snake', true, true)     -- Minigame Settings
CreateClientConVar('lps_defaultswep', 'weapon_smg1', true, true) -- Set default hunter SWEP
CreateClientConVar('lps_lastmanswep', 'weapon_lastman', true, true) -- Set lastman SWEP

--[[---------------------------------------------------------
--   3rd person view
---------------------------------------------------------]]--
CreateClientConVar('lps_tpvp', '1', true, true)         -- 3rd person view props (Bool: 0 or 1)
CreateClientConVar('lps_tpvh', '0', true, true)         -- 3rd person view hunters (Bool: 0 or 1)
CreateClientConVar('lps_tpv_dist', '50', true, true)    -- 3rd person distance (Int: 0 to 100)
CreateClientConVar('lps_tpv_offset', '15', true, true)  -- 3rd person offset (Int: 0 to 15)
CreateClientConVar('lps_tpv_offset_on', '0', true, true)--

--[[---------------------------------------------------------
--   Volume
---------------------------------------------------------]]--
CreateClientConVar('lps_vol_ui', '0.5', true, true)   -- Volume UI (Float: 0.00 to 1.00)
CreateClientConVar('lps_vol_sfx', '0.5', true, true)  -- Volume SFX (Float: 0.00 to 1.00)
CreateClientConVar('lps_vol_music', '0.5', true, true)-- Volume Music (Float: 0.00 to 1.00)

--[[---------------------------------------------------------
--   Crosshair
---------------------------------------------------------]]--
CreateClientConVar('lps_xhair_r', '255', true, true)  -- xhiar red (Int: 0 to 255)
CreateClientConVar('lps_xhair_g', '208', true, true)  -- xhiar green (Int: 0 to 255)
CreateClientConVar('lps_xhair_b', '64', true, true)   -- xhiar blue (Int: 0 to 255)
CreateClientConVar('lps_xhair_a', '255', true, true)  -- xhiar alpha (Int: 0 to 255)
CreateClientConVar('lps_xhair_l', '10', true, true)   -- xhiar length (Int: 0 to 25)

--[[---------------------------------------------------------
--   concommand: lps_reset
---------------------------------------------------------]]--
concommand.Add('lps_reset', function(ply, cmd, args, arg_str)
    hook.Call('ResetConvars', GAMEMODE)
end)

--[[---------------------------------------------------------
--   Name: GM:ResetConvars()
---------------------------------------------------------]]--
function GM:ResetConvars()
    for var, value in pairs({
        specmode = 6,
        tauntpack = 'any',
        hidehud = 0,
        glow = 1,
        minigame = 'Snake',
        defaultswep = 'weapon_smg1',
        lastmanswep = 'weapon_lastman',

        tpvp = 1,
        tpvh = 0,
        tpv_dist = 50,
        tpv_offset = 15,
        tpv_offset_on = 0,

        vol_ui = 0.5,
        vol_sfx = 0.5,
        vol_music = 0.5,

        xhair_r = 255,
        xhair_g = 208,
        xhair_b = 64,
        xhair_a = 255,
        xhair_l = 10,
    }) do
        RunConsoleCommand('lps_' .. var, value)
    end
end

--[[---------------------------------------------------------
--   Name: GM:Initialize()
---------------------------------------------------------]]--
function GM:Initialize()
    self.BaseClass:Initialize()
    self:AddShouldDraw('CHudCrosshair', false)
    self:AddShouldDraw('CHudDamageIndicator', false)
    self:AddShouldDraw('CHudDeathNotice', false)
    self:AddShouldDraw('CHudGeiger', false)
    self:AddShouldDraw('CHudHintDisplay', false)
    self:AddShouldDraw('CHudPoisonDamageIndicator', false)
    self:AddShouldDraw('CHudSquadStatus', false)
    self:AddShouldDraw('CHudTrain', false)
    self:AddShouldDraw('CHudZoom', false)
    self:AddShouldDraw('CHudVoiceStatus', false)
end

lps.net.Hook('Initialize', function(data)
    lps.banned = data[1]
    lps.support = data[2]
    lps.version = data[3]
end)

--[[---------------------------------------------------------
--   Name: GM:InitPostEntity()
---------------------------------------------------------]]--
function GM:InitPostEntity()
    if (hook.Call('ShouldShowTeam', self) and LocalPlayer():IsSpec()) then
        self:ShowTeam()
    end
end

--[[---------------------------------------------------------
--   Name: GM:Think()
---------------------------------------------------------]]--
function GM:Think()

end

--[[---------------------------------------------------------
--   Name: GM:PlayingSoundsThink()
---------------------------------------------------------]]--
function GM:PlayingSoundsThink()

    if (#self.sounds <= 0) then
        timer.Destroy('PlayingSoundsThink')
        return
    end

    local volUI, volSFX, volMusic = math.Clamp(GetConVar('lps_vol_ui'):GetFloat(), 0, 1), math.Clamp(GetConVar('lps_vol_sfx'):GetFloat(), 0, 1), math.Clamp(GetConVar('lps_vol_music'):GetFloat(), 0, 1)
    for i, data in pairs(self.sounds) do
        if (IsValid(data.sound)) then
            local vol = 0
            if (data.channel == SOUND.UI) then
                vol = volUI
            elseif (data.channel == SOUND.SFX) then
                vol = volSFX
            elseif (data.channel == SOUND.MUSIC) then
                vol = volMusic
            end

            if (vol <= 0) then
                data.sound:Stop()
                table.remove(self.sounds, i)
                return
            end

            if (data.sound:GetVolume() ~= vol)then
                data.sound:SetVolume(vol)
            end

            if (data.sound:GetState() == GMOD_CHANNEL_PLAYING) and (data.stop > 0 and data.stop <= CurTime()) then
                data.sound:Stop()
                return
            end

            if (table.HasValue({GMOD_CHANNEL_STOPPED, GMOD_CHANNEL_PAUSED}, data.sound:GetState())) then
                table.remove(self.sounds, i)
            end
        else
            table.remove(self.sounds, i)
        end
    end
end