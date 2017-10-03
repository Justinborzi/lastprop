lps = lps or {}
lps.bindings = lps.bindings or {
    default = {},
    settings = {}
}

--[[---------------------------------------------------------
--   Name: lps.bindings:Load()
---------------------------------------------------------]]--
function lps.bindings:Load()
    local data = lps.fs:Load('bindings.txt')
    if (data and type(data) == 'table' and not table.Empty(data)) then
        for class, setting in pairs(data) do
            self.settings[class] = setting
        end
    end
end

--[[---------------------------------------------------------
--   Name: lps.bindings:Save()
---------------------------------------------------------]]--
function lps.bindings:Save()
    lps.fs:Save('bindings.txt', self.settings)
end

--[[---------------------------------------------------------
--   Name: lps.bindings:Register()
---------------------------------------------------------]]--
function lps.bindings:Register(class, id, default, type, name, description)
    if (not self.default[class]) then self.default[class] = {} end
    if (not self.settings[class]) then self.settings[class] = {} end
    self.default[class][id] = {key = default, name = name, desc = description, type = type}
    self.settings[class][id] = {key = default, type = type}
end

--[[---------------------------------------------------------
--   Name: lps.bindings:GetKey()
---------------------------------------------------------]]--
function lps.bindings:GetKey(class, id)
    return self.settings[class][id]
end

--[[---------------------------------------------------------
--   Name: lps.bindings:GetClass()
---------------------------------------------------------]]--
function lps.bindings:GetClass(class)
    return self.default[class], self.settings[class]
end

--[[---------------------------------------------------------
--   Name: lps.bindings:Setkey()
---------------------------------------------------------]]--
function lps.bindings:SetKey(class, id, key, type)
    self.settings[class][id] = {key = key, type = type}
    lps.bindings:Save()
end

--[[---------------------------------------------------------
--   Name: lps.bindings:Resetkey()
---------------------------------------------------------]]--
function lps.bindings:ResetKey(class, id, key, type)
    self.settings[class][id] = {key = self.default[class][id].key, type = self.default[class][id].type}
    lps.bindings:Save()
end


--[[---------------------------------------------------------
--   hook: BindingsLoad
---------------------------------------------------------]]--
hook.Add('InitPostEntity', 'BindingsLoad', function()
    hook.Call('RegisterBindings', GAMEMODE)
    lps.bindings:Load()
end)
