-- taken from 943738100 and adapted to gamemode

ConfigHelper = ConfigHelper or {}

function ConfigHelper:CreateConfigFolderIfNotExists()
    if not file.Exists("lastprop/mapvote", "DATA") then
        file.CreateDir("lastprop/mapvote")
    end
end

function ConfigHelper:ReadConfig(configFile)
    local jsonString = file.Read("lastprop/mapvote/" .. configFile .. ".txt", "DATA")
    return util.JSONToTable(jsonString)
end

function ConfigHelper:WriteConfig(configFile, config)
    local configString = util.TableToJSON(config, true) -- true = prettyPrint
    file.Write("lastprop/mapvote/" .. configFile .. ".txt", configString)
end