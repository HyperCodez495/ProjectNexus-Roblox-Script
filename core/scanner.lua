--[[
    Project Nexus - Game Scanner Module
    Scans Roblox games for backdoor vulnerabilities and exploitable RemoteEvents
]]

local Scanner = {}
Scanner.__index = Scanner

-- Detection patterns for backdoor identification
local BACKDOOR_PATTERNS = {
    "require%(%d+%)",  -- require(assetID)
    "require%(game:GetService",
    "loadstring%(game:HttpGet",
    "loadstring%(syn%.request",
    "getfenv%(0%)",
    "setfenv%(",
    "getrawmetatable",
    "hookmetamethod",
    "Pose%.Value",  -- Common backdoor attribute storage
    "_G%[",  -- Global table manipulation
    "shared%[",  -- Shared table exploitation
}

-- Vulnerable RemoteEvent patterns
local REMOTE_PATTERNS = {
    "FireServer%(.-%)$",  -- RemoteEvents without validation
    "InvokeServer%(.-%)$",  -- RemoteFunctions
    "OnServerEvent:Connect",
}

function Scanner.new()
    local self = setmetatable({}, Scanner)
    self.foundBackdoors = {}
    self.vulnerableRemotes = {}
    self.scannedGames = {}
    return self
end

-- Scan a game instance for backdoors
function Scanner:ScanGame(gameInstance)
    local results = {
        backdoors = {},
        remotes = {},
        suspiciousScripts = {},
        score = 0  -- Exploitability score
    }
    
    -- Recursively scan all descendants
    for _, obj in ipairs(gameInstance:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source then
                -- Check for backdoor patterns
                for _, pattern in ipairs(BACKDOOR_PATTERNS) do
                    if source:match(pattern) then
                        table.insert(results.backdoors, {
                            script = obj:GetFullName(),
                            pattern = pattern,
                            line = self:FindLineNumber(source, pattern)
                        })
                        results.score = results.score + 10
                    end
                end
                
                -- Check for obfuscation (high entropy, unusual character frequency)
                if self:IsObfuscated(source) then
                    table.insert(results.suspiciousScripts, {
                        script = obj:GetFullName(),
                        reason = "Obfuscated code detected"
                    })
                    results.score = results.score + 5
                end
            end
        end
        
        -- Check RemoteEvents and RemoteFunctions
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local parent = obj.Parent
            table.insert(results.remotes, {
                remote = obj:GetFullName(),
                type = obj.ClassName,
                accessible = true
            })
            results.score = results.score + 3
        end
    end
    
    -- Calculate final exploitability rating
    results.rating = self:CalculateRating(results.score)
    
    return results
end

-- Detect obfuscated code using entropy analysis
function Scanner:IsObfuscated(source)
    local charFreq = {}
    local totalChars = #source
    
    -- Calculate character frequency
    for i = 1, totalChars do
        local char = source:sub(i, i)
        charFreq[char] = (charFreq[char] or 0) + 1
    end
    
    -- Calculate Shannon entropy
    local entropy = 0
    for char, count in pairs(charFreq) do
        local probability = count / totalChars
        entropy = entropy - (probability * math.log(probability, 2))
    end
    
    -- High entropy indicates obfuscation (threshold: 4.5)
    return entropy > 4.5
end

-- Find line number of pattern match
function Scanner:FindLineNumber(source, pattern)
    local lineNum = 1
    for line in source:gmatch("[^\n]+") do
        if line:match(pattern) then
            return lineNum
        end
        lineNum = lineNum + 1
    end
    return -1
end

-- Calculate exploitability rating
function Scanner:CalculateRating(score)
    if score >= 50 then
        return "CRITICAL"
    elseif score >= 30 then
        return "HIGH"
    elseif score >= 15 then
        return "MEDIUM"
    elseif score >= 5 then
        return "LOW"
    else
        return "CLEAN"
    end
end

-- Scan for specific backdoor asset IDs (known malicious modules)
function Scanner:ScanForKnownBackdoors(gameInstance)
    local knownMalicious = {}
    
    for _, obj in ipairs(gameInstance:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("ModuleScript") then
            local success, source = pcall(function() return obj.Source end)
            if success and source then
                -- Extract require() asset IDs
                for assetId in source:gmatch("require%((%d+)%)") do
                    table.insert(knownMalicious, {
                        script = obj:GetFullName(),
                        assetId = assetId,
                        type = "require_injection"
                    })
                end
            end
        end
    end
    
    return knownMalicious
end

-- Network traffic analysis for RemoteEvent monitoring
function Scanner:MonitorRemoteTraffic(remote, duration)
    local trafficLog = {}
    local startTime = tick()
    
    -- Hook RemoteEvent fires
    local connection = remote.OnServerEvent:Connect(function(player, ...)
        local args = {...}
        table.insert(trafficLog, {
            timestamp = tick() - startTime,
            player = player.Name,
            arguments = args
        })
    end)
    
    -- Monitor for specified duration
    task.wait(duration or 10)
    connection:Disconnect()
    
    return trafficLog
end

-- Export scan results to structured format
function Scanner:ExportResults(results, format)
    if format == "json" then
        return game:GetService("HttpService"):JSONEncode(results)
    elseif format == "table" then
        return results
    else
        -- Plain text format
        local output = "=== Project Nexus Scan Results ===\n"
        output = output .. string.format("Rating: %s (Score: %d)\n", results.rating, results.score)
        output = output .. string.format("\nBackdoors Found: %d\n", #results.backdoors)
        for _, backdoor in ipairs(results.backdoors) do
            output = output .. string.format("  - %s [%s] Line %d\n", 
                backdoor.script, backdoor.pattern, backdoor.line)
        end
        output = output .. string.format("\nVulnerable Remotes: %d\n", #results.remotes)
        for _, remote in ipairs(results.remotes) do
            output = output .. string.format("  - %s (%s)\n", remote.remote, remote.type)
        end
        return output
    end
end

return Scanner
