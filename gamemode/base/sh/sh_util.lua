util = util or {}

--[[---------------------------------------------------------
--   Name: util.ToMinutes()
---------------------------------------------------------]]--
function util.ToMinutes(seconds)
    local minutes = math.floor(seconds / 60)
    seconds = seconds - minutes * 60
    return string.format('%02d:%02d', minutes, math.floor(seconds))
end

NOTIFY = {
    DEFAULT = 1,
    RED = 2,
    WHITE = 3,
    GREEN = 4,
    YELLOW = 5,
}

local Colors = {
    [NOTIFY.DEFAULT]    = Color(230, 230, 230),
    [NOTIFY.RED]         = Color(211, 78, 71),
    [NOTIFY.WHITE]         = Color(230, 230, 230),
    [NOTIFY.GREEN]        = Color(55, 163, 68),
    [NOTIFY.YELLOW]        = Color(255, 230, 0)
}

--[[---------------------------------------------------------
--   Name: util.Notify()
---------------------------------------------------------]]--
function util.Notify(ply, ...)
    local arguments = {...}
    local text = ''

    for k, v in pairs(arguments) do
        if (type(v) == 'number') then
            if (Colors[v] == nil) then
                arguments[k] = NOTIFY.DEFAULT
            end
        elseif (type(v) == 'string') then
            text = text .. v
        else
            table.remove(v)
        end
    end

    if type(arguments[1]) ~= 'number' then
        table.insert(arguments, 1, NOTIFY.DEFAULT)
    end

    if (SERVER) then
        if (IsValid(ply)) then
            lps.net.Start(ply, 'LPSNotifyText', arguments)
        else
            lps.net.Start(nil, 'LPSNotifyText', arguments)
        end
    elseif (CLIENT) then
        for k, v in pairs(arguments) do
            if (type(v) == 'number') then
                arguments[k] = Colors[v]
            end
        end
        chat.AddText(unpack(arguments))
    end
end

if (CLIENT) then
    lps.net.Hook('LPSNotifyText', function(data)
        local arguments = {}
        for _, v in pairs(data) do
            if (type(v) == 'number') then
                arguments[#arguments + 1] = Colors[v]
            elseif (type(v) == 'string') then
                arguments[#arguments + 1] = v
            end
        end
        chat.AddText(unpack(arguments))
    end)
end

--[[---------------------------------------------------------
--   Name: util.SpectatorNames()
---------------------------------------------------------]]--
function util.SpectatorNames()
    local names = {}
    for _, v in pairs(player.GetAll()) do
        if (v:IsSpectator()) then
            table.insert(names, v:Nick())
        end
    end
    return table.concat(names, ', ')
end
