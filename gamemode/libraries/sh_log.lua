
local MsgC, Color, os, string = MsgC, Color, os, string

lps = lps or {}

LOG = LOG or {
    COMMON    = 1,
    INFO      = 2,
    WARN      = 4,
    ERROR     = 8
}

local function canlog(flag)
    local level = 11
    if (ConVarExists('lps_logs')) then
        level = GetConVar('lps_logs'):GetInt()
    end
    if (type(flag) == 'table') then
        for i=1, #flag do
            if (bit.band(flag[i], level) >= flag[i])then
                return true
            end
        end
    else
        if (bit.band(flag, level) >= flag)then
            return true
        end
    end
    return false
end

local function log(color, flag, time, format, ...)

    if (not canlog(flag)) then return end

    local data = {}
    for i, v in ipairs{...} do
        if (type(v) == 'table') then
            data[i] = table.ToString(v, nil, true)
        elseif (type(v) == 'number') then
            data[i] = tostring(v)
        else
            data[i] = v
        end
    end

    local log;
    if (#data > 0) then
        log = string.format(format, unpack(data))
    elseif(type(format) == 'table') then
        log = table.ToString(format, nil, true)
    else
        log = string.format('%s', format)
    end

    local flagStr;

    if (flag == LOG.INFO) then
        flagStr = ' INFO: '
    elseif(lag == LOG.WARN) then
        flagStr = ' WARN: '
    elseif(lag == LOG.ERROR) then
        flagStr = ' ERROR: '
    else
        flagStr = ' '
    end

    local timeStr = ''
    if (time) then
        timeStr = '[' .. os.date('%H:%M:%S') .. '] '
    end

    MsgC(color,
        string.format('[GM]%s%s%s' .. (string.EndsWith(log,'\n') and '' or '\n'),
            timeStr,
            flagStr,
            log
       )
   )
end

local function trace()
    local trace = {}
    for i, line in pairs(string.Split(debug.traceback(), '\n')) do
        if (i == 1) then
            table.insert(trace, '    ' .. line)
        else
            if (not string.find(line, 'sh_log.lua')) then
                table.insert(trace, string.Replace(line,  lps.paths.lua .. '/gamemode/', '') )
            end
        end
    end
    return table.concat(trace , '\n')
end

function safecall(func, ...)
    local succ, err = pcall(func, ...)
    if (not succ) then
        log(Color(255, 0, 0), LOG.ERROR, true, 'ERROR: %s \n%s \n', string.Replace(err, lps.paths.lua .. '/gamemode/', ''),  trace())
    end
    return succ
end

--[[---------------------------------------------------------
--   Name: lps.Log()
---------------------------------------------------------]]--
function lps.Log(f, ...)
    log(Color(255, 255, 255), LOG.COMMON, false, f, ...)
end

--[[---------------------------------------------------------
--   Name: lps.Info()
---------------------------------------------------------]]--
function lps.Info(f, ...)
    log(Color(0, 255, 255), LOG.INFO, false, f, ...)
end

--[[---------------------------------------------------------
--   Name: lps.Error()
---------------------------------------------------------]]--
function lps.Error(f, ...)
    log(Color(255, 0, 0), LOG.ERROR, true, f, ...)
end

--[[---------------------------------------------------------
--   Name: lps.Warning()
---------------------------------------------------------]]--
function lps.Warning(f, ...)
    log(Color(255, 255, 0), LOG.WARN, true, f, ...)
end

--[[---------------------------------------------------------
--   Name: lps.WarningTrace()
---------------------------------------------------------]]--
function lps.WarningTrace(f, ...)
    log(Color(255, 255, 0), LOG.WARN, true, f, ...)
    MsgC(Color(255, 255, 0), trace())
end