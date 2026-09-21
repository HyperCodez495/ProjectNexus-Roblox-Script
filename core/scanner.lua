--[[
    Nexus Core - Advanced Game Scanner
    Deep analysis of Roblox games for serverside vulnerabilities
    
    Detection vectors:
    - Admin system command injection (HD Admin, Adonis, Kohls, etc)
    - MainModule require() backdoors
    - Attribute-based payload storage
    - LoadString gamepass systems
    - Insecure RemoteEvent/RemoteFunction handlers
    - DataStore injection points
    - FilteringEnabled bypass attempts
]]

local Scanner = {}
Scanner.__index = Scanner

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Known admin system signatures
local ADMIN_SYSTEMS = {
    {name = "HD Admin", markers = {"HD_ADMIN", "HDAdminMain", "MainModule"}},
    {name = "Adonis", markers = {"Adonis_Loader", "Adonis_Main"}},
    {name = "Kohls Admin", markers = {"Kohl's Admin", "KOHLS_ADMIN"}},
    {name = "Basic Admin Essentials", markers = {"BAE_", "Basic Admin"}},
    {name = "Perm Admin", markers = {"PermAdmin", "PERM_ADMIN"}},
}

-- Critical backdoor patterns (high confidence)
local CRITICAL_PATTERNS = {
    -- Remote execution vectors
    {pattern = "require%(%d+%)", desc = "External module injection", severity = 10, type = "require_asset"},
    {pattern = "loadstring%(game:HttpGet", desc = "Remote code execution", severity = 10, type = "http_exec"},
    {pattern = "loadstring%(.-%)", desc = "Dynamic code execution", severity = 9, type = "loadstring"},
    
    -- Admin command patterns
    {pattern = "Players.PlayerAdded:Connect.-Chatted:Connect", desc = "Chat command listener", severity = 8, type = "chat_commands"},
    {pattern = ":Chatted:Connect.-if%s+msg", desc = "Message handler", severity = 7, type = "chat_handler"},
    
    -- Attribute storage (common evasion)
    {pattern = ":GetAttribute%(.+%)%s*==", desc = "Attribute-based control", severity = 8, type = "attribute"},
    {pattern = ":SetAttribute%(.-loadstring", desc = "Attribute payload storage", severity = 9, type = "attribute_payload"},
    
    -- Environment manipulation
    {pattern = "getfenv%(%d+%)", desc = "Environment access", severity = 7, type = "getfenv"},
    {pattern = "setfenv%(.-%)", desc = "Environment hijacking", severity = 8, type = "setfenv"},
    {pattern = "debug%.getinfo", desc = "Debug library access", severity = 6, type = "debug"},
    
    -- Global namespace pollution
    {pattern = "_G%[.-%]%s*=%s*function", desc = "Global function injection", severity = 7, type = "global_inject"},
    {pattern = "shared%[.-%]%s*=%s*", desc = "Shared table exploit", severity = 7, type = "shared"},
    
    -- Gamepass/product exploits
    {pattern = "MarketplaceService:UserOwnsGamePassAsync.-loadstring", desc = "Gamepass code injection", severity = 9, type = "gamepass_exec"},
    {pattern = "ProcessReceipt.-loadstring", desc = "Product purchase exploit", severity = 9, type = "product_exec"},
}

-- Moderate risk patterns
local MODERATE_PATTERNS = {
    {pattern = "RemoteEvent:FireServer%(.-%)", desc = "Client → Server communication", severity = 4},
    {pattern = "RemoteFunction:InvokeServer", desc = "Server invocation", severity = 5},
    {pattern = ":FireAllClients%(", desc = "Broadcast to all clients", severity = 3},
    {pattern = "DataStoreService:GetDataStore", desc = "DataStore access", severity = 5},
}

function Scanner.new()
    local self = setmetatable({}, Scanner)
    self.foundBackdoors = {}
    self.vulnerableRemotes = {}
    self.adminSystems = {}
    self.suspiciousAttributes = {}
    self.mainModules = {}
    self.scanDepth = 0
    self.maxDepth = 1000
    return self
end

-- Deep scan game for all vulnerability vectors
function Scanner:ScanGame(gameInstance)
    local startTime = tick()
    local results = {
        backdoors = {},
        remotes = {},
        adminSystems = {},
        mainModules = {},
        suspiciousScripts = {},
        attributes = {},
        score = 0,
        confidence = "LOW"
    }
    
    print("[SCANNER] Starting deep analysis...")
    
    -- Phase 1: Admin system detection
    local adminResults = self:DetectAdminSystems(gameInstance)
    results.adminSystems = adminResults
    results.score = results.score + (#adminResults * 15)
    
    -- Phase 2: Script analysis
    local scripts = {}
    for _, obj in ipairs(gameInstance:GetDescendants()) do
        if obj:IsA("ModuleScript") or obj:IsA("Script") or obj:IsA("LocalScript") then
            table.insert(scripts, obj)
        end
    end
    
    print(string.format("[SCANNER] Analyzing %d scripts...", #scripts))
    
    for i, script in ipairs(scripts) do
        if i % 50 == 0 then
            print(string.format("[SCANNER] Progress: %d/%d", i, #scripts))
        end
        
        local scriptResults = self:AnalyzeScript(script)
        
        if #scriptResults.backdoors > 0 then
            for _, backdoor in ipairs(scriptResults.backdoors) do
                table.insert(results.backdoors, backdoor)
                results.score = results.score + backdoor.severity
            end
        end
        
        if scriptResults.suspicious then
            table.insert(results.suspiciousScripts, {
                path = script:GetFullName(),
                reason = scriptResults.reason,
                entropy = scriptResults.entropy
            })
            results.score = results.score + 3
        end
        
        if script:IsA("ModuleScript") then
            local isMainModule = self:CheckMainModule(script)
            if isMainModule then
                table.insert(results.mainModules, {
                    path = script:GetFullName(),
                    risk = "HIGH"
                })
                results.score = results.score + 12
            end
        end
    end
    
    -- Phase 3: Remote analysis
    print("[SCANNER] Analyzing RemoteEvents/Functions...")
    for _, obj in ipairs(gameInstance:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local remoteRisk = self:AnalyzeRemote(obj)
            if remoteRisk.vulnerable then
                table.insert(results.remotes, remoteRisk)
                results.score = results.score + remoteRisk.severity
            end
        end
    end
    
    -- Phase 4: Attribute scanning
    print("[SCANNER] Scanning instance attributes...")
    local attrResults = self:ScanAttributes(gameInstance)
    results.attributes = attrResults
    results.score = results.score + (#attrResults * 8)
    
    -- Calculate confidence
    results.confidence = self:CalculateConfidence(results.score, #results.backdoors, #results.adminSystems)
    results.rating = self:CalculateRating(results.score)
    results.scanTime = tick() - startTime
    
    print(string.format("[SCANNER] Scan complete in %.2fs - Rating: %s", results.scanTime, results.rating))
    
    return results
end

-- Detect known admin systems
function Scanner:DetectAdminSystems(gameInstance)
    local found = {}
    
    for _, adminDef in ipairs(ADMIN_SYSTEMS) do
        for _, marker in ipairs(adminDef.markers) do
            for _, obj in ipairs(gameInstance:GetDescendants()) do
                local name = obj.Name
                if name:find(marker) or (obj:IsA("ModuleScript") and obj.Name:find("Admin")) then
                    local success, source = pcall(function() return obj.Source end)
                    if success and source and #source > 100 then
                        table.insert(found, {
                            system = adminDef.name,
                            location = obj:GetFullName(),
                            type = obj.ClassName,
                            exploitable = self:CheckAdminExploitability(source)
                        })
                        break
                    end
                end
            end
        end
    end
    
    return found
end

-- Check if admin system has exploitable command injection
function Scanner:CheckAdminExploitability(source)
    local exploitMarkers = {
        "Chatted:Connect.-:lower%(%).-==",  -- Chat command without auth
        "OnServerEvent:Connect.-:sub%(1",   -- Direct message parsing
        ":match%(.-%)",                     -- Pattern matching without validation
    }
    
    for _, marker in ipairs(exploitMarkers) do
        if source:find(marker) then
            return true
        end
    end
    
    return false
end

-- Analyze individual script for backdoors
function Scanner:AnalyzeScript(script)
    local results = {
        backdoors = {},
        suspicious = false,
        reason = "",
        entropy = 0
    }
    
    local success, source = pcall(function() return script.Source end)
    if not success or not source or source == "" then
        return results
    end
    
    -- Pattern matching
    for _, patternDef in ipairs(CRITICAL_PATTERNS) do
        local matches = {source:match(patternDef.pattern)}
        if #matches > 0 then
            table.insert(results.backdoors, {
                script = script:GetFullName(),
                pattern = patternDef.desc,
                type = patternDef.type,
                severity = patternDef.severity,
                line = self:FindLineNumber(source, patternDef.pattern),
                context = self:ExtractContext(source, patternDef.pattern)
            })
        end
    end
    
    for _, patternDef in ipairs(MODERATE_PATTERNS) do
        if source:find(patternDef.pattern) then
            table.insert(results.backdoors, {
                script = script:GetFullName(),
                pattern = patternDef.desc,
                severity = patternDef.severity,
                line = self:FindLineNumber(source, patternDef.pattern)
            })
        end
    end
    
    -- Obfuscation detection
    local entropy = self:CalculateEntropy(source)
    results.entropy = entropy
    
    if entropy > 4.8 then
        results.suspicious = true
        results.reason = string.format("High entropy (%.2f) - likely obfuscated", entropy)
    end
    
    -- Check for unusual string patterns
    if self:HasSuspiciousStrings(source) then
        results.suspicious = true
        results.reason = "Suspicious string patterns detected"
    end
    
    return results
end

-- Check if ModuleScript is a MainModule (common backdoor vector)
function Scanner:CheckMainModule(moduleScript)
    if moduleScript.Name:lower():find("main") then
        return true
    end
    
    local parent = moduleScript.Parent
    if parent and (parent.Name:lower():find("admin") or parent.Name:lower():find("loader")) then
        return true
    end
    
    return false
end

-- Analyze RemoteEvent/Function for vulnerabilities
function Scanner:AnalyzeRemote(remote)
    local risk = {
        path = remote:GetFullName(),
        type = remote.ClassName,
        vulnerable = false,
        severity = 0,
        reason = ""
    }
    
    -- Check parent location (exposed remotes are risky)
    local parent = remote.Parent
    if parent == game:GetService("ReplicatedStorage") then
        risk.vulnerable = true
        risk.severity = 6
        risk.reason = "Exposed in ReplicatedStorage"
    elseif parent and parent.Name:find("Remote") then
        risk.vulnerable = true
        risk.severity = 5
        risk.reason = "Located in remote folder"
    end
    
    -- Check for serverside connections (indicates active handler)
    if RunService:IsClient() then
        -- Can't verify serverside connections from client
        risk.severity = risk.severity + 2
        risk.reason = risk.reason .. " | Unknown serverside validation"
    end
    
    return risk
end

-- Scan for attribute-based payloads
function Scanner:ScanAttributes(gameInstance)
    local suspicious = {}
    
    for _, obj in ipairs(gameInstance:GetDescendants()) do
        local attributes = obj:GetAttributes()
        for name, value in pairs(attributes) do
            if type(value) == "string" then
                -- Check for encoded/suspicious data
                if #value > 100 and (
                    value:find("loadstring") or 
                    value:find("require") or
                    value:find("getfenv") or
                    self:IsBase64(value)
                ) then
                    table.insert(suspicious, {
                        instance = obj:GetFullName(),
                        attribute = name,
                        length = #value,
                        reason = "Suspicious attribute content"
                    })
                end
            end
        end
    end
    
    return suspicious
end

-- Calculate Shannon entropy
function Scanner:CalculateEntropy(text)
    if not text or #text == 0 then return 0 end
    
    local freq = {}
    for i = 1, #text do
        local char = text:sub(i, i)
        freq[char] = (freq[char] or 0) + 1
    end
    
    local entropy = 0
    local len = #text
    
    for _, count in pairs(freq) do
        local p = count / len
        entropy = entropy - (p * math.log(p) / math.log(2))
    end
    
    return entropy
end

-- Check for suspicious string patterns
function Scanner:HasSuspiciousStrings(source)
    local suspiciousPatterns = {
        string.char,     -- string.char(X,Y,Z) obfuscation
        "\\x%x%x",       -- hex escapes
        "\\%d%d%d",      -- octal escapes
        "%[%[.-%]%]",    -- long strings (can hide code)
    }
    
    local charCount = 0
    for _ in source:gmatch("string%.char%(") do
        charCount = charCount + 1
    end
    
    if charCount > 10 then
        return true
    end
    
    for i = 2, #suspiciousPatterns do
        if source:find(suspiciousPatterns[i]) then
            local matchCount = 0
            for _ in source:gmatch(suspiciousPatterns[i]) do
                matchCount = matchCount + 1
            end
            if matchCount > 5 then
                return true
            end
        end
    end
    
    return false
end

-- Check if string is base64 encoded
function Scanner:IsBase64(str)
    if #str < 20 then return false end
    
    local base64Pattern = "^[A-Za-z0-9+/]+={0,2}$"
    if str:match(base64Pattern) then
        local padding = str:match("=+$")
        return not padding or #padding <= 2
    end
    
    return false
end

-- Extract code context around pattern match
function Scanner:ExtractContext(source, pattern)
    local lines = {}
    for line in source:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    for i, line in ipairs(lines) do
        if line:find(pattern) then
            local start = math.max(1, i - 2)
            local finish = math.min(#lines, i + 2)
            local context = {}
            for j = start, finish do
                table.insert(context, lines[j])
            end
            return table.concat(context, "\n")
        end
    end
    
    return ""
end

-- Find line number of pattern match
function Scanner:FindLineNumber(source, pattern)
    local lineNum = 1
    for line in source:gmatch("[^\n]+") do
        if line:find(pattern) then
            return lineNum
        end
        lineNum = lineNum + 1
    end
    return -1
end

-- Calculate confidence level
function Scanner:CalculateConfidence(score, backdoorCount, adminCount)
    if backdoorCount >= 3 or adminCount >= 1 then
        return "VERY HIGH"
    elseif score >= 40 or backdoorCount >= 2 then
        return "HIGH"
    elseif score >= 20 or backdoorCount >= 1 then
        return "MEDIUM"
    elseif score >= 10 then
        return "LOW"
    else
        return "MINIMAL"
    end
end

-- Calculate exploitability rating
function Scanner:CalculateRating(score)
    if score >= 80 then
        return "CRITICAL"
    elseif score >= 50 then
        return "HIGH"
    elseif score >= 25 then
        return "MEDIUM"
    elseif score >= 10 then
        return "LOW"
    else
        return "CLEAN"
    end
end

-- Export scan results
function Scanner:ExportResults(results, format)
    if format == "json" then
        return HttpService:JSONEncode(results)
    elseif format == "table" then
        return results
    else
        -- Enhanced text format
        local output = {}
        table.insert(output, "═══════════════════════════════════════")
        table.insert(output, "   NEXUS VULNERABILITY SCAN REPORT")
        table.insert(output, "═══════════════════════════════════════")
        table.insert(output, string.format("Rating: %s | Confidence: %s | Score: %d", 
            results.rating, results.confidence, results.score))
        table.insert(output, string.format("Scan Time: %.2fs", results.scanTime or 0))
        table.insert(output, "")
        
        -- Admin systems
        if #results.adminSystems > 0 then
            table.insert(output, string.format("Admin Systems Detected: %d", #results.adminSystems))
            for i, admin in ipairs(results.adminSystems) do
                table.insert(output, string.format("  [%d] %s - %s", i, admin.system, admin.location))
                table.insert(output, string.format("      Exploitable: %s", admin.exploitable and "YES" or "NO"))
            end
            table.insert(output, "")
        end
        
        -- Backdoors
        if #results.backdoors > 0 then
            table.insert(output, string.format("Backdoors Found: %d", #results.backdoors))
            local shown = 0
            for i, backdoor in ipairs(results.backdoors) do
                if shown < 10 then
                    table.insert(output, string.format("  [%d] %s", i, backdoor.script))
                    table.insert(output, string.format("      Type: %s | Severity: %d | Line: %d",
                        backdoor.type or "unknown", backdoor.severity, backdoor.line))
                    if backdoor.context and #backdoor.context < 200 then
                        table.insert(output, string.format("      Context: %s", backdoor.context:gsub("\n", " ")))
                    end
                    shown = shown + 1
                end
            end
            if #results.backdoors > 10 then
                table.insert(output, string.format("  ... and %d more", #results.backdoors - 10))
            end
            table.insert(output, "")
        end
        
        -- MainModules
        if #results.mainModules > 0 then
            table.insert(output, string.format("MainModules Found: %d", #results.mainModules))
            for i, mod in ipairs(results.mainModules) do
                table.insert(output, string.format("  [%d] %s (Risk: %s)", i, mod.path, mod.risk))
            end
            table.insert(output, "")
        end
        
        -- Remotes
        if #results.remotes > 0 then
            table.insert(output, string.format("Vulnerable Remotes: %d", #results.remotes))
            local shown = 0
            for i, remote in ipairs(results.remotes) do
                if shown < 5 then
                    table.insert(output, string.format("  [%d] %s (%s) - Severity: %d", 
                        i, remote.path, remote.type, remote.severity))
                    table.insert(output, string.format("      Reason: %s", remote.reason))
                    shown = shown + 1
                end
            end
            if #results.remotes > 5 then
                table.insert(output, string.format("  ... and %d more", #results.remotes - 5))
            end
            table.insert(output, "")
        end
        
        -- Attributes
        if #results.attributes > 0 then
            table.insert(output, string.format("Suspicious Attributes: %d", #results.attributes))
            for i, attr in ipairs(results.attributes) do
                if i <= 3 then
                    table.insert(output, string.format("  [%d] %s.%s (Length: %d)",
                        i, attr.instance, attr.attribute, attr.length))
                end
            end
            if #results.attributes > 3 then
                table.insert(output, string.format("  ... and %d more", #results.attributes - 3))
            end
            table.insert(output, "")
        end
        
        table.insert(output, "═══════════════════════════════════════")
        
        return table.concat(output, "\n")
    end
end

return Scanner
