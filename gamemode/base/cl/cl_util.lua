util = util or {}

--[[---------------------------------------------------------
--   Name: util.textWrap()
---------------------------------------------------------]]--
-- From https://github.com/FPtje/DarkRP/blob/353dc3286092cdb2efade2cc0f2145db5a6c2e69/gamemode/modules/base/cl_util.lua
function util.textWrap(text, font, pxWidth)
    local total = 0

    surface.SetFont(font)

    local spaceSize = surface.GetTextSize(' ')
    text = text:gsub('(%s?[%S]+)', function(word)
            local char = string.sub(word, 1, 1)
            if char == '\n' or char == '\t' then
                total = 0
            end

            local wordlen = surface.GetTextSize(word)
            total = total + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= pxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, pxWidth - (total - wordlen))
                total = splitPoint
                return splitWord
            elseif total < pxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                total = wordlen - spaceSize
                return '\n' .. string.sub(word, 2)
            end

            total = wordlen
            return '\n' .. word
        end)

    return text
end


--[[---------------------------------------------------------
--   Name: util.GetConsoleColor()
---------------------------------------------------------]]--
function util.GetConsoleColor(var)
    local r = math.Clamp(GetConVar(var .. '_r'):GetInt(), 0,  255)
    local g = math.Clamp(GetConVar(var .. '_g'):GetInt(), 0,  255)
    local b = math.Clamp(GetConVar(var .. '_b'):GetInt(), 0,  255)
    local a = math.Clamp(GetConVar(var .. '_a'):GetInt(), 0,  255)
    return Color(r,g,b,a)
end

--[[---------------------------------------------------------
--   Name: util.SetConsoleColor()
---------------------------------------------------------]]--
function util.SetConsoleColor(var, color)
    RunConsoleCommand(var ..  '_r', color.r)
    RunConsoleCommand(var .. '_g', color.g)
    RunConsoleCommand(var .. '_b', color.b)
    RunConsoleCommand(var .. '_a', color.a)
end

--[[---------------------------------------------------------
--   Name: util.BindToScreen()
---------------------------------------------------------]]--
function util.BindToScreen(vec)
    local toScreen = vec:ToScreen()
    toScreen.x = math.Clamp(toScreen.x,0,ScrW())
    toScreen.y = math.Clamp(toScreen.y,0,ScrH())
    return toScreen
end

--[[---------------------------------------------------------
--   Name: util.DistanceColor()
---------------------------------------------------------]]--
function util.DistanceColor(distance, maxDist)
    local scale = distance/maxDist
    if scale > 1 then scale = 1 end
    return Color(255 -(255 * scale), scale * 255, 0, 200)
end

--[[---------------------------------------------------------
--   Name: util.Darken()
---------------------------------------------------------]]--
function util.Darken(c, n)
    return Color(c.r - n,c.g - n,c.b - n,c.a)
end

--[[---------------------------------------------------------
--   Name: util.Lighten()
---------------------------------------------------------]]--
function util.Lighten(c, n)
    return Color(c.r + n, c.g + n, c.b + n, c.a)
end

--[[---------------------------------------------------------
--   Name: util.SetAlpha()
---------------------------------------------------------]]--
function util.SetAlpha(color, alpha)
    return Color(color.r, color.g, color.b, alpha)
end

--[[---------------------------------------------------------
--   Name: util.Rainbow()
---------------------------------------------------------]]--
function util.Rainbow(saturation, value, alpha)
    saturation = saturation or 1
    value = value or 1
    alpha = alpha or 255
    local color = HSVToColor(math.abs(math.sin(0.3 * RealTime()) * 128), saturation, value)
    return Color(color.r, color.g, color.b, alpha)
end

--[[---------------------------------------------------------
--   Name: util.StencilStart()
---------------------------------------------------------]]--
function util.StencilStart()
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    render.SetStencilReferenceValue(1)
    render.SetColorModulation(1, 1, 1)
end

--[[---------------------------------------------------------
--   Name: util.StencilReplace()
---------------------------------------------------------]]--
function util.StencilReplace()
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilReferenceValue(1)
end

--[[---------------------------------------------------------
--   Name: util.StencilEnd()
---------------------------------------------------------]]--
function util.StencilEnd()
    render.SetStencilEnable(false)
end

--[[---------------------------------------------------------
--   Name: util.DrawSimpleCircle()
---------------------------------------------------------]]--
function util.DrawSimpleCircle(posx, posy, radius, color)
    local poly = {}
    local v = 40
    for i = 0, v do
        poly[i+1] = {x = math.sin(-math.rad(i / v * 360)) * radius + posx, y = math.cos(-math.rad(i / v * 360)) * radius + posy}
    end
    draw.NoTexture()
    surface.SetDrawColor(color)
    surface.DrawPoly(poly)
end

--[[---------------------------------------------------------
--   Name: util.DrawCircle()
---------------------------------------------------------]]--
function util.DrawCircle(posx, posy, radius, progress, color)
    local poly = {}
    local v = 220
    poly[1] = {x = posx, y = posy}
    for i = 0, v * progress + 0.5 do
        poly[i+2] = {x = math.sin(-math.rad(i / v * 360)) * radius + posx, y = math.cos(-math.rad(i / v * 360)) * radius + posy}
    end
    draw.NoTexture()
    surface.SetDrawColor(color)
    surface.DrawPoly(poly)
end

--[[---------------------------------------------------------
--   Name: util.DrawCircleGradient()
---------------------------------------------------------]]--
local gradientDown = Material('vgui/gradient-d')
function util.DrawCircleGradient(posx, posy, radius, progress, color)
    local poly = {}
    local v = 100
    poly[1] = {x = posx, y = posy}
    for i = 0, v * progress do
        poly[i+2] = {x = math.sin(-math.rad(i / v * 360)) * radius + posx, y = math.cos(-math.rad(i / v * 360)) * radius + posy}
        poly[i+2].u = 0
        poly[i+2].v = 0.6
    end
    surface.SetMaterial(gradientDown)
    surface.SetDrawColor(Color(0, 0, 0, 200))
    surface.DrawPoly(poly)
end