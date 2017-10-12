--[[
    mysql - 1.0.2
    A simple MySQL wrapper for Garry's Mod.
    Alexander Grist-Hucker
    http://www.alexgrist.com
--]]

lps = lps or {}

local type = type
local tostring = tostring
local table = table
local moduleNotExist = 'The %s module does not exist!'

local QUERY = {}
QUERY.__index = QUERY

lps.sql = lps.sql or {
    queueTable =  {},
    module = 'sqlite',
    connected = false,
    prefix = ''
}

function QUERY:New(tableName, queryType)
    local newObject = setmetatable({}, QUERY)
    newObject.queryType = queryType
    newObject.tableName = tableName
    newObject.selectList = {}
    newObject.insertList = {}
    newObject.updateList = {}
    newObject.createList = {}
    newObject.whereList = {}
    newObject.orderByList = {}
    return newObject
end

function QUERY:Escape(text)
    return lps.sql:Escape(tostring(text))
end

function QUERY:ForTable(tableName)
    self.tableName = tableName
end

function QUERY:Where(key, value)
    self:WhereEqual(key, value)
end

function QUERY:WhereEqual(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` = \'' .. self:Escape(value) .. '\''
end

function QUERY:WhereNotEqual(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` != \'' .. self:Escape(value) .. '\''
end

function QUERY:WhereLike(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` LIKE \'' .. self:Escape(value) .. '\''
end

function QUERY:WhereNotLike(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` NOT LIKE \'' .. self:Escape(value) .. '\''
end

function QUERY:WhereGT(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` > \'' .. self:Escape(value) .. '\''
end

function QUERY:WhereLT(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` < \'' .. self:Escape(value) .. '\''
end

function QUERY:WhereGTE(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` >= \'' .. self:Escape(value) .. '\''
end

function QUERY:WhereLTE(key, value)
    self.whereList[#self.whereList + 1] = '`' .. key .. '` <= \'' .. self:Escape(value) .. '\''
end

function QUERY:OrderByDesc(key)
    self.orderByList[#self.orderByList + 1] = '`' .. key .. '` DESC'
end

function QUERY:OrderByAsc(key)
    self.orderByList[#self.orderByList + 1] = '`' .. key .. '` ASC'
end

function QUERY:Callback(queryCallback)
    self.callback = queryCallback
end

function QUERY:Select(fieldName)
    self.selectList[#self.selectList + 1] = '`' .. fieldName .. '`'
end

function QUERY:Insert(key, value)
    self.insertList[#self.insertList + 1] = {'`' .. key .. '`', '\'' .. self:Escape(value) .. '\''}
end

function QUERY:Update(key, value)
    self.updateList[#self.updateList + 1] = {'`' .. key .. '`', '\'' .. self:Escape(value) .. '\''}
end

function QUERY:Create(key, value)
    self.createList[#self.createList + 1] = {'`' .. key .. '`', value}
end

function QUERY:PrimaryKey(key)
    self.primaryKey = '`' .. key .. '`'
end

function QUERY:Limit(value)
    self.limit = value
end

function QUERY:Offset(value)
    self.offset = value
end

local function BuildSelectQuery(queryObj)
    local queryString = {'SELECT'}

    if (type(queryObj.selectList) != 'table' or #queryObj.selectList == 0) then
        queryString[#queryString + 1] = ' *'
    else
        queryString[#queryString + 1] = ' ' .. table.concat(queryObj.selectList, ', ')
    end

    if (type(queryObj.tableName) == 'string') then
        queryString[#queryString + 1] = ' FROM `' .. queryObj.tableName .. '` '
    else
        hook.Call('DBError', GAMEMODE, 'No table name specified!')
        return
    end

    if (type(queryObj.whereList) == 'table' and #queryObj.whereList > 0) then
        queryString[#queryString + 1] = ' WHERE '
        queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
    end

    if (type(queryObj.orderByList) == 'table' and #queryObj.orderByList > 0) then
        queryString[#queryString + 1] = ' ORDER BY '
        queryString[#queryString + 1] = table.concat(queryObj.orderByList, ', ')
    end

    if (type(queryObj.limit) == 'number') then
        queryString[#queryString + 1] = ' LIMIT '
        queryString[#queryString + 1] = queryObj.limit
    end

    return table.concat(queryString)
end

local function BuildInsertQuery(queryObj)
    local queryString = {'INSERT INTO'}
    local keyList = {}
    local valueList = {}

    if (type(queryObj.tableName) == 'string') then
        queryString[#queryString + 1] = ' `' .. queryObj.tableName .. '`'
    else
        hook.Call('DBError', GAMEMODE, 'No table name specified!')
        return
    end

    for i = 1, #queryObj.insertList do
        keyList[#keyList + 1] = queryObj.insertList[i][1]
        valueList[#valueList + 1] = queryObj.insertList[i][2]
    end

    if (#keyList == 0) then
        return
    end

    queryString[#queryString + 1] = ' (' .. table.concat(keyList, ', ') .. ')'
    queryString[#queryString + 1] = ' VALUES (' .. table.concat(valueList, ', ') .. ')'

    return table.concat(queryString)
end

local function BuildUpdateQuery(queryObj)
    local queryString = {'UPDATE'}

    if (type(queryObj.tableName) == 'string') then
        queryString[#queryString + 1] = ' `' .. queryObj.tableName .. '`'
    else
        hook.Call('DBError', GAMEMODE, 'No table name specified!')
        return
    end

    if (type(queryObj.updateList) == 'table' and #queryObj.updateList > 0) then
        local updateList = {}

        queryString[#queryString + 1] = ' SET'

        for i = 1, #queryObj.updateList do
            updateList[#updateList + 1] = queryObj.updateList[i][1] .. ' = ' .. queryObj.updateList[i][2]
        end

        queryString[#queryString + 1] = ' ' .. table.concat(updateList, ', ')
    end

    if (type(queryObj.whereList) == 'table' and #queryObj.whereList > 0) then
        queryString[#queryString + 1] = ' WHERE '
        queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
    end

    if (type(queryObj.offset) == 'number') then
        queryString[#queryString + 1] = ' OFFSET '
        queryString[#queryString + 1] = queryObj.offset
    end

    return table.concat(queryString)
end

local function BuildDeleteQuery(queryObj)
    local queryString = {'DELETE FROM'}

    if (type(queryObj.tableName) == 'string') then
        queryString[#queryString + 1] = ' `' .. queryObj.tableName .. '`'
    else
        hook.Call('DBError', GAMEMODE, 'No table name specified!')
        return
    end

    if (type(queryObj.whereList) == 'table' and #queryObj.whereList > 0) then
        queryString[#queryString + 1] = ' WHERE '
        queryString[#queryString + 1] = table.concat(queryObj.whereList, ' AND ')
    end

    if (type(queryObj.limit) == 'number') then
        queryString[#queryString + 1] = ' LIMIT '
        queryString[#queryString + 1] = queryObj.limit
    end

    return table.concat(queryString)
end

local function BuildDropQuery(queryObj)
    local queryString = {'DROP TABLE'}

    if (type(queryObj.tableName) == 'string') then
        queryString[#queryString + 1] = ' `' .. queryObj.tableName .. '`'
    else
        hook.Call('DBError', GAMEMODE, 'No table name specified!')
        return
    end

    return table.concat(queryString)
end

local function BuildTruncateQuery(queryObj)
    local queryString = {'TRUNCATE TABLE'}

    if (type(queryObj.tableName) == 'string') then
        queryString[#queryString + 1] = ' `' .. queryObj.tableName .. '`'
    else
        hook.Call('DBError', GAMEMODE, 'No table name specified!')
        return
    end

    return table.concat(queryString)
end

local function BuildCreateQuery(queryObj)
    local queryString = {'CREATE TABLE IF NOT EXISTS'}

    if (type(queryObj.tableName) == 'string') then
        queryString[#queryString + 1] = ' `' .. queryObj.tableName .. '`'
    else
        hook.Call('DBError', GAMEMODE, 'No table name specified!')
        return
    end

    queryString[#queryString + 1] = ' ('

    if (type(queryObj.createList) == 'table' and #queryObj.createList > 0) then
        local createList = {}

        for i = 1, #queryObj.createList do
            if (lps.sql.module == 'sqlite') then
                createList[#createList + 1] = queryObj.createList[i][1] .. ' ' .. string.gsub(string.gsub(string.gsub(queryObj.createList[i][2], 'AUTO_INCREMENT', ''), 'AUTOINCREMENT', ''), 'INT ', 'INTEGER ')
            else
                createList[#createList + 1] = queryObj.createList[i][1] .. ' ' .. queryObj.createList[i][2]
            end
        end

        queryString[#queryString + 1] = ' ' .. table.concat(createList, ', ')
    end

    if (type(queryObj.primaryKey) == 'string') then
        queryString[#queryString + 1] = ', PRIMARY KEY'
        queryString[#queryString + 1] = ' (' .. queryObj.primaryKey .. ')'
    end

    queryString[#queryString + 1] = ')'

    return table.concat(queryString)
end

function QUERY:Execute(bQueueQuery)
    local queryString = nil
    local queryType = string.lower(self.queryType)

    if (queryType == 'select') then
        queryString = BuildSelectQuery(self)
    elseif (queryType == 'insert') then
        queryString = BuildInsertQuery(self)
    elseif (queryType == 'update') then
        queryString = BuildUpdateQuery(self)
    elseif (queryType == 'delete') then
        queryString = BuildDeleteQuery(self)
    elseif (queryType == 'drop') then
        queryString = BuildDropQuery(self)
    elseif (queryType == 'truncate') then
        queryString = BuildTruncateQuery(self)
    elseif (queryType == 'create') then
        queryString = BuildCreateQuery(self)
    end

    if (type(queryString) == 'string') then
        if (!bQueueQuery) then
            return lps.sql:RawQuery(queryString, self.callback)
        else
            return lps.sql:Queue(queryString, self.callback)
        end
    end
end

--[[
    End Query Class.
--]]

function lps.sql:Select(tableName)
    return QUERY:New(self.prefix .. tableName, 'SELECT')
end

function lps.sql:Insert(tableName)
    return QUERY:New(self.prefix .. tableName, 'INSERT')
end

function lps.sql:Update(tableName)
    return QUERY:New(self.prefix .. tableName, 'UPDATE')
end

function lps.sql:Delete(tableName)
    return QUERY:New(self.prefix .. tableName, 'DELETE')
end

function lps.sql:Drop(tableName)
    return QUERY:New(self.prefix .. tableName, 'DROP')
end

function lps.sql:Truncate(tableName)
    return QUERY:New(self.prefix .. tableName, 'TRUNCATE')
end

function lps.sql:Create(tableName)
    return QUERY:New(self.prefix .. tableName, 'CREATE')
end

-- A function to connect to the MySQL database.
function lps.sql:Connect(host, username, password, database, port, socket, flags)
    if (!port) then
        port = 3306
    end

    if (self.module == 'tmysql4') then
        if (type(tmysql) != 'table') then
            require('tmysql4')
        end

        if (tmysql) then
            local errorText = nil

            self.connection, errorText = tmysql.initialize(host, username, password, database, port, socket, flags)

            if (!self.connection) then
                self:OnConnectionFailed(errorText)
            else
                self:OnConnected()
            end
        else
            hook.Call('DBError', GAMEMODE, string.format(moduleNotExist, module))
        end
    elseif (self.module == 'mysqloo') then
        if (type(mysqloo) != 'table') then
            require('mysqloo')
        end

        if (mysqloo) then
            local clientFlag = flags or 0

            if (type(socket) ~= 'string') then
                self.connection = mysqloo.connect(host, username, password, database, port)
            else
                self.connection = mysqloo.connect(host, username, password, database, port, socket, clientFlag)
            end

            self.connection.onConnected = function(database)
                lps.sql:OnConnected()
            end

            self.connection.onConnectionFailed = function(database, errorText)
                lps.sql:OnConnectionFailed(errorText)
            end

            self.connection:connect()
        else
            hook.Call('DBError', GAMEMODE, string.format(moduleNotExist, module))
        end
    elseif (self.module == 'sqlite') then
        lps.sql:OnConnected()
    end
end

-- A function to query the MySQL database.
function lps.sql:RawQuery(query, callback, flags,  ...)
    if (!self.connection and module != 'sqlite') then
        self:Queue(query)
    end

    if (self.module == 'tmysql4') then
        local queryFlag = flags or QUERY_FLAG_ASSOC

        self.connection:Query(query, function(result)
            local queryStatus = result[1]['status']

            if (queryStatus) then
                if (type(callback) == 'function') then
                    local bStatus, value = pcall(callback, result[1]['data'], queryStatus, result[1]['lastid'])

                    if (!bStatus) then
                        hook.Call('DBError', GAMEMODE, string.format('SQL Callback Error!%s', value))
                    end
                end
            else
                hook.Call('DBError', GAMEMODE, string.format('SQL Query Error!Query: %s%s', query, result[1]['error']))
            end
        end, queryFlag,  ...)
    elseif (self.module == 'mysqloo') then
        local queryObj = self.connection:query(query)

        queryObj:setOption(mysqloo.OPTION_NAMED_FIELDS)

        queryObj.onSuccess = function(queryObj, result)
            if (callback) then
                local bStatus, value = pcall(callback, result, true, queryObj:lastInsert())

                if (!bStatus) then
                    hook.Call('DBError', GAMEMODE, string.format('SQL Callback Error!%s', value))
                end
            end
        end

        queryObj.onError = function(queryObj, errorText)
            hook.Call('DBError', GAMEMODE, string.format('SQL Query Error!Query: %s%s', query, errorText))
        end

        queryObj:start()
    elseif (self.module == 'sqlite') then
        local result = sql.Query(query)

        if (result == false) then
            hook.Call('DBError', GAMEMODE, string.format('SQL Query Error!Query: %s%s', query, sql.LastError()))
        else
            if (callback) then
                local bStatus, value = pcall(callback, result)

                if (!bStatus) then
                    hook.Call('DBError', GAMEMODE, string.format('SQL Callback Error!%s', value))
                end
            end
        end
    else
        hook.Call('DBError', GAMEMODE, string.format('Unsupported module \'%s\'!', self.module))
    end
end

-- A function to add a query to the queue.
function lps.sql:Queue(queryString, callback)
    if (type(queryString) == 'string') then
        self.queueTable[#self.queueTable + 1] = {queryString, callback}
    end
end

-- A function to escape a string for MySQL.
function lps.sql:Escape(text)
    if (self.connection) then
        if (self.module == 'tmysql4') then
            return self.connection:Escape(text)
        elseif (self.module == 'mysqloo') then
            return self.connection:escape(text)
        end
    else
        return sql.SQLStr(string.gsub(text, '"', '\''), true)
    end
end

-- A function to disconnect from the MySQL database.
function lps.sql:Disconnect()
    if (self.connection) then
        if (self.module == 'tmysql4') then
            return self.connection:Disconnect()
        end
    end

    self.connected = false
end

function lps.sql:Think()
    if (#self.queueTable > 0) then
        if (type(self.queueTable[1]) == 'table') then
            local queueObj = self.queueTable[1]
            local queryString = queueObj[1]
            local callback = queueObj[2]

            if (type(queryString) == 'string') then
                self:RawQuery(queryString, callback)
            end

            table.remove(self.queueTable, 1)
        end
    end
end


-- A function to set the module that should be used.
function lps.sql:SetPrefix(prefix)
    self.prefix = prefix
end

-- A function to set the module that should be used.
function lps.sql:SetModule(module)
    self.module = module
end

-- Called when the database connects successfully.
function lps.sql:OnConnected()
    self.connected = true
    hook.Call('DBConnected', GAMEMODE)
end

-- Called when the database connection fails.
function lps.sql:OnConnectionFailed(errorText)
    hook.Call('DBFailed', GAMEMODE, errorText)
end

-- A function to check whether or not the module is connected to a database.
function lps.sql:IsConnected()
    return self.connected
end

return mysql