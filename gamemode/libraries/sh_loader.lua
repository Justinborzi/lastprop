--
-- CONSTANTS
--
local include, AddCSLuaFile, format, exists, find, ends = include, AddCSLuaFile, string.format, file.Exists, file.Find, string.EndsWith

lps = lps or {}

if (SERVER) then
    AddCSLuaFile()
end

lps.load = lps.load or {}
lps.state = lps.state or {
    server = 1,
    client = 2,
    shared = 3,
}

-- Base Folders for Gamemode
lps.paths = lps.paths or {
    mod     = 'gamemodes/lastprop',
    game    = 'gamemodes/lastprop',
    lua     = 'lastprop/gamemode',
    addon   = 'lastprop',
    data    = 'lastprop',
}


--[[---------------------------------------------------------
--   Name: lps.load:CSInclude()
--   Desc: Includes file, server and client side.
---------------------------------------------------------]]--
function lps.load:CSInclude(lua, state)
    if (type(lua) == 'table') then
        for i = 1, #lua do
            self:CSInclude(lua[i], state)
        end
    else
        if (state == lps.state.shared) then
            if exists(lua, 'LUA') then
                if (SERVER) then
                    AddCSLuaFile(lua)
                end
                include(lua)
            end
        else
            if (state == lps.state.client) then
                if exists(lua, 'LUA') then
                    if (SERVER) then
                        AddCSLuaFile(lua)
                    elseif (CLIENT) then
                        include(lua)
                    end
                end
            end
            if (state == lps.state.server and SERVER) then
                if exists(lua, 'LUA') then
                    include(lua)
                end
            end
        end
    end
end

--[[---------------------------------------------------------
--   Name: lps.load:StaticInclude()
--   Desc: Includes folder with static state, server and client.
---------------------------------------------------------]]--
function lps.load:StaticInclude(folder, state)
    local files, folders = find(format('%s/*.lua', folder), 'LUA')
    for _, lua in pairs(files) do
        if exists(format('%s/%s', folder, lua), 'LUA') then
            self:CSInclude(format('%s/%s', folder, lua), state)
        end
    end
    for _, src in pairs(folders) do
        self:StaticInclude(format('%s/%s', folder, src), state)
    end
end

--[[---------------------------------------------------------
--   Name: lps.load:ParseInclude()
--   Desc: Includes folder with states according to file name (sh_, vgui_, cl_, sv_), server and client.
---------------------------------------------------------]]--
function lps.load:ParseInclude(folder, base)
    local files, folders = find(format('%s/*', folder) , 'LUA')
    for _, lua in pairs(find(format('%s/sh_*.lua', folder), 'LUA')) do
        local lua = format('%s/%s', folder, lua)
        if (exists(lua, 'LUA')) then
            self:CSInclude(lua, lps.state.shared)
        end
    end
    for _, lua in pairs(find(format('%s/vgui_*.lua', folder), 'LUA')) do
        local lua = format('%s/%s', folder, lua)
        if (exists(lua,  'LUA')) then
            self:CSInclude(lua, lps.state.client)
        end
    end
    for _, lua in pairs(find(format('%s/cl_*.lua', folder), 'LUA')) do
        local lua = format('%s/%s', folder, lua)
        if (exists(lua,  'LUA')) then
            self:CSInclude(lua, lps.state.client)
        end
    end
    for _, lua in pairs(find(format('%s/sv_*.lua', folder), 'LUA')) do
        local lua = format('%s/%s', folder, lua)
        if (exists(lua, 'LUA')) then
            self:CSInclude(lua, lps.state.server)
        end
    end
    for _, src in pairs(folders) do
        self:ParseInclude(format('%s/%s', folder, src))
    end
end

--[[---------------------------------------------------------
--   Name: lps.load:Lua()
---------------------------------------------------------]]--
function lps.load:Lua(folder, base)
    if (type(folder) == 'table') then
        for i = 1, #folder do
            self:Lua(folder[i], base)
        end
    else
        local files, folders = find(format('%s/%s/*', base and base or lps.paths.lua, folder), 'LUA')
        for _, lua in pairs(files) do
            if (ends(lua, 'lua')) then
                local lua = format('%s/%s/%s', base and base or lps.paths.lua, folder, lua)
                if exists(lua, 'LUA') then
                    AddCSLuaFile(lua)
                end
            end
        end
        for _, src in pairs(folders) do
            self:Lua(format('%s/%s', folder, src))
        end
    end
end

--[[---------------------------------------------------------
--   Name: lps.load:File()
---------------------------------------------------------]]--
function lps.load:File(folder, state, files, base)
    self:CSInclude(format('%s/%s/%s', base and base or lps.paths.lua, folder, lua), state)
end

--[[---------------------------------------------------------
--   Name: lps.load:Files()
---------------------------------------------------------]]--
function lps.load:Files(folder, state, files, base)
    for _, lua in pairs(files) do
        self:CSInclude(format('%s/%s/%s', base and base or lps.paths.lua, folder, lua), state)
    end
end

--[[---------------------------------------------------------
--   Name: lps.load:Modules()
---------------------------------------------------------]]--
function lps.load:Modules(folder, base)
    local files, folders = find(format('%s/%s/*', base and base or lps.paths.lua, folder and folder or 'modules'), 'LUA')
    for _, src in pairs(folders) do
        self:ParseInclude(format('%s/%s', base and base or lps.paths.lua, folder))
    end
end

--[[---------------------------------------------------------
--   Name: lps.load:Module()
---------------------------------------------------------]]--
function lps.load:Module(folder, base)
    self:ParseInclude(format('%s/%s', base and base or lps.paths.lua, folder))
end

--[[---------------------------------------------------------
--   Name: lps.load:Map()
---------------------------------------------------------]]--
function lps.load:Map()
    self:CSInclude(format('%s/maps/%s.lua', lps.paths.lua, game.GetMap()), lps.state.shared)
end
