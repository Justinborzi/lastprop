--[[---------------------------------------------------------
--   Name: GM:OnPreRoundStart()
---------------------------------------------------------]]--
function GM:OnPreRoundStart(num)

end
lps.net.Hook('OnPreRoundStart', function(data) hook.Call('OnPreRoundStart', GAMEMODE, data[1]) end)

--[[---------------------------------------------------------
--   Name: GM:OnRoundStart()
---------------------------------------------------------]]--
function GM:OnRoundStart(num)
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer)) then return end

    if (localPlayer:Team() == TEAM.HUNTERS) then
         self:PlaySound(lps.sounds.sfx.start_hunters , SOUND.SFX)
    end

    if (localPlayer:Team() == TEAM.PROPS) then
         self:PlaySound(lps.sounds.sfx.start_props, SOUND.SFX)
    end
end
lps.net.Hook('OnRoundStart', function(data) hook.Call('OnRoundStart', GAMEMODE, data[1]) end)

--[[---------------------------------------------------------
--   Name: GM:OnRoundLastMan()
---------------------------------------------------------]]--
local lastManNotice
function GM:OnRoundLastMan(ply)
    if (not IsValid(ply) or ply:Team() != TEAM.PROPS) then return end

    lastManNotice = vgui.Create('LPSLastManNotice')
    lastManNotice:Show(ply)
end
lps.net.Hook('OnRoundLastMan', function(data) hook.Call('OnRoundLastMan', GAMEMODE, data[1]) end)

--[[---------------------------------------------------------
--   Name: GM:OnRoundEnd()
---------------------------------------------------------]]--
function GM:OnRoundEnd(teamID, num)
    local localPlayer = LocalPlayer()
    if (not IsValid(localPlayer)) then return end
    local winner = (teamID == ROUND.TIMER) and TEAM.PROPS or teamID

    if (IsValid(lastManNotice)) then
        lastManNotice:Hide()
    end

    if (winner == localPlayer:Team()) then
        self:PlaySound(lps.sounds.sfx.victory, SOUND.SFX)
        if (localPlayer:Alive()) then RunConsoleCommand('act', 'cheer') end
    else
        self:PlaySound(lps.sounds.sfx.defeat, SOUND.SFX)
        if (localPlayer:Alive()) then RunConsoleCommand('act', 'bow') end
    end

    for _, v in pairs(player.GetAll()) do
        if (v:Team() == winner and v:Alive()) then
            local em = ParticleEmitter(v:GetPos())
            for i = 0, 50 do
                local part = em:Add('effects/spark', v:GetPos() + VectorRand() * math.random(-30, 30) + Vector(math.random(1, 10), math.random(1, 10), math.random(50, 175)))
                part:SetAirResistance(100)
                part:SetBounce(0.3)
                part:SetCollide(true)
                part:SetColor(math.random(10, 250), math.random(10, 250), math.random(10, 250), 255)
                part:SetDieTime(2)
                part:SetEndAlpha(0)
                part:SetEndSize(0)
                part:SetGravity(Vector(0, 0, -250))
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-7,7))
                part:SetStartAlpha(math.Rand(80, 250))
                part:SetStartSize(math.Rand(6, 12))
                part:SetVelocity(VectorRand() * 75)
            end
            em:Finish()
        end
    end
end
lps.net.Hook('OnRoundEnd', function(data) hook.Call('OnRoundEnd', GAMEMODE, data[1], data[2]) end)

--[[---------------------------------------------------------
--   Name: GM:OnNextRound()
---------------------------------------------------------]]--
function GM:OnNextRound(num)

end
lps.net.Hook('OnNextRound', function(data) hook.Call('OnPreRoundStart', GAMEMODE, data[1]) end)

local inPreGame, inGame, inPostGame, roundWinner = false, false, false, -1
local inPreRound, inRound, inPostRound = false, false, false
local canStartGame, canStartRound = false, false

--[[---------------------------------------------------------
--   Hook: HUDShouldUpdate:Rounds
---------------------------------------------------------]]--
hook.Add('HUDShouldUpdate', 'HUDShouldUpdate:Rounds', function(ply)
    if (GAMEMODE:InPreGame() ~= inPreGame) then return true end
    if (GAMEMODE:InGame() ~= inGame) then return true end
    if (GAMEMODE:InPostGame() ~= inPostGame) then  return true end
    if (GAMEMODE:InPreRound() ~= inPreRound) then return true end
    if (GAMEMODE:InRound() ~= inRound) then return true end
    if (GAMEMODE:InPostRound() ~= inPostRound) then return true end
    if (GAMEMODE:RoundWinner() ~= roundWinner) then return true end

    if(GAMEMODE:InPreGame()) then
        if (GAMEMODE:CanStartRound(GAMEMODE:Round()) ~= canStartGame) then return true end
    end

    if(GAMEMODE:InGame() and not GAMEMODE:InPreRound()) then
        if (GAMEMODE:CanStartGame() ~= canStartRound) then return true end
    end
end)

--[[---------------------------------------------------------
--   Hook: HUDUpdate:Rounds
---------------------------------------------------------]]--
hook.Add('HUDUpdate', 'HUDUpdate:Rounds', function(ply, hud)

    if(ply:IsObserver() and table.HasValue({OBS_MODE_DEATHCAM, OBS_MODE_FREEZECAM}, ply:GetObserverMode())) then return end

    if (GAMEMODE:InPreGame()) then
        if (not GAMEMODE:CanStartGame()) then
            local noPlayers = vgui.Create('DHudElement')
            noPlayers:SetText('WAITING FOR PLAYERS')
            noPlayers:SizeToContents()
            noPlayers:SetMargins(20, 20, 20, 20)
            hud:AddItem(noPlayers, 8)
        else
            local gameStart = vgui.Create('DHudCountdown')
            gameStart:SetValueFunction(function() return GAMEMODE:GameStartTime() end)
            gameStart:SetLabel('GAME STARTS IN')
            gameStart:SizeToContents()
            gameStart:SetMargins(20, 20, 20, 20)
            hud:AddItem(gameStart, 2)
        end
    elseif (GAMEMODE:InGame()) then
        local inPreRound, inRound, inPostRound = GAMEMODE:InPreRound(), GAMEMODE:InRound(), GAMEMODE:InPostRound()

        local winner, teamID = GAMEMODE:RoundWinner()
        if (winner ~= -1) then
            if (winner == ROUND.TIMER) then
                teamID = TEAM.PROPS
            elseif (winner ~= ROUND.DRAW) then
                teamID = winner
            end
            if (teamID) then
                local winner = vgui.Create('DHudElement')
                winner:SetText(string.upper(team.GetName(teamID)) .. ' WIN!')
                winner:SetTextColor(team.GetColor(teamID))
                winner:SizeToContents()
                winner:SetMargins(20, 150, 20, 20)
                hud:AddItem(winner, 8)
            end
        end

        if (not inPreRound and not inRound and not inPostRound and not GAMEMODE:CanStartRound(GAMEMODE:Round())) then
            local noPlayers = vgui.Create('DHudElement')
            noPlayers:SetText('WAITING FOR PLAYERS')
            noPlayers:SizeToContents()
            noPlayers:SetMargins(20, 20, 20, 20)
            hud:AddItem(noPlayers, 8)
        elseif (inPreRound) then
            local roundStart = vgui.Create('DHudCountdown')
            roundStart:SetValueFunction(function() return GAMEMODE:RoundStartTime() end)
            roundStart:SetLabel('ROUND STARTS IN')
            roundStart:SizeToContents()
            roundStart:SetMargins(20, 20, 20, 20)
            hud:AddItem(roundStart, 2)
        elseif (inRound) then
            local bar = vgui.Create('DHudBar')

            local round = vgui.Create('DHudUpdater')
            round:SetMargins(20, 20, 20, 20)
            round:SizeToContents()
            round:SetLabel('ROUND')
            round:SetValueFunction(function()
                return GAMEMODE:Round()
            end)
            bar:AddItem(round)

            local roundEnd = vgui.Create('DHudCountdown')
            roundEnd:SizeToContents()
            roundEnd:SetLabel('TIME')
            roundEnd:SetValueFunction(function()
                return GAMEMODE:RoundEndTime()
            end)
            bar:AddItem(roundEnd)

            hud:AddItem(bar, 2)
        elseif (inPostRound and (GAMEMODE:Round() + 1) < GAMEMODE:GetConfig('round_limit')) then
            local nextRound = vgui.Create('DHudCountdown')
            nextRound:SetValueFunction(function() return GAMEMODE:NextRoundTime() end)
            nextRound:SetLabel('NEXT ROUND IN')
            nextRound:SizeToContents()
            nextRound:SetMargins(20, 20, 20, 20)
            hud:AddItem(nextRound, 2)
        end
    end
end)

--[[---------------------------------------------------------
--   Hook: HUDOnUpdate:Rounds
---------------------------------------------------------]]--
hook.Add('HUDOnUpdate', 'HUDOnUpdate:Rounds', function(ply)
    inPreGame = GAMEMODE:InPreGame()
    inGame = GAMEMODE:InGame()
    inPostGame = GAMEMODE:InPostGame()
    inPreRound = GAMEMODE:InPreRound()
    inRound = GAMEMODE:InRound()
    inPostRound = GAMEMODE:InPostRound()
    roundWinner = GAMEMODE:RoundWinner()
    canStartGame = GAMEMODE:CanStartGame()
    canStartRound = GAMEMODE:CanStartRound(GAMEMODE:Round())
end)
