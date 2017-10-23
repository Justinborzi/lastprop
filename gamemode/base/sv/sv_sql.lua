--[[---------------------------------------------------------
--   THIS IS A WIP, FOR NOW IT JUST LOGS TO SQL
--   THERE IS NO VGUI FOR THIS FEATURE!
---------------------------------------------------------]]--

GM.db = GM.db or {}
GM.db.enabled    = GM.db.enabled    or true
GM.db.prefix     = GM.db.prefix     or 'lps_'
GM.db.username   = GM.db.username   or 'root'
GM.db.password   = GM.db.password   or ''
GM.db.database   = GM.db.database   or 'lps'
GM.db.host       = GM.db.host       or '127.0.0.1'
GM.db.unixsocket = GM.db.unixsocket or ''
GM.db.module     = GM.db.module     or 'sqlite'

--[[---------------------------------------------------------
--   Name: GM:DBInitialize()
---------------------------------------------------------]]--
function GM:DBInitialize()
    if (self.db.enabled) then
        lps.sql:SetModule(self.db.module)
        lps.sql:SetPrefix(self.db.prefix)
        lps.Info('Database prefix set to \'%s\' and module set to \'%s\'.', self.db.prefix, self.db.module)
        lps.sql:Connect(self.db.host, self.db.username, self.db.password, self.db.database, self.db.port, self.db.unixsocket)
    else
        lps.Warning('Unable to find database.cfg, your stats will not be saved!')
    end
end

--[[---------------------------------------------------------
--   Name: GM:DBConnected()
---------------------------------------------------------]]--
function GM:DBConnected()
    lps.Info('Successfully connected to database!.')
    local queryObj = lps.sql:Create('stats')
    queryObj:Create('steam_id', 'VARCHAR(25) NOT NULL')
    queryObj:Create('name', 'VARCHAR(255) NOT NULL')
    queryObj:Create('losses', 'INT NOT NULL')
    queryObj:Create('wins', 'INT NOT NULL')
    queryObj:Create('prop_kills', 'INT NOT NULL')
    queryObj:Create('hunter_kills', 'INT NOT NULL')
    queryObj:Create('lastman_kills', 'INT NOT NULL')
    queryObj:Create('suicides', 'INT NOT NULL')
    queryObj:Create('deaths', 'INT NOT NULL')
    queryObj:PrimaryKey('steam_id')
	queryObj:Execute()
end

--[[---------------------------------------------------------
--   Name: GM:DBFailed()
---------------------------------------------------------]]--
function GM:DBFailed(error)
    lps.Warning('Unable to connect to the database! Check your database.cfg! Your stats will not be saved! %s', error)
end

--[[---------------------------------------------------------
--   Name: GM:DBError()
---------------------------------------------------------]]--
function GM:DBError(error)
    lps.Error(error)
end

--[[---------------------------------------------------------
--   Hook: DB:PlayerInitialSpawn
---------------------------------------------------------]]--
hook.Add('PlayerInitialSpawn', 'DB:PlayerInitialSpawn', function(ply)
    if (not lps.sql:IsConnected() or not IsValid(ply) or ply:IsBot()) then return end

    local queryObj = lps.sql:Select('stats')
    queryObj:Where('steam_id', ply:SteamID())
    queryObj:Callback(function(result, status, lastID)
        if (type(result) == 'table' and #result > 0) then
            local updateObj = lps.sql:Update('stats')
            updateObj:Update('name', ply:Name())
            updateObj:Where('steam_id', ply:SteamID())
            updateObj:Execute()
        else
            local insertObj = lps.sql:Insert('stats')
            insertObj:Insert('name', ply:Name())
            insertObj:Insert('steam_id', ply:SteamID())
            insertObj:Insert('losses', 0)
            insertObj:Insert('wins', 0)
            insertObj:Insert('prop_kills', 0)
            insertObj:Insert('hunter_kills', 0)
            insertObj:Insert('lastman_kills', 0)
            insertObj:Insert('suicides', 0)
            insertObj:Insert('deaths', 0)
            insertObj:Execute()
        end
    end)
    queryObj:Execute()
end)

--[[---------------------------------------------------------
--   Hook: DB:PlayerDeath
---------------------------------------------------------]]--
hook.Add('PlayerDeath', 'DB:PlayerDeath', function(victim, inflictor, attacker)
    if (not lps.sql:IsConnected()) then return end

    if (GAMEMODE:InRound()) then
        if (IsValid(victim) and victim:IsPlayer() and not victim:IsBot() and not victim:IsSpec()) then
            local queryObj = lps.sql:Select('stats')
            queryObj:Where('steam_id', victim:SteamID())
            queryObj:Callback(function(result, status, lastID)
                if (type(result) == 'table' and #result > 0) then
                    local updateObj = lps.sql:Update('stats')
                    updateObj:Update('name', victim:Name())
                    updateObj:Update('deaths', result[1].deaths + 1)
                    updateObj:Where('steam_id', victim:SteamID())
                    updateObj:Execute()
                end
		    end)
            queryObj:Execute()
        end

        if (IsValid(attacker) and attacker:IsPlayer() and not attacker:IsBot() and not attacker:IsSpec()) then
            local col = ''
            if (victim == attacker) then
                col = 'suicides'
            elseif (victim:Team() == TEAM.PROPS) then
                if (victim:IsLastMan()) then
                    col ='lastman_kills'
                else
                    col ='prop_kills'
                end
            elseif (victim:Team() == TEAM.HUNTERS) then
                col ='hunter_kills'
            end

            local queryObj = lps.sql:Select('stats')
            queryObj:Where('steam_id', attacker:SteamID())
            queryObj:Callback(function(result, status, lastID)
                if (type(result) == 'table' and #result > 0) then
                    local updateObj = lps.sql:Update('stats')
                    updateObj:Update('name', attacker:Name())
                    updateObj:Update(col, result[1][col] + 1)
                    updateObj:Where('steam_id', attacker:SteamID())
                    updateObj:Execute()
                end
		    end)
            queryObj:Execute()
        end
    end
end)

--[[---------------------------------------------------------
--   Hook: DB:OnRoundEnd
---------------------------------------------------------]]--
hook.Add('OnRoundEnd', 'DB:OnRoundEnd', function(teamID, num)
    if (not lps.sql:IsConnected()) then return end

    for _, v in pairs(player.GetAll()) do
        if (not IsValid(v) or v:IsBot()) then continue end

        local col
        if (teamID == ROUND.TIMER and v:Team() == TEAM.PROPS) or (teamID == v:Team()) then
            col = 'wins'
        else
            col = 'losses'
        end

        local queryObj = lps.sql:Select('stats')
        queryObj:Where('steam_id', v:SteamID())
        queryObj:Callback(function(result, status, lastID)
            if (type(result) == 'table' and #result > 0) then
                local updateObj = lps.sql:Update('stats')
                updateObj:Update('name', v:Name())
                updateObj:Update(col, result[1][col] + 1)
                updateObj:Where('steam_id', v:SteamID())
                updateObj:Execute()
            end
        end)
        queryObj:Execute()
    end
end)