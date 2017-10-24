lps.mapvote = lps.mapvote or {}
lps.mapvote.active = lps.mapvote.active or false
lps.mapvote.endtime = lps.mapvote.endtime or 0
lps.mapvote.votes = lps.mapvote.votes or {}
lps.mapvote.recentMaps = lps.mapvote.recentMaps or {}
lps.mapvote.mapExtends = lps.mapvote.mapExtends or 0
lps.mapvote.rtv = lps.mapvote.rtv or {
    queued = false,
    votes = {},
}
lps.mapvote.config = lps.mapvote.config or {
    voteTime = 20,
    mapsToVote = 10,
    mapRevoteBanRounds = 4,
    mapAllowExtend = true,
    mapMaxExtends = 4,
    mapPrefixes = {'lps_', 'cs_', 'ph_', 'ttt_', 'mu_', 'rp_'},
    mapExcludes = {},
    rtvMinPlayers = 4,
    rtvPercentage = 0.6,
    rtvEnabled = true,
    allowForce = true,
}

--[[---------------------------------------------------------
--   Mapvote
---------------------------------------------------------]]--
function lps.mapvote:GetMaps()
    local maps = {}

    if (self.config.mapAllowExtend and (self.config.mapMaxExtends == 0 or self.mapExtends <= self.config.mapMaxExtends)) then
        table.insert(maps, game.GetMap())
    end

    for _, map in RandomPairs(file.Find('maps/*.bsp', 'GAME')) do

        map = map:sub(1, -5)

        if (#maps >= self.config.mapsToVote) then
            break
        end

        if (table.HasValue(maps, map)) then
            continue
        end

        if (table.HasValue(self.recentMaps, map)) then
            continue
        end

        if (table.HasValue(self.config.mapExcludes, map)) then
            continue
        end

        local hasPrefix = false
        for _, prefix in pairs(self.config.mapPrefixes) do
            if string.StartWith(map, prefix) then
                hasPrefix = true
            end
        end

        if (not hasPrefix) then
            continue
        end

        table.insert(maps, map)
    end

    return maps
end

function lps.mapvote:Start(voteTime)
    if (self.active) then return end

    self.active = true
    self.endtime = CurTime() + (voteTime or self.config.voteTime)

    for _, map in pairs(self:GetMaps()) do
        self.votes[map] = {}
    end

    lps.net.Start(nil, 'Mapvote:Create', {self.config, self.endtime, self.votes})

    timer.Create('Mapvote:Finish', (voteTime or self.config.voteTime), 1, function()
        lps.mapvote:Finish()
    end)
end

function lps.mapvote:Finish(winner)
    if (not self.active) then return end

    timer.Destroy('Mapvote:Finish')

    if (winner == nil) then
        local votes = 0
        for map, voters in pairs(self.votes) do
            local total = 0
            for _, voter in pairs(voters) do
                total = total + self:VotePower(Player(voter))
            end
            if (total > votes) then
                votes = total
                winner = map
            end
        end

        if (votes == 0) then
            winner = table.Random(table.GetKeys(self.votes))
        end
    end

    lps.net.Start(nil, 'Mapvote:Finish', {winner})

    if (winner == game.GetMap()) then
        timer.Simple(5, function()
            lps.mapvote:Cancel()
            lps.mapvote.mapExtends = lps.mapvote.mapExtends + 1
            util.Notify(nil, NOTIFY.YELLOW, 'Everyone voted to extend the map! New game starting!')
            GAMEMODE:StartGame()
        end)
        return
    end

    local recentMaps = {}
    if (#self.recentMaps + 1  > self.config.mapRevoteBanRounds) then
        for i=1, (self.config.mapRevoteBanRounds - 1) do
            recentMaps[i] = self.recentMaps[i + 1] or ''
        end
         recentMaps[self.config.mapRevoteBanRounds] = winner
    end

    lps.fs:Save('recent_maps.txt', recentMaps)

    timer.Simple(5, function()
        RunConsoleCommand('changelevel', winner)
    end)
end

function lps.mapvote:Cancel()
    if (not self.active) then return end

    self:ResetRTV()

    self.active = false
    self.endtime = 0
    self.votes = {}

    lps.net.Start(nil, 'Mapvote:Cancel', {1})
    timer.Destroy('Mapvote:Finish')
end

function lps.mapvote:VotePower(ply)
    if (not IsValid(ply)) then return 0 end
    if (ply:IsAdmin()) then return 2 end
    return 1
end

lps.net.Hook('Mapvote:Force', function(ply, data)
    if (IsValid(ply) and ply:IsAdmin()) then
        util.Notify(nil, NOTIFY.YELLOW, '%s forced mapvote to %s', ply:Nick(), data[1])
        lps.mapvote:Finish(data[1])
    end
end)

lps.net.Hook('Mapvote:Vote', function(ply, data)
    if (not lps.mapvote.votes[data[1]] or not lps.mapvote.active) then return end

    for map, voters in pairs(lps.mapvote.votes) do
        if (table.HasValue(lps.mapvote.votes[map], ply:UserID())) then
            table.RemoveByValue(lps.mapvote.votes[map], ply:UserID())
        end
    end

    table.insert(lps.mapvote.votes[data[1]], ply:UserID())

    lps.net.Start(nil, 'Mapvote:Update', {data[1], ply:UserID()})
end)

hook.Add('Initialize', 'Mapvote:Initialize', function()
    local config = lps.fs:Load('mapvote.txt')
    if (not config) then
        lps.fs:Save('mapvote.txt', lps.mapvote.config, true)
    else
        local save = false
        for id, var in pairs(lps.mapvote.config) do
            if (not config[id]) then
                save = true
            else
                lps.mapvote.config[id] = config[id]
            end
        end
        if (save) then
            lps.fs:Save('mapvote.txt', lps.mapvote.config, true)
        end
    end

    local recentMaps = lps.fs:Load('recent_maps.txt')
    if (recentMaps) then
        lps.mapvote.recentMaps = recentMaps
    end
end)

hook.Add('PlayerDisconnected', 'Mapvote:PlayerDisconnected', function(ply)
    if (not lps.mapvote.active) then return end
    lps.net.Start(nil, 'Mapvote:Update', {'disconnected', ply:UserID()})
end)


hook.Add('PlayerInitialSpawn', 'Mapvote:PlayerInitialSpawn', function(ply)
    if (not lps.mapvote.active) then return end
    lps.net.Start(ply, 'Mapvote:Create', {lps.mapvote.endtime, lps.mapvote.votes})
end)

hook.Add('OnEndGame', 'Mapvote:Start', function()
    lps.mapvote:Start()
end)

--[[---------------------------------------------------------
--   RTV
---------------------------------------------------------]]--
function lps.mapvote:RTV(ply)
    if (self.rtv.queued or not self.config.rtvEnabled) then return end

    local percentage = math.Clamp(self.config.rtvPercentage, 0, 1)
    local players = #player.GetAll()

    if (players < self.config.rtvMinPlayers) then
        util.Notify(ply, NOTIFY.RED, 'Not enough players to rtv!')
        return
    end

    local newVote = false
    if (not self.rtv.votes[ply:SteamID()]) then
        newVote = true
        self.rtv.votes[ply:SteamID()] = ply
    end

    local votes = 0
    for _, ply in pairs(self.rtv.votes) do
        if (IsValid(ply)) then
            votes = votes + 1
        end
    end

    if (votes >= math.ceil(percentage * players)) then
        if (GAMEMODE:InGame()) then
            hook.Add('CanStartRound', 'MapVote:CanStartRound', function() return false end)
            hook.Add('CanStartNextRound', 'MapVote:CanStartNextRound', function() return false end)
            hook.Add('OnRoundEnd', 'MapVote:OnRoundEnd', function() self:Start() end)

            self.rtv.queued = true
            util.Notify(nil, NOTIFY.YELLOW, 'RTV Successfull! Map vote will start at the end of the round!')
        else
            hook.Add('CanStartRound', 'MapVote:CanStartRound', function() return false end)
            hook.Add('CanStartNextRound', 'MapVote:CanStartNextRound', function() return false end)

            self.rtv.queued = true
            util.Notify(nil, NOTIFY.YELLOW, 'RTV Successfull! Map vote starting!')
            self:Start()
        end
    else
        util.Notify(nil, NOTIFY.GREEN, ply:Nick(), NOTIFY.YELLOW, string.format(' wants to start a map vote. (%i/%i) Type \'!rtv\' to cast your vote!', votes, math.ceil(percentage * players)))
    end
end

function lps.mapvote:ResetRTV()
    self.rtv.queued = false
    self.rtv.votes = {}
    hook.Remove('CanStartRound', 'MapVote:CanStartRound')
    hook.Remove('CanStartNextRound', 'MapVote:CanStartNextRound')
    hook.Remove('OnRoundEnd', 'MapVote:OnRoundEnd')
end

concommand.Add('rtv', function(ply, cmd, args)
    lps.mapvote:RTV(ply)
end)

hook.Add('PlayerSay', 'Mapvote:RTV', function(ply, text, public)
	if (string.lower(string.Trim(text)) == '!rtv') then
		lps.mapvote:RTV(ply)
        return ''
	end
end)