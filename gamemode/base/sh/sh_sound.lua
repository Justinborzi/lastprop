SOUND = {
    UI = 1,
    SFX = 2,
    MUSIC = 3
}

--[[---------------------------------------------------------
--   Name: GM:PlaySound()
---------------------------------------------------------]]--
function GM:PlaySound(soundPath, channel, stoptime)
    if (not soundPath) then return end

    if (SERVER) then
        lps.net.Start(nil, 'PlaySound', {soundPath, channel, stoptime})
        return
    end

    channel = channel or SOUND.UI
    stoptime = stoptime or 0

    local vol = 0
    if (channel == SOUND.UI) then
        vol =  math.Clamp(GetConVar('lps_vol_ui'):GetFloat(), 0, 1)
    elseif (channel == SOUND.SFX) then
        vol =  math.Clamp(GetConVar('lps_vol_sfx'):GetFloat(), 0, 1)
    elseif (channel == SOUND.MUSIC) then
        vol =  math.Clamp(GetConVar('lps_vol_music'):GetFloat(), 0, 1)
    end

    if (vol <= 0) then return end

    sound.PlayFile('sound/' .. soundPath, 'noplay', function(playing, error_id, error_name)
        if (error_id) then
            surface.PlaySound(soundPath)
            lps.Error('Unable to PlaySound \'%s\', %s %s', soundPath, error_id, error_name)
        end

        if (IsValid(playing)) then

            playing:SetVolume(vol)
            playing:Play()

            if (not self.sounds) then
                self.sounds = {}
            end

            table.insert(self.sounds, {sound = playing, channel = channel, stop = (stoptime > 0 and (CurTime() + stoptime) or 0)})

            if (not timer.Exists('PlayingSoundsThink')) then
                timer.Create('PlayingSoundsThink', .1, 0, function()
                    GAMEMODE:PlayingSoundsThink()
                end)
            end
        else
            lps.Warning('Unable to PlaySound, sound.PlayFile is invalid!')
        end
    end)
end

lps.net.Hook('PlaySound', function(data)
    hook.Call('PlaySound', GAMEMODE, data[1], data[2], data[3])
end)


--[[---------------------------------------------------------
--   Name: GM:RegisterTaunt()
---------------------------------------------------------]]--
function GM:RegisterTaunt(pack, type, taunt)

    if (not table.HasValue(lps.taunts.packs, pack)) then table.insert(lps.taunts.packs, pack) end

    if (not lps.taunts.sounds[pack]) then lps.taunts.sounds[pack] = {} end
    if (not lps.taunts.sounds[pack][type]) then lps.taunts.sounds[pack][type] = {} end

    if (not lps.taunts.info[pack]) then lps.taunts.info[pack] = {} end
    if (not lps.taunts.info[pack][type]) then
        lps.taunts.info[pack][type] = {
            count = 0,
            max = 0,
            min = 0
        }
    end

    if (SERVER) then
        sound.Add({
            name = taunt.name,
            channel = taunt.channel or CHAN_AUTO,
            volume = math.Clamp(taunt.volume or 1, .1, 1),
            level = taunt.level or 90, -- https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel
            pitch = taunt.pitch or 100,
            sound = taunt.file
        })
    end

    util.PrecacheSound(taunt.name)

    lps.taunts.sounds[pack][type][taunt.name] = taunt

    if (taunt.length > lps.taunts.info[pack][type].max) then
        lps.taunts.info[pack][type].max = taunt.length
    end

    if (taunt.length < lps.taunts.info[pack][type].min) then
        lps.taunts.info[pack][type].min = taunt.length
    end

    lps.taunts.info[pack][type].count = lps.taunts.info[pack][type].count +1
end

--[[---------------------------------------------------------
--   Name: GM:RegisterTauntPack()
---------------------------------------------------------]]--
function GM:RegisterTauntPack(pack, taunts)
    if (not taunts.hunter) then
        lps.WarningTrace('Taunt pack \'%s\' doesn\'t have a hunter property!', pack)
    else
        for _, taunt in pairs(taunts.hunter) do
            self:RegisterTaunt(pack, 'hunter', taunt)
        end
    end

    if (not taunts.prop) then
        lps.WarningTrace('Taunt pack \'%s\' doesn\'t have a prop property!', pack)
    else
        for _, taunt in pairs(taunts.prop) do
            self:RegisterTaunt(pack, 'prop', taunt)
        end
    end

    if (not taunts.lastman) then
        lps.WarningTrace('Taunt pack \'%s\' doesn\'t have a lastman property!', pack)
    else
        for _, taunt in pairs(taunts.lastman) do
            self:RegisterTaunt(pack, 'lastman', taunt)
        end
    end
end

--[[---------------------------------------------------------
--   Name: GM:AddMusic()
---------------------------------------------------------]]--
function GM:AddMusic(path)
    if (type(path) == 'table') then
        for _, soundFile in pairs(path) do
            self:AddMusic(soundFile)
        end
        return
    end
    table.insert(lps.sounds.music, path)
end

--[[---------------------------------------------------------
--   Name: GM:AddSFX()
---------------------------------------------------------]]--
function GM:AddSFX(name, path)
    lps.sounds.sfx[name] = path
end

--[[---------------------------------------------------------
--   Name: GM:AddUISound()
---------------------------------------------------------]]--
function GM:AddUISound(name, path)
    lps.sounds.ui[name] = path
end

