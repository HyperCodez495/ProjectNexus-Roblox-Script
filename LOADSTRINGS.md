# Nexus Loadstrings

Different ways to load and configure Nexus for various use cases.

---

## Standard Loadstrings

### Recommended: Standalone Loader (v2)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
```

**Features:**
- Auto-scans on load
- No C&C server required
- GUI included
- Compromise attempts automatically
- Access via `_G.NexusInstance`

**Toggle GUI:** Press `Right Shift`

---

### Basic Loader (v1)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

**Features:**
- Similar to v2
- Slightly different initialization
- Legacy compatibility

---

### Direct Main Module

```lua
local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()
local instance = Nexus.new({
    commandServer = "http://localhost:8080",
    autoScan = true,
    persistentMode = true
})
```

**Use when:**
- You need custom configuration
- Building on top of Nexus
- Integrating with other scripts

---

## Configuration Options

### Silent Mode (No GUI)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
local nexus = _G.NexusInstance

-- GUI is loaded but hidden - don't toggle it
-- Use command-line interface only
```

### Scanner Only

```lua
local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()
local nexus = Nexus.new({autoScan = false})

-- Just scan, don't compromise
local results = nexus:ScanCurrentGame()
print(nexus.scanner:ExportResults(results, "text"))
```

### Auto-Execute on Compromise

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

-- Wait for compromise, then run code
task.spawn(function()
    local nexus = _G.NexusInstance
    while not nexus.compromised do
        task.wait(1)
    end
    
    -- Game is compromised, execute your code
    nexus:Execute([[
        print("We have serverside access!")
        -- Your code here
    ]])
end)
```

---

## Advanced Loadstrings

### With Custom Toggle Key

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

-- Override toggle key
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then  -- Use Insert instead
        if _G.NexusGUI then
            _G.NexusGUI:Toggle()
        end
    end
end)
```

### Delayed Initialization

```lua
-- Load but don't initialize yet
local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()

-- Wait for specific condition
repeat task.wait(0.5) until game:IsLoaded()

-- Now initialize
local nexus = Nexus.new({autoScan = true})
nexus:Initialize()
```

### Multiple Game Support

```lua
local games = {
    [606849621] = "Jailbreak",
    [2753915549] = "Bloxburg",
    -- Add more
}

local currentGame = games[game.PlaceId]
if currentGame then
    print("Loading Nexus for", currentGame)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
else
    warn("Nexus not configured for this game")
end
```

---

## Executor-Specific

### Synapse X

```lua
-- Standard loadstring works
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

-- Or use syn functions
syn.queue_on_teleport([[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
]])
```

### Script-Ware

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

-- Auto-execute on server hop
game:GetService("TeleportService").TeleportInitFailed:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
end)
```

### KRNL

```lua
-- Basic loadstring
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

-- Save to workspace for faster loading
writefile("nexus.lua", game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))

-- Load from file
loadstring(readfile("nexus.lua"))()
```

---

## Custom Configurations

### High Security Mode

```lua
local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()

local nexus = Nexus.new({
    commandServer = "https://your-secure-server.com",
    authKey = "your-secret-key-here",
    autoScan = false,  -- Manual control
    persistentMode = false  -- Don't persist across respawns
})

-- Manually scan when ready
task.wait(5)
nexus:ScanCurrentGame()
```

### Developer Mode

```lua
-- More verbose output for debugging
_G.DEBUG = true

local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()
local nexus = Nexus.new({autoScan = true})

-- Log all function calls
setmetatable(nexus, {
    __index = function(t, k)
        print("[DEBUG] Accessing:", k)
        return rawget(t, k)
    end
})
```

### Minimal Footprint

```lua
-- Load components individually, no globals
local Scanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/core/scanner.lua"))()
local scanner = Scanner.new()

local results = scanner:ScanGame(game)
print("Score:", results.score)

-- Don't load GUI or executor - just scan
```

---

## Integration Examples

### With Universal ESP

```lua
-- Load Nexus first
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

-- Wait for compromise
repeat task.wait(1) until _G.NexusInstance.compromised

-- Now you have serverside - enhance your ESP
_G.NexusInstance:Execute([[
    -- Serverside ESP helper
    game:GetService("Players").PlayerAdded:Connect(function(player)
        -- Tag players for client ESP
        player:SetAttribute("ESP_Visible", true)
    end)
]])
```

### With Admin Commands

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

local nexus = _G.NexusInstance

-- Wait for serverside
repeat task.wait(1) until nexus.compromised

-- Inject admin system
nexus:Command("admin")

-- Now use chat commands
-- :kill PlayerName
-- :tp Player1 Player2
-- :god PlayerName
-- :speed PlayerName 100
```

### Auto-Farm Integration

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()

local nexus = _G.NexusInstance

-- Once compromised, give yourself items serverside
task.spawn(function()
    repeat task.wait(1) until nexus.compromised
    
    -- Farm loop with serverside control
    while task.wait(60) do
        nexus:Execute([[
            local player = game.Players.LocalPlayer
            -- Give currency, items, etc.
        ]])
    end
end)
```

---

## Obfuscated Loadstrings

For users who want to hide their source:

### Basic Obfuscation

```lua
-- Base64 encode your URL
local url = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL1lPVVJfVVNFUk5BTUUvUHJvamVjdE5leHVzL21haW4vbG9hZGVyX3YyLmx1YQ=="
local decoded = (function(b64)
    local decode = {}
    for i = 65, 90 do table.insert(decode, string.char(i)) end
    for i = 97, 122 do table.insert(decode, string.char(i)) end
    for i = 48, 57 do table.insert(decode, string.char(i)) end
    table.insert(decode, "+")
    table.insert(decode, "/")
    
    -- Decoding logic here (implement proper base64)
    return "YOUR_URL"
end)(url)

loadstring(game:HttpGet(decoded))()
```

### String Splitting

```lua
local parts = {
    "https://raw.git",
    "hubusercontent.com/",
    "YOUR_USERNAME/",
    "ProjectNexus/main/",
    "loader_v2.lua"
}
loadstring(game:HttpGet(table.concat(parts)))()
```

### Function Wrapping

```lua
local function LoadNexus()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
end

LoadNexus()
```

---

## Pastebin Alternative

If you prefer Pastebin over GitHub:

1. **Create a Pastebin paste** with your loader code
2. **Get the raw URL:** `https://pastebin.com/raw/PASTE_ID`
3. **Load from Pastebin:**

```lua
loadstring(game:HttpGet("https://pastebin.com/raw/YOUR_PASTE_ID"))()
```

**Note:** Pastebin can be unreliable. GitHub is recommended.

---

## Cache Control

### Force Reload (Bypass Cache)

```lua
local cacheBuster = "?t=" .. tostring(os.time())
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua" .. cacheBuster))()
```

### Local Caching

```lua
local cacheFile = "nexus_cache.lua"

-- Check if cached version exists
if isfile and isfile(cacheFile) then
    print("Loading from cache")
    loadstring(readfile(cacheFile))()
else
    print("Downloading fresh copy")
    local content = game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua")
    
    if writefile then
        writefile(cacheFile, content)
    end
    
    loadstring(content)()
end
```

---

## Troubleshooting Loadstrings

### Test HTTP Access

```lua
-- Verify your executor supports HTTP
print(game:HttpGet("https://httpbin.org/get"))
```

### Test GitHub Access

```lua
-- Verify GitHub raw URLs work
print(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/README.md"))
```

### Catch Errors

```lua
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
end)

if success then
    print("Nexus loaded successfully")
else
    warn("Failed to load:", result)
end
```

---

## Best Practices

1. **Always test loadstrings** before sharing
2. **Use HTTPS** (not HTTP) for security
3. **Include error handling** in production scripts
4. **Cache locally** if loading frequently
5. **Version your loadstrings** for backwards compatibility
6. **Document your configuration** for future reference

---

**Ready to load?** Choose the loadstring that fits your use case and paste it into your executor.
