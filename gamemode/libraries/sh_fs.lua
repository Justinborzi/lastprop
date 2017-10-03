lps = lps or {}

lps.fs = lps.fs or {}

--[[---------------------------------------------------------
--   Name: lps.fs:Load()
---------------------------------------------------------]]--
function lps.fs:Load(sFile)
    if (not file.Exists(lps.paths.data, 'DATA')) then
        file.CreateDir(lps.paths.data)
    end
    local path = string.format('%s/%s', lps.paths.data, sFile)
    if (file.Exists(path, 'DATA')) then
        local data =  util.JSONToTable(file.Read(path))
        if (data) then
            return data
        else
            lps.Warning('Failed to load \'%s\'', sFile)
            debug.Trace()
        end
    end
    return false
end

--[[---------------------------------------------------------
--   Name: lps.fs:Save()
---------------------------------------------------------]]--
function lps.fs:Save(sFile, data)
    if (not file.Exists(lps.paths.data, 'DATA')) then
        file.CreateDir(lps.paths.data)
    end
    file.Write(string.format('%s/%s',  lps.paths.data, sFile), util.TableToJSON(data))
    lps.Info('Saved file \'%s\'', sFile)
end