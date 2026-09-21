--[[
    Test Loader - Diagnostic Version
    Tests each step of the loading process
]]

print("=== PROJECT NEXUS DIAGNOSTIC TEST ===")

-- Test 1: Can we access GitHub?
print("[TEST 1] Testing GitHub access...")
local testUrl = "https://raw.githubusercontent.com/HyperCodez495/ProjectNexus-Roblox-Script/main/loader.lua"
local success1, result1 = pcall(function()
    return game:HttpGet(testUrl)
end)

if success1 then
    print("[TEST 1] ✓ GitHub access OK - Retrieved " .. #result1 .. " bytes")
else
    warn("[TEST 1] ✗ GitHub access FAILED: " .. tostring(result1))
    return
end

-- Test 2: Can we load main.lua?
print("[TEST 2] Testing main.lua download...")
local mainUrl = "https://raw.githubusercontent.com/HyperCodez495/ProjectNexus-Roblox-Script/main/main.lua"
local success2, mainCode = pcall(function()
    return game:HttpGet(mainUrl)
end)

if success2 then
    print("[TEST 2] ✓ main.lua downloaded - " .. #mainCode .. " bytes")
else
    warn("[TEST 2] ✗ main.lua download FAILED: " .. tostring(mainCode))
    return
end

-- Test 3: Can we compile main.lua?
print("[TEST 3] Testing main.lua compilation...")
local success3, compiledMain = pcall(function()
    return loadstring(mainCode)
end)

if success3 and compiledMain then
    print("[TEST 3] ✓ main.lua compiled successfully")
else
    warn("[TEST 3] ✗ main.lua compilation FAILED: " .. tostring(compiledMain))
    return
end

-- Test 4: Can we execute main.lua?
print("[TEST 4] Testing main.lua execution...")
local success4, Nexus = pcall(compiledMain)

if success4 then
    if Nexus then
        print("[TEST 4] ✓ main.lua executed - Type: " .. type(Nexus))
        if type(Nexus) == "table" then
            print("[TEST 4]   Nexus.new exists: " .. tostring(Nexus.new ~= nil))
        end
    else
        warn("[TEST 4] ✗ main.lua returned nil")
    end
else
    warn("[TEST 4] ✗ main.lua execution FAILED: " .. tostring(Nexus))
    return
end

-- Test 5: Can we download a core module?
print("[TEST 5] Testing core module download (scanner.lua)...")
local scannerUrl = "https://raw.githubusercontent.com/HyperCodez495/ProjectNexus-Roblox-Script/main/core/scanner.lua"
local success5, scannerCode = pcall(function()
    return game:HttpGet(scannerUrl)
end)

if success5 then
    print("[TEST 5] ✓ scanner.lua downloaded - " .. #scannerCode .. " bytes")
    
    -- Try to compile it
    local success5b, compiledScanner = pcall(function()
        return loadstring(scannerCode)
    end)
    
    if success5b and compiledScanner then
        print("[TEST 5] ✓ scanner.lua compiled successfully")
        
        -- Try to execute it
        local success5c, Scanner = pcall(compiledScanner)
        if success5c and Scanner then
            print("[TEST 5] ✓ scanner.lua executed successfully")
        else
            warn("[TEST 5] ✗ scanner.lua execution FAILED: " .. tostring(Scanner))
        end
    else
        warn("[TEST 5] ✗ scanner.lua compilation FAILED: " .. tostring(compiledScanner))
    end
else
    warn("[TEST 5] ✗ scanner.lua download FAILED: " .. tostring(scannerCode))
end

print("\n=== DIAGNOSTIC TEST COMPLETE ===")
print("If all tests passed, the main loader should work.")
print("If any test failed, the error message above shows the issue.")
