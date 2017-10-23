lps.mapvote = lps.mapvote or {}

function lps.mapvote:VotePower(ply)
    if (not IsValid(ply)) then return 0 end
    if (ply:IsSuperAdmin()) then return 3 end
    if (ply:IsAdmin()) then return 2 end
    return 1
end
