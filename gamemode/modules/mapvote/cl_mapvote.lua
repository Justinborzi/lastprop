-- taken from 943738100 and adapted to gamemode

net.Receive("MapVote_Start", function()
    MapVote:Init() -- init client MapVote
    MapVote:CalcGUIConstants()

    local voteTime = net.ReadUInt(16)
    MapVote.voteTime = voteTime
    MapVote.voteTimeEnd = voteTime + CurTime()

    local maps = net.ReadTable()

    local gui = vgui.Create( "MapFrame" )
    gui:AddMaps(maps)
    MapVote.gui = gui

end)

net.Receive("MapVote_Stop", function()
    if MapVote.gui then
        MapVote.gui:Clear()
        MapVote.gui:SetVisible(false)
        MapVote.gui = nil
    end
end)

net.Receive("MapVote_End", function()
    MapVote.active = false
    local winner = net.ReadUInt(32)
    local button = MapVote.gui:GetButton(winner)
    button:Blink()
end)

net.Receive("MapVote_UpdateToAllClient", function()
    local ply = net.ReadEntity()
    if IsValid(ply) then
        local id = net.ReadUInt(32) -- the clicked button id
        local button = MapVote.gui:GetButton(id)

        local curButtonId = MapVote.votes[ply:UniqueID()]
        local icon = nil

        if not curButtonId then
            icon = MapVote:CreateVoterIcon(ply)
        else
            -- remove avatar icon from button if one already exists on another button
            local curButton = MapVote.gui:GetButton(curButtonId)
            icon = curButton:GetVoterIcon(ply)
            curButton:RemoveVoterIcon(ply)
        end


        button:AddVoterIcon(ply, icon)
        icon:SetParent(button)

        MapVote.votes[ply:UniqueID()] = id
    end
end)

function MapVote:CalcGUIConstants()
    -- global variables for the gui components
    local scale = ScrW() / 1920.0
    UI_SCALE_FACTOR = math.Clamp(scale, 0.5, 1.0)
    MAX_FRAME_W = 1280 * UI_SCALE_FACTOR
    MIN_FRAME_W = 200 * UI_SCALE_FACTOR
    MIN_FRAME_H = 200 * UI_SCALE_FACTOR

    SPACING = 4

    MAPBUTTON_W = 200 * UI_SCALE_FACTOR
    MAPBUTTON_H = 250 * UI_SCALE_FACTOR

    MAX_BUTTONROW = 5

    AVATAR_ICON_SIZE = 32 * UI_SCALE_FACTOR
end

function MapVote:CreateVoterIcon(ply)
    local icon_blank = vgui.Create("Panel")
    icon_blank:SetSize(AVATAR_ICON_SIZE, AVATAR_ICON_SIZE)
    icon_blank.player = ply

    local icon_holder = vgui.Create("DPanel", icon_blank)
    icon_holder:SetPos(2, 2)
    icon_holder:SetSize(AVATAR_ICON_SIZE - 4, AVATAR_ICON_SIZE - 4)

    local icon = vgui.Create("AvatarImage", icon_holder)
    icon:SetPos(1, 1)
    icon:SetSize(AVATAR_ICON_SIZE - 6, AVATAR_ICON_SIZE - 6)
    icon:SetPlayer(ply)
    icon_holder.icon = icon

    return icon_blank
end