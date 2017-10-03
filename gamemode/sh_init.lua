---
--- sh_init.lua - Shared Init Component
-----------------------------------------------------
--- Shared init file for client/server
---

lps = lps or {
    banned = {},
    taunts = {
        packs = {},
        info = {},
        sounds ={},
    },
    sounds = {
        music ={},
        ui = {},
        sfx = {},
    },
    player = {},
    support = {},
}

MsgC(Color(0,255,255), [[
   __            __    ___                  ______               ___           __
  / /  ___ ____ / /_  / _ \_______  ___    / __/ /____ ____  ___/ (_)__  ___ _/ /
 / /__/ _ `(_-</ __/ / ___/ __/ _ \/ _ \  _\ \/ __/ _ `/ _ \/ _  / / _ \/ _ `/_/
/____/\_,_/___/\__/ /_/  /_/  \___/ .__/ /___/\__/\_,_/_//_/\_,_/_/_//_/\_, (_)
                                 /_/                                   /___/
]])
--
-- Include loader library
--
include('libraries/sh_loader.lua')

--
-- Core Libraries
--
lps.load:Files('libraries', lps.state.shared, {
    'sh_log.lua',
    'sh_fs.lua',
    'sh_pon.lua',
    'sh_netstream.lua',
    'sh_module.lua',
    'sh_class.lua',
})

--
-- Client Libraries
--
lps.load:Files('libraries', lps.state.client, {
    'cl_input.lua',
    'cl_binding.lua'
})

--
-- Server Libraries
--
lps.load:Files('libraries', lps.state.server, {
    'sv_database.lua',
})

if (SERVER) then
    --
    -- Send Client Files
    --
    lps.load:Lua({ 'base/cl', 'base/sh' })

    --
    -- Grab Workshop Content
    --
    resource.AddWorkshop('1150433884')

    --
    -- Load banned props
    --
    local path = string.format('%s/%s', lps.paths.data, 'banned_props.txt')
    if (file.Exists(path, 'DATA')) then
        lps.banned = util.JSONToTable(file.Read(path))
    else
        lps.banned = {
            'models/props/cs_assault/dollar.mdl',
            'models/props/cs_assault/money.mdl',
            'models/props/cs_office/snowman_arm.mdl',
            'models/props_junk/garbage_metalcan002a.mdl',
            'models/props/cs_office/computer_mouse.mdl',
            'models/props/cs_office/projector_remote.mdl',
            'models/props/cs_office/fire_extinguisher.mdl',
            'models/props_lab/huladoll.mdl',
            'models/weapons/w_357.mdl',
            'models/props_c17/tools_wrench01a.mdl',
            'models/props_c17/signpole001.mdl',
            'models/props_lab/clipboard.mdl',
            'models/props_c17/chair02a.mdl',
            'models/props/cs_office/computer_caseb_p2a.mdl',
            'models/props_trainstation/payphone_reciever001a.mdl'
        }
        file.Write(path, util.TableToJSON(lps.banned))
    end

    local path = string.format('%s/%s', lps.paths.mod, 'lastprop.txt')
    if (file.Exists(path, 'MOD')) then
        local config = util.KeyValuesToTable(file.Read(path, 'MOD'));
        lps.version = config.version
        for id, tag in pairs(config.support) do
            lps.support[string.upper(id)] = tag
        end
        MsgC(Color(0,255,255), string.format('  v%s, a gamemode by Nerdism\n\n', config.version))
    end

    timer.Simple(1, function()
        http.Fetch('https://raw.githubusercontent.com/gluaws/lastprop/master/lastprop.txt',
        function(body, len, headers, code)
            if (code ~= 200) then
                lps.Warning('UNABLE TO CHECK FOR UPDATE!')
                return
            end
            local config = util.KeyValuesToTable(body);
            if(config.version ~= lps.version) then
                lps.Log('There\'s a new update! v%s is out! Go to \'%s\' to download and view changelogs!', config.version, config.download_url)
            end
            for id, tag in pairs(config.support) do
                lps.support[string.upper(id)] = tag
            end
        end,
        function(error)
            lps.Warning('UNABLE TO CHECK FOR UPDATE!')
        end)
    end)
end

--
-- Load Modules
--
lps.load:Modules('modules', lps.paths.lua)
lps.load:Modules('modules', lps.paths.addon)

--
-- Load map fixes
--
lps.load:Map()

--
-- Include shred base
--
include('base/sh/sh_init.lua')