lps = lps or {}
lps.class = lps.class or {}

--[[---------------------------------------------------------
--   Name: lps.class:Register()
---------------------------------------------------------]]--
function lps.class:Register(name, class)
    if not (self.classes) then self.classes = {} end
    self.classes[name] = class
    self.classes[name].setup = false
    lps.Info('Registered class \'%s\'', name)
end

--[[---------------------------------------------------------
--   Name: lps.class:Get()
---------------------------------------------------------]]--
function lps.class:Get(name)
    if (type(name) == 'table') then name = table.Random(name) end
    if (not self.classes or not self.classes[name]) then return end
    if (not self.classes[name].setup) then
        lps.Info('Setup class \'%s\'', name)
        self.classes[name].setup = true
        local base = self.classes[name].base
        if (self.classes[name].base and self:Get(base)) then
            self.classes[name] = table.Inherit(self.classes[name], self:Get(base))
            self.classes[name].baseclass = self:Get(base)
        end
    end
    return self.classes[name]
end

--[[---------------------------------------------------------
--   hook: ClassRegisterBindings
---------------------------------------------------------]]--
hook.Add('RegisterBindings', 'ClassRegisterBindings', function()
    for _, class in pairs(lps.class.classes) do
        if class.RegisterBindings then
            class:RegisterBindings()
        end
    end
end)