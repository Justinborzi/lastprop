function GM:RegisterMinigame(name)
    if (not table.HasValue(lps.minigames, name)) then
        table.insert(lps.minigames, name)
    end
end

local drawing = false
hook.Add('HUDPaint', 'HUDPaintMinigame', function()
    local localPlayer = LocalPlayer()
    local minigame = GetConVar('lps_minigame'):GetString()

    if (not IsValid(localPlayer) or not localPlayer:GetVar('blinded') or minigame == 'none' or not table.HasValue(lps.minigames, minigame)) then
        if (drawing == true) then
            hook.Call('MinigameEndDraw', GAMEMODE, localPlayer, minigame)
            drawing = false
        end
        return
    end

    if (drawing == false) then
        hook.Call('MinigameStartDraw', GAMEMODE, localPlayer, minigame)
        drawing = true
    end

    hook.Call('MinigameDraw', GAMEMODE, localPlayer, minigame)
end)

function GM:MinigameStartDraw(ply, minigame)
    return
end

function GM:MinigameDraw(ply, minigame)
    return
end

function GM:MinigameEndDraw(ply, minigame)
    return
end
