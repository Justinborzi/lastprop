
--[[---------------------------------------------------------
--   Name: GM:PreDrawHalos()
---------------------------------------------------------]]--
function GM:PreDrawHalos()
    if (GetConVar('lps_noglow'):GetBool()) then return end

    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer)) then return end
    localPlayer:ClassCall('PreDrawHalos')

    local lastMan = GAMEMODE:LastMan(TEAM.PROPS)
    if (IsValid(lastMan)) and (lastMan ~= LocalPlayer()) and (GAMEMODE:InRound()) then
        local disguise = lastMan:GetDisguise()
        if (IsValid(disguise)) then
            halo.Add({disguise}, util.Rainbow(), 2, 2, 1)
        else
            halo.Add({lastMan}, util.Rainbow(), 2, 2, 1)
        end
    end
end

--[[---------------------------------------------------------
--   Name: GM:HUDDrawTargetID()
---------------------------------------------------------]]--
function GM:HUDDrawTargetID()
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer)) then return end
    localPlayer:ClassCall('HUDDrawTargetID')
end

--[[---------------------------------------------------------
--   Name: ()
---------------------------------------------------------]]--
function GM:AddShouldDraw(name, shouldDraw)
    if(not self.shouldDraw) then self.shouldDraw = {} end
    self.shouldDraw[name] = shouldDraw
end

--[[---------------------------------------------------------
--   Name: GM:HUDShouldDraw()
---------------------------------------------------------]]--
function GM:HUDShouldDraw(name)
    if(not self.shouldDraw) then self.shouldDraw = {} end

    local localPlayer = LocalPlayer()
    if (IsValid(localPlayer)) then
        local shouldDraw = localPlayer:ClassCall('HUDShouldDraw', name)
        if (shouldDraw ~= nil) then
            return shouldDraw
        end
    end

    if (self.shouldDraw[name] ~= nil) then
        return self.shouldDraw[name]
    end

    return true
end

--[[---------------------------------------------------------
--   Name: GM:AddHUDItem()
---------------------------------------------------------]]--
function GM:AddHUDItem(item, pos, parent)
    if (IsValid(self.hud)) then
        self.hud:AddItem(item, pos, parent)
    end
end

--[[---------------------------------------------------------
--   Name: GM:HUDPaint()
---------------------------------------------------------]]--
function GM:HUDPaint()
    self.BaseClass:HUDPaint()

    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer)) then return end

    if (IsValid(localPlayer:GetActiveWeapon())) then
        local tr = localPlayer:GetEyeTrace()
        local pos = tr.HitPos:ToScreen()
        local fraction = math.min((tr.HitPos - tr.StartPos):Length(), 1024) / 1024
        local size = 10 + (20 * (1.0 - fraction))
        local offset = (size * 0.5)
        local offset2 = (offset - (size * 0.1)) + GetConVar('lps_xhair_l'):GetInt()

        surface.SetDrawColor(util.GetConsoleColor('lps_xhair'))
        surface.DrawLine(pos.x - offset, pos.y, pos.x - offset2, pos.y)
        surface.DrawLine(pos.x + offset, pos.y, pos.x + offset2, pos.y)
        surface.DrawLine(pos.x, pos.y - offset, pos.x, pos.y - offset2)
        surface.DrawLine(pos.x, pos.y + offset, pos.x, pos.y + offset2)
        surface.DrawLine(pos.x - 1, pos.y, pos.x + 1, pos.y)
        surface.DrawLine(pos.x, pos.y - 1, pos.x, pos.y + 1)
    end


    if (lps and lps.version and lps.version == 'dev' and not GetConVar('lps_hidehud'):GetBool()) then
        draw.DrawText('This gamemode is a development version, please report any bugs you see!', 'LPS16', 20, ScrH() - 25, util.Rainbow(), TEXT_ALIGN_LEFT)
    end

    localPlayer:ClassCall('HUDPaint')

    if (not hook.Call('HUDShouldUpdate', self, localPlayer)) then return end
    if (IsValid(self.hud)) then self.hud:Remove() end
    if (not GetConVar('lps_hidehud'):GetBool()) then
        self.hud = vgui.Create('DHudLayout')
        hook.Call('HUDUpdate', self, localPlayer, self.hud)
    end
    hook.Call('HUDOnUpdate', self, localPlayer)

end

--[[---------------------------------------------------------
--   Name: GM:HUDShouldUpdate()
---------------------------------------------------------]]--
function GM:HUDShouldUpdate()
    return false
end

--[[---------------------------------------------------------
--   hook: HUDShouldUpdate:HideHud
---------------------------------------------------------]]--
local hidehud = GetConVar('lps_hidehud'):GetBool()
hook.Add('HUDShouldUpdate', 'HUDShouldUpdate:HideHud', function(ply)
    if (hidehud ~= GetConVar('lps_hidehud'):GetBool()) then return true end
end)

--[[---------------------------------------------------------
--   hook: HUDOnUpdate:HideHud
---------------------------------------------------------]]--
hook.Add('HUDOnUpdate', 'HUDOnUpdate:HideHud', function(ply)
    hidehud = GetConVar('lps_hidehud'):GetBool()
end)