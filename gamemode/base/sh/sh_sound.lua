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

--[[---------------------------------------------------------
--   Hook: DefaultSounds
---------------------------------------------------------]]--
hook.Add('InitPostEntity', 'DefaultSounds', function()

    GAMEMODE:AddUISound('lock', 'buttons/button24.wav')
    GAMEMODE:AddUISound('unlock', 'buttons/button3.wav')

    GAMEMODE:AddSFX('victory', 'lps/sounds/sfx/victory.mp3')
    GAMEMODE:AddSFX('defeat', 'lps/sounds/sfx/defeat.mp3')
    GAMEMODE:AddSFX('death', 'lps/sounds/sfx/death.wav')
    GAMEMODE:AddSFX('start_hunters', 'lps/sounds/sfx/start_hunters.wav')
    GAMEMODE:AddSFX('start_props', 'lps/sounds/sfx/start_props.wav')

    GAMEMODE:AddMusic({
        'lps/sounds/music/afraid.mp3',
        'lps/sounds/music/backitup.mp3',
        'lps/sounds/music/bardello.mp3',
        'lps/sounds/music/dreaming.mp3',
        'lps/sounds/music/dreams.mp3',
        'lps/sounds/music/giraffe.mp3',
        'lps/sounds/music/midnightrun.mp3',
        'lps/sounds/music/moon.mp3',
        'lps/sounds/music/revibe.mp3',
        'lps/sounds/music/sendai.mp3',
        'lps/sounds/music/solparte.mp3',
        'lps/sounds/music/stansmood.mp3',
        'lps/sounds/music/tennyson.mp3',
        'lps/sounds/music/thoughts.mp3',
        'lps/sounds/music/wind.mp3',
    })

    GAMEMODE:RegisterTauntPack('default', {
        hunter = {
            {name = 't_asses2', file = 'lps/taunts/hunter/t_asses2.mp3', length = 2},
            {name = 't_bountyhunter1', file = 'lps/taunts/hunter/t_bountyhunter1.mp3', length = 7},
            {name = 't_bountyhunter2', file = 'lps/taunts/hunter/t_bountyhunter2.mp3', length = 8},
            {name = 't_canthide', file = 'lps/taunts/hunter/t_canthide.wav', length = 2},
            {name = 't_chardis', file = 'lps/taunts/hunter/t_chardis.mp3', length = 11},
            {name = 't_checked', file = 'lps/taunts/hunter/t_checked.mp3', length = 4},
            {name = 't_come_here_little_one', file = 'lps/taunts/hunter/t_come_here_little_one.mp3', length = 5},
            {name = 't_crappyshot', file = 'lps/taunts/hunter/t_crappyshot.wav', length = 4},
            {name = 't_dontrun', file = 'lps/taunts/hunter/t_dontrun.mp3', length = 2},
            {name = 't_gonnakill', file = 'lps/taunts/hunter/t_gonnakill.mp3', length = 3},
            {name = 't_goodbye', file = 'lps/taunts/hunter/t_goodbye.mp3', length = 2},
            {name = 't_how', file = 'lps/taunts/hunter/t_how.mp3', length = 7},
            {name = 't_iwillfindyou', file = 'lps/taunts/hunter/t_iwillfindyou.mp3', length = 3},
            {name = 't_i_see_you', file = 'lps/taunts/hunter/t_i_see_you.mp3', length = 6},
            {name = 't_jawstheme', file = 'lps/taunts/hunter/t_jawstheme.mp3', length = 11},
            {name = 't_liamneeson', file = 'lps/taunts/hunter/t_liamneeson.mp3', length = 8},
            {name = 't_predator', file = 'lps/taunts/hunter/t_predator.mp3', length = 4},
            {name = 't_psycho', file = 'lps/taunts/hunter/t_psycho.mp3', length = 12},
            {name = 't_sneaky', file = 'lps/taunts/hunter/t_sneaky.mp3', length = 4},
            {name = 't_whereareu', file = 'lps/taunts/hunter/t_whereareu.mp3', length = 5},
        },
        prop = {
            {name = 't_acdc', file = 'lps/taunts/prop/t_acdc.mp3', length = 6},
            {name = 't_agun', file = 'lps/taunts/prop/t_agun.wav', length = 2},
            {name = 't_alert2', file = 'lps/taunts/prop/t_alert2.mp3', length = 2},
            {name = 't_amazing_horse', file = 'lps/taunts/prop/t_amazing_horse.mp3', length = 13},
            {name = 't_apocpony', file = 'lps/taunts/prop/t_apocpony.mp3', length = 6},
            {name = 't_ballin', file = 'lps/taunts/prop/t_ballin.mp3', length = 3},
            {name = 't_bananana', file = 'lps/taunts/prop/t_bananana.mp3', length = 4},
            {name = 't_bananaphone', file = 'lps/taunts/prop/t_bananaphone.mp3', length = 10},
            {name = 't_batman', file = 'lps/taunts/prop/t_batman.mp3', length = 9},
            {name = 't_bh', file = 'lps/taunts/prop/t_bh.mp3', length = 15},
            {name = 't_bloops', file = 'lps/taunts/prop/t_bloops.mp3', length = 7},
            {name = 't_boo', file = 'lps/taunts/prop/t_boo.wav', length = 1},
            {name = 't_boxghost', file = 'lps/taunts/prop/t_boxghost.mp3', length = 2},
            {name = 't_cantina2', file = 'lps/taunts/prop/t_cantina2.mp3', length = 4},
            {name = 't_canttouchthis', file = 'lps/taunts/prop/t_canttouchthis.mp3', length = 22},
            {name = 't_circus', file = 'lps/taunts/prop/t_circus.mp3', length = 8},
            {name = 't_colt45', file = 'lps/taunts/prop/t_colt45.mp3', length = 9},
            {name = 't_cunning', file = 'lps/taunts/prop/t_cunning.mp3', length = 4},
            {name = 't_deathrooster2', file = 'lps/taunts/prop/t_deathrooster2.mp3', length = 8},
            {name = 't_dew', file = 'lps/taunts/prop/t_dew.mp3', length = 8},
            {name = 't_de_la_biere_icitte', file = 'lps/taunts/prop/t_de_la_biere_icitte.mp3', length = 21},
            {name = 't_dogsocks2', file = 'lps/taunts/prop/t_dogsocks2.mp3', length = 6},
            {name = 't_dropit', file = 'lps/taunts/prop/t_dropit.mp3', length = 8},
            {name = 't_eagleblimp', file = 'lps/taunts/prop/t_eagleblimp.mp3', length = 6},
            {name = 't_foxsay', file = 'lps/taunts/prop/t_foxsay.mp3', length = 17},
            {name = 't_gangnam', file = 'lps/taunts/prop/t_gangnam.mp3', length = 16},
            {name = 't_getlow', file = 'lps/taunts/prop/t_getlow.mp3', length = 9},
            {name = 't_giggity', file = 'lps/taunts/prop/t_giggity.mp3', length = 2},
            {name = 't_giveyouup', file = 'lps/taunts/prop/t_giveyouup.mp3', length = 8},
            {name = 't_goodies', file = 'lps/taunts/prop/t_goodies.mp3', length = 5},
            {name = 't_grenades2', file = 'lps/taunts/prop/t_grenades2.mp3', length = 1},
            {name = 't_guiles', file = 'lps/taunts/prop/t_guiles.mp3', length = 12},
            {name = 't_hahagood1', file = 'lps/taunts/prop/t_hahagood1.mp3', length = 6},
            {name = 't_hello2', file = 'lps/taunts/prop/t_hello2.mp3', length = 7},
            {name = 't_holyshit', file = 'lps/taunts/prop/t_holyshit.mp3', length = 4},
            {name = 't_iama', file = 'lps/taunts/prop/t_iama.mp3', length = 2},
            {name = 't_iloveweed', file = 'lps/taunts/prop/t_iloveweed.mp3', length = 2},
            {name = 't_imthemap', file = 'lps/taunts/prop/t_imthemap.mp3', length = 6},
            {name = 't_im_sexy', file = 'lps/taunts/prop/t_im_sexy.mp3', length = 9},
            {name = 't_intermission', file = 'lps/taunts/prop/t_intermission.mp3', length = 8},
            {name = 't_lickmybattery', file = 'lps/taunts/prop/t_lickmybattery.wav', length = 10},
            {name = 't_lotion', file = 'lps/taunts/prop/t_lotion.mp3', length = 7},
            {name = 't_manamana', file = 'lps/taunts/prop/t_manamana.mp3', length = 12},
            {name = 't_mario', file = 'lps/taunts/prop/t_mario.mp3', length = 7},
            {name = 't_meow', file = 'lps/taunts/prop/t_meow.mp3', length = 1},
            {name = 't_mosquito', file = 'lps/taunts/prop/t_mosquito.mp3', length = 5},
            {name = 't_my_dick', file = 'lps/taunts/prop/t_my_dick.mp3', length = 10},
            {name = 't_naked', file = 'lps/taunts/prop/t_naked.wav', length = 4},
            {name = 't_nomnom', file = 'lps/taunts/prop/t_nomnom.wav', length = 20},
            {name = 't_nyan', file = 'lps/taunts/prop/t_nyan.mp3', length = 7},
            {name = 't_people_on_inside', file = 'lps/taunts/prop/t_people_on_inside.mp3', length = 5},
            {name = 't_pirate', file = 'lps/taunts/prop/t_pirate.mp3', length = 4},
            {name = 't_porn2', file = 'lps/taunts/prop/t_porn2.mp3', length = 5},
            {name = 't_rocky', file = 'lps/taunts/prop/t_rocky.mp3', length = 14},
            {name = 't_scream', file = 'lps/taunts/prop/t_scream.wav', length = 2},
            {name = 't_selfie', file = 'lps/taunts/prop/t_selfie.wav', length = 4},
            {name = 't_shutup', file = 'lps/taunts/prop/t_shutup.mp3', length = 3},
            {name = 't_sixflags', file = 'lps/taunts/prop/t_sixflags.mp3', length = 7},
            {name = 't_smb_star', file = 'lps/taunts/prop/t_smb_star.mp3', length = 10},
            {name = 't_sneakylaugh', file = 'lps/taunts/prop/t_sneakylaugh.mp3', length = 2},
            {name = 't_sofat', file = 'lps/taunts/prop/t_sofat.mp3', length = 9},
            {name = 't_star_017', file = 'lps/taunts/prop/t_star_017.mp3', length = 11},
            {name = 't_star_019', file = 'lps/taunts/prop/t_star_019.mp3', length = 11},
            {name = 't_stayinalive', file = 'lps/taunts/prop/t_stayinalive.mp3', length = 17},
            {name = 't_stayinalive2', file = 'lps/taunts/prop/t_stayinalive2.mp3', length = 13},
            {name = 't_sticky1', file = 'lps/taunts/prop/t_sticky1.mp3', length = 4},
            {name = 't_sticky2', file = 'lps/taunts/prop/t_sticky2.mp3', length = 6},
            {name = 't_sticky5', file = 'lps/taunts/prop/t_sticky5.mp3', length = 5},
            {name = 't_techno', file = 'lps/taunts/prop/t_techno.mp3', length = 11},
            {name = 't_toast', file = 'lps/taunts/prop/t_toast.mp3', length = 12},
            {name = 't_trololo', file = 'lps/taunts/prop/t_trololo.mp3', length = 12},
            {name = 't_trumpets', file = 'lps/taunts/prop/t_trumpets.mp3', length = 7},
            {name = 't_turret_anyone_there', file = 'lps/taunts/prop/t_turret_anyone_there.mp3', length = 1},
            {name = 't_turret_goodbye', file = 'lps/taunts/prop/t_turret_goodbye.mp3', length = 1},
            {name = 't_turret_hello', file = 'lps/taunts/prop/t_turret_hello.mp3', length = 1},
            {name = 't_vahjayjay', file = 'lps/taunts/prop/t_vahjayjay.mp3', length = 5},
            {name = 't_weed', file = 'lps/taunts/prop/t_weed.mp3', length = 2},
            {name = 't_whisp', file = 'lps/taunts/prop/t_whisp.mp3', length = 7},
            {name = 't_wickedsick', file = 'lps/taunts/prop/t_wickedsick.mp3', length = 3},
            {name = 't_yousmellfunny', file = 'lps/taunts/prop/t_yousmellfunny.mp3', length = 1},
        },
        lastman = {
            {name = 't_annihilate', file = 'lps/taunts/lastman/t_annihilate.mp3', length = 71},
            {name = 't_birthdaycake', file = 'lps/taunts/lastman/t_birthdaycake.mp3', length = 70},
            {name = 't_diffused', file = 'lps/taunts/lastman/t_diffused.mp3', length = 60},
            {name = 't_down_low', file = 'lps/taunts/lastman/t_down_low.mp3', length = 61},
            {name = 't_droid', file = 'lps/taunts/lastman/t_droid.mp3', length = 60},
            {name = 't_drwho', file = 'lps/taunts/lastman/t_drwho.mp3', length = 71},
            {name = 't_freshprince', file = 'lps/taunts/lastman/t_freshprince.mp3', length = 68},
            {name = 't_ftw', file = 'lps/taunts/lastman/t_ftw.mp3', length = 71},
            {name = 't_grinder', file = 'lps/taunts/lastman/t_grinder.mp3', length = 70},
            {name = 't_killthenoise', file = 'lps/taunts/lastman/t_killthenoise.mp3', length = 71},
            {name = 't_losingcontrol', file = 'lps/taunts/lastman/t_losingcontrol.mp3', length = 71},
            {name = 't_megaman2', file = 'lps/taunts/lastman/t_megaman2.mp3', length = 65},
            {name = 't_outoftime1', file = 'lps/taunts/lastman/t_outoftime1.mp3', length = 71},
            {name = 't_outoftime2', file = 'lps/taunts/lastman/t_outoftime2.mp3', length = 73},
            {name = 't_pumpvolume', file = 'lps/taunts/lastman/t_pumpvolume.mp3', length = 71},
            {name = 't_rise1', file = 'lps/taunts/lastman/t_rise1.mp3', length = 70},
            {name = 't_rise2', file = 'lps/taunts/lastman/t_rise2.mp3', length = 73},
            {name = 't_ruckus', file = 'lps/taunts/lastman/t_ruckus.mp3', length = 70},
            {name = 't_signalz', file = 'lps/taunts/lastman/t_signalz.mp3', length = 71},
            {name = 't_turndown', file = 'lps/taunts/lastman/t_turndown.mp3', length = 71},
        },
    })

end)


