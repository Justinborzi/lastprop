-- taken from 943738100 and adapted to gamemode

-- this are the base mapvote stuff for client and server

MapVote = MapVote or {}

function MapVote:Init()
    self.votes = {}
    self.active = true

    if SERVER then
        self.runs = true
        self.maps = self:GetRandomMaps()
    end
end

