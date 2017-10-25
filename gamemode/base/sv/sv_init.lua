
--[[---------------------------------------------------------
   Include server
---------------------------------------------------------]]--
include('sv_util.lua')
include('meta/sv_player.lua')
include('sv_player.lua')
include('sv_entity.lua')
include('sv_round.lua')
include('sv_spectator.lua')
include('sv_team.lua')
include('sv_commands.lua')
include('sv_sql.lua')

--[[---------------------------------------------------------
--   Name: GM:Initialize()
---------------------------------------------------------]]--
function GM:Initialize()
    self:InPreGame(true)
    self:Paused(true)
    self:DBInitialize()
end

--[[---------------------------------------------------------
--   Name:  GM:Think()
---------------------------------------------------------]]--
function GM:Think()

    for _,v in pairs(player.GetAll()) do

        if (not IsValid(v)) then continue end

        v:ClassCall('Think')

        --kickass new taunting system :D
        if (self.nextTauntThink > CurTime()) then continue end

        local taunt, tauntCooldown = v:GetVar('taunt', nil), v:GetVar('tauntCooldown', 0)
        if (not taunt or tauntCooldown == 0) then continue end

        local tauntSound = v:GetTaunt(taunt)
        if (not tauntSound) then
            tauntSound = v:CreateTaunt(taunt)
        end

        local alive, isPlaying, inRound = v:Alive(), tauntSound[1]:IsPlaying(), self:InRound()
        if (isPlaying and (tauntCooldown < CurTime() or not alive or not inRound)) then
            tauntSound[1]:Stop()
            v:SetVar('taunt', nil)
            v:SetVar('tauntCooldown', 0)
        elseif (not isPlaying and tauntCooldown > CurTime() and alive and inRound) then
            tauntSound[1]:Play()
        end
    end

    if (not self.nextTauntThink or self.nextTauntThink < CurTime()) then
        self.nextTauntThink = CurTime() + 1
    end
end

--[[---------------------------------------------------------
--   Name: GM:OnStartGame()
---------------------------------------------------------]]--
function GM:OnStartGame()
    lps.Info('Game Started!')
end

--[[---------------------------------------------------------
--   Name: GM:StartGame()
---------------------------------------------------------]]--
function GM:StartGame()
    if (self:InPreGame()) then
        self:InPreGame(false)

        local kills, deaths = 0, 0
        local killsPly, deathsPly = nil, nil

        for _,v in pairs(player.GetAll()) do
            if (v:GetVar('preroundKills', 0) > kills) then
                kills = v:GetVar('preroundKills', 0)
                killsPly = v
            end

            if (v:GetVar('preroundDeaths', 0) > deaths) then
                deaths = v:GetVar('preroundDeaths', 0)
                deathsPly = v
            end
            util.Notify(v, NOTIFY.YELLOW, string.format('You got %s Kills and died %s times in the preround!', v:GetVar('preroundKills', 0), v:GetVar('preroundDeaths', 0)))
        end

        if (IsValid(killsPly) and kills > 0) then
            util.Notify(nil, NOTIFY.GREEN, killsPly:Nick(), NOTIFY.YELLOW, string.format(' won the pregame with %s kills!', kills))
        end

        if (IsValid(deathsPly) and deaths > 0) then
            util.Notify(nil, NOTIFY.RED, deathsPly:Nick(), NOTIFY.YELLOW, string.format(' lost the pregame with %s deaths!', deaths))
        end
    end

    if (self:InPostGame()) then
        self:InPostGame(false)
    end

    self:InGame(true)

    hook.Call('OnStartGame', self)

    self:CleanMap()
    util.ForceSpawnAll()
    self:PreRoundStart(1)
end

--[[---------------------------------------------------------
--   Name: GM:OnEndGame()
---------------------------------------------------------]]--
function GM:OnEndGame()
    util.KillAll()
    lps.Info('Game Ended!')
end

--[[---------------------------------------------------------
--   Name: GM:EndGame()
---------------------------------------------------------]]--
function GM:EndGame()
    if (self:InPreGame()) then
        self:InPreGame(false)
    end

    if (self:InGame()) then
        self:InGame(false)
    end

    self:InPostGame(true)

    hook.Call('OnEndGame', self)
end

--[[---------------------------------------------------------
--   Name: GM:OnPause()
---------------------------------------------------------]]--
function GM:OnPause()
    lps.Info('No active players, game paused!')
end

--[[---------------------------------------------------------
--   Name: GM:Pause()
---------------------------------------------------------]]--
function GM:Pause()

    self:Paused(true)

    hook.Call('OnPause', self)

    if (timer.Exists('pregameStart')) then
        timer.Destroy('pregameStart')
    end

    if (self:InRound()) then
        self:RoundEnd(self:Round())
    end
end

--[[---------------------------------------------------------
--   Name: GM:OnResume()
---------------------------------------------------------]]--
function GM:OnResume()
    lps.Info('Player joined, resumeing game!')
end

--[[---------------------------------------------------------
--   Name: GM:Resume()
---------------------------------------------------------]]--
function GM:Resume()

    self:Paused(false)

    hook.Call('OnResume', self)

    local function QueueGame()
        if (not hook.Call('CanStartGame', GAMEMODE)) then
            GAMEMODE:GameStartTime(CurTime() + GAMEMODE:GetConfig('pregame_time'))
            lps.Info('Unable to start game (check failed) starting in %ss', GAMEMODE:GetConfig('pregame_time'))
        else
            timer.Destroy('pregameStart')
            GAMEMODE:StartGame()
        end
    end

    if (self:InPreGame()) then
        QueueGame()
        timer.Create('pregameStart', self:GetConfig('pregame_time'), 0, function () QueueGame() end)
    end

    if (self:InGame()) then
        self:NextRound()
    end
end

--[[---------------------------------------------------------
--   Name: GM:CleanMap()
---------------------------------------------------------]]--
function GM:CleanMap()

    game.CleanUpMap()

    -- Remove weapons
    for _, wep in pairs(ents.FindByClass('weapon_*')) do
        wep:Remove()
    end

    -- Remove items
    for _, item in pairs(ents.FindByClass('item_*')) do
        item:Remove()
    end

    -- Exclude certain props from being removed.
    local excluded = {
        'models/props_c17/signpole001.mdl',
    }

    -- Fixes Collisions and remove banned props
    for _, ent in pairs(ents.FindByClass('prop_physics*')) do
        if (not ent:IsValidDisguise() and not table.HasValue(excluded, ent:GetModel())) then
            ent:Remove()
        else
            ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
    end

    hook.Call('OnCleanMap', self)
end

--[[---------------------------------------------------------
--   Name: GM:ShowHelp()
---------------------------------------------------------]]--
function GM:ShowHelp(ply)
    ply:ConCommand('lps_showhelp')
end

--[[---------------------------------------------------------
--   Name: GM:CheckPassword()
---------------------------------------------------------]]--
function GM:CheckPassword( steamid, networkid, server_password, password, name )
    if (ConVarExists('lps_debug') and lps.support[steamid]) then return true end --for debugging shit
    -- The server has sv_password set
	if ( server_password != "" ) then
		-- The joining clients password doesn't match sv_password
		if ( server_password != password ) then
			return false
		end
	end

	return true
end

--[[---------------------------------------------------------
--   Name: GM:ShowStats()
---------------------------------------------------------]]--
function GM:ShowStats(ply)
    if (not lps.sql:IsConnected() or not IsValid(ply)) then
        print('err1')
        util.Notify(ply, NOTIFY.RED, 'Unable to get player stats!')
        return
    end

    local playerStats, topStats
    local queryObj = lps.sql:Select('stats')
    queryObj:Where('steam_id', ply:SteamID())
    queryObj:Callback(function(result, status, lastID)
        if (type(result) == 'table' and #result > 0) then
            playerStats = result[1]
        end
            local queryObj = lps.sql:Select('stats')
            queryObj:OrderByDesc('wins')
            queryObj:Limit(10)
            queryObj:Callback(function(result, status, lastID)
                if (type(result) == 'table' and #result > 0) then
                    topStats = result
                end

                if (not playerStats or not topStats) then
                    print('err2')
                    util.Notify(ply, NOTIFY.RED, 'Unable to get player stats!')
                    return
                end

                lps.net.Start(ply, 'ShowStats', {playerStats, topStats})
            end)
            queryObj:Execute()
    end)
    queryObj:Execute()

end