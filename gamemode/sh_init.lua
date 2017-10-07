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
    a gamemode by Nerdism
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
    'sv_sql.lua',
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
    -- Check version
    --
    local path = string.format('%s/%s', lps.paths.mod, 'lastprop.txt')
    if (file.Exists(path, 'MOD')) then
        local config = util.KeyValuesToTable(file.Read(path, 'MOD'));
        lps.version = config.version
        for id, tag in pairs(config.support) do
            lps.support[string.upper(id)] = tag
        end
        if (config.version == 'dev') then
            lps.Warning('Using a development version of the gamemode! You might experience bugs!')
        end
    end

    timer.Simple(1, function()
        http.Fetch('https://raw.githubusercontent.com/gluaws/lastprop/info/info.json',
        function(body, len, headers, code)
            if (code ~= 200) then
                lps.Warning('UNABLE TO CHECK FOR UPDATE!')
                return
            end
            local config = util.JSONToTable(body)
            if(lps.version ~= 'dev' ) then
                if(config.version ~= lps.version) then
                    lps.Log('There\'s a new update! v%s is out! Go to \'%s\' to download and view changelogs!', config.version, config.download_url)
                else
                    lps.Log('v%s is up to date! Enjoy!', lps.version)
                end
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