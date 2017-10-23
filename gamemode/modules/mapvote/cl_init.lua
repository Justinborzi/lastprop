lps.mapvote = lps.mapvote or {}
lps.mapvote.vgui = lps.mapvote.vgui or nil
lps.mapvote.endTime = lps.mapvote.endTime or 0
lps.mapvote.votes = lps.mapvote.votes or {}

lps.net.Hook('Mapvote:Create', function(data)
    lps.mapvote.endTime = data[1]
    lps.mapvote.votes = data[2]

    if (not lps.mapvote.vgui) then
        lps.mapvote.vgui = vgui.Create('MapVote:Frame')
    else
        lps.mapvote.vgui:UpdateVoters()
    end
end)

lps.net.Hook('Mapvote:Update', function(data)
    if (not lps.mapvote.votes[data[1]] or not lps.mapvote.vgui) then return end

    for map, voters in pairs(lps.mapvote.votes) do
        if (table.HasValue(lps.mapvote.votes[map], data[2])) then
            table.RemoveByValue(lps.mapvote.votes[map], data[2])
        end
    end

    table.insert(lps.mapvote.votes[data[1]], data[2])

    lps.mapvote.vgui:UpdateVoters()
end)

lps.net.Hook('Mapvote:Finish', function(data)
    if (lps.mapvote.vgui) then
        lps.mapvote.vgui:Finish(data[1])
    end
end)

lps.net.Hook('Mapvote:Cancel', function(data)
    lps.mapvote.votes = {}
    lps.mapvote.endtime = 0
    if (lps.mapvote.vgui) then
        lps.mapvote.vgui:Remove()
        lps.mapvote.vgui = nil
    end
end)

