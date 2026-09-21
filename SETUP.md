# Nexus Setup Guide

Complete setup instructions for deploying Nexus to GitHub and using it in Roblox games.

---

## Prerequisites

- **Git** installed on your system
- **GitHub account**
- **Roblox executor** with HTTP capabilities (Synapse, Script-Ware, KRNL, etc.)
- **Basic understanding** of Lua and Git

---

## GitHub Setup

### Method 1: Automated Setup (Windows)

1. Open PowerShell in the ProjectNexus directory
2. Run the initialization script:
   ```powershell
   .\init.bat
   ```
3. Follow the prompts to enter your GitHub username
4. The script will automatically configure and push to GitHub

### Method 2: Automated Setup (Linux/Mac)

1. Open terminal in the ProjectNexus directory
2. Make the script executable:
   ```bash
   chmod +x init.sh
   ```
3. Run the setup:
   ```bash
   ./init.sh
   ```
4. Follow the prompts to enter your GitHub username

### Method 3: Manual Setup

If you prefer manual control:

**Step 1: Update Repository URLs**

Edit `loader_v2.lua` and replace the repository name:

```lua
local GITHUB_REPO = "YOUR_USERNAME/ProjectNexus"
local GITHUB_BRANCH = "main"
```

**Step 2: Initialize Git**

```bash
git init
git add .
git commit -m "Initial commit - Nexus v2.0"
```

**Step 3: Create GitHub Repository**

1. Go to https://github.com/new
2. Name: `ProjectNexus` (or your preferred name)
3. Visibility: Public (required for raw content access)
4. Do NOT initialize with README

**Step 4: Push to GitHub**

```bash
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ProjectNexus.git
git push -u origin main
```

---

## Loadstring Configuration

After pushing to GitHub, your loadstring will be:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/loader_v2.lua"))()
```

### Testing Your Loadstring

1. Open Roblox Studio or join a game
2. Execute your loadstring
3. You should see:
   ```
   ╔═══════════════════════════════════════════════╗
   ║          PROJECT NEXUS v2.0                    ║
   ║     Advanced FE Serverside Executor            ║
   ║             STANDALONE MODE                    ║
   ╚═══════════════════════════════════════════════╝
   ```
4. Press `Right Shift` to toggle the GUI

---

## Customization

### Changing the Repository Name

If you want to use a different repository name:

1. **Update loader_v2.lua:**
   ```lua
   local GITHUB_REPO = "YOUR_USERNAME/YOUR_REPO_NAME"
   ```

2. **Update main.lua:**
   ```lua
   local GITHUB_REPO = "YOUR_USERNAME/YOUR_REPO_NAME"
   ```

3. **Create GitHub repository** with matching name

4. **Push changes:**
   ```bash
   git add .
   git commit -m "Update repository name"
   git push
   ```

### Changing the GUI Toggle Key

Edit `loader_v2.lua`, find:

```lua
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        gui:Toggle()
    end
end)
```

Replace `RightShift` with any key:
- `LeftControl`
- `RightControl`
- `Insert`
- `Home`
- `End`
- etc.

### Custom Branding

**Change UI Title:**

Edit `client/gui.lua`, find:

```lua
title.Text = "NEXUS"
```

Change to your preferred name.

**Change UI Colors:**

Edit the `Theme` table in `client/gui.lua`:

```lua
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(24, 24, 28),
    Primary = Color3.fromRGB(99, 102, 241),  -- Change this
    -- ... more colors
}
```

---

## Advanced Configuration

### C&C Server Setup (Optional)

If you want remote command and control:

**Step 1: Install Python Dependencies**

```bash
pip install -r requirements.txt
```

**Step 2: Configure Server**

Edit `server/command_server.py`:

```python
HOST = "0.0.0.0"  # Listen on all interfaces
PORT = 8080       # Or your preferred port
```

**Step 3: Start Server**

```bash
cd server
python command_server.py
```

**Step 4: Update Loader**

Edit `loader_v2.lua`:

```lua
local config = {
    serverUrl = "http://YOUR_IP:8080",  -- Your server URL
    autoInit = true,
}
```

**Note:** Most Roblox executors block `localhost` HTTP requests. You'll need to:
- Deploy to a VPS/cloud server
- Use ngrok for testing
- Configure port forwarding

---

## Troubleshooting

### "Failed to load main module"

**Cause:** GitHub raw URL not accessible or incorrect repository name

**Solution:**
1. Verify repository is public
2. Check `GITHUB_REPO` matches your actual username/repo
3. Test URL manually in browser: `https://raw.githubusercontent.com/YOUR_USERNAME/ProjectNexus/main/main.lua`
4. Make sure you've pushed all files to GitHub

### "Main module returned nil"

**Cause:** Syntax error in `main.lua` or circular dependency

**Solution:**
1. Test `main.lua` syntax locally
2. Check console for error messages
3. Verify all `require()` statements are correct

### GUI Not Showing

**Cause:** Toggle key conflict or GUI creation error

**Solutions:**
1. Check console output for errors
2. Try a different toggle key
3. Verify `client/gui.lua` loaded successfully
4. Manually create GUI: `_G.NexusInstance.gui = loadstring(game:HttpGet("YOUR_URL/client/gui.lua"))().new() _G.NexusInstance.gui:Create():Toggle()`

### "No vulnerabilities found"

**Cause:** Game is properly secured or pattern detection needs refinement

**What to try:**
1. Check if game uses FilteringEnabled (most do now)
2. Look for admin systems manually
3. Test on different games
4. Review scanner patterns in `core/scanner.lua`

### HTTP Requests Blocked

**Cause:** Executor doesn't support HTTP or game blocks it

**Solutions:**
1. Verify your executor supports `HttpGet`
2. Test with: `print(game:HttpGet("https://httpbin.org/get"))`
3. Some games disable HTTP - try a different game
4. Use a different executor with better HTTP support

---

## Security Considerations

### Repository Privacy

**Public Repositories:**
- ✅ Free
- ✅ Easy to use with loadstrings
- ❌ Code is visible to everyone
- ❌ May be detected/blacklisted

**Private Repositories:**
- ✅ Code is hidden
- ❌ Requires authentication tokens
- ❌ More complex setup
- ❌ Not recommended for beginners

### Detection Avoidance

If you're concerned about detection:

1. **Use a unique repository name** (not "ProjectNexus")
2. **Obfuscate the loader** (advanced users)
3. **Change variable names** in source code
4. **Use different branding** (GUI title, colors)
5. **Host on multiple services** (GitHub, GitLab, Bitbucket)

### Best Practices

1. **Never share your loadstring publicly** if it's linked to your main GitHub account
2. **Use an alt GitHub account** for security research
3. **Don't store sensitive data** in the repository
4. **Regularly update** to stay current with Roblox changes
5. **Test on your own games first** before using elsewhere

---

## Updating Nexus

### Update from GitHub

1. **Edit your files locally**
2. **Commit changes:**
   ```bash
   git add .
   git commit -m "Description of changes"
   ```
3. **Push to GitHub:**
   ```bash
   git push
   ```
4. **Wait 1-2 minutes** for GitHub cache to clear
5. **Reload in Roblox** — your executor will pull the latest version

### Cache Busting

Nexus automatically adds cache busters to HTTP requests:

```lua
local cacheBuster = "?cb=" .. tostring(math.random(1000000, 9999999))
```

This ensures you always get the latest code.

---

## Testing Checklist

Before considering setup complete:

- [ ] Repository is public on GitHub
- [ ] All files are pushed successfully
- [ ] Raw URLs are accessible (test in browser)
- [ ] Loadstring executes without errors
- [ ] GUI appears and toggles correctly
- [ ] Scanner produces output
- [ ] Executor can run code
- [ ] Status indicator updates

---

## Next Steps

Now that Nexus is set up:

1. **Read the main README.md** for usage instructions
2. **Review the examples** in `examples/` directory
3. **Test on your own game** first
4. **Understand the scanner output** before attempting exploits
5. **Use responsibly** and ethically

---

## Getting Help

If you encounter issues not covered here:

1. Check the console output for error messages
2. Verify all setup steps were completed
3. Test individual components (scanner, GUI, executor)
4. Review source code comments for hints
5. Try on a different game to isolate the issue

---

## Additional Resources

- **GitHub Raw URL Format:** `https://raw.githubusercontent.com/USERNAME/REPO/BRANCH/FILE.lua`
- **Testing HTTP Access:** `game:HttpGet("https://httpbin.org/get")`
- **Lua Bytecode:** Advanced users can compile to bytecode for obfuscation
- **Alternative Hosts:** GitLab, Bitbucket, Pastebin (less reliable)

---

**Setup Complete!** You're ready to use Nexus for security research.
