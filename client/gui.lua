--[[
    Project Nexus - Client GUI
    User interface for controlling the serverside executor
]]

local Nexus = _G.NexusInstance or require(script.Parent.Parent.main)

local GUI = {}
GUI.__index = GUI

function GUI.new()
    local self = setmetatable({}, GUI)
    self.screenGui = nil
    self.mainFrame = nil
    self.visible = false
    return self
end

-- Create GUI interface
function GUI:Create()
    local player = game:GetService("Players").LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "PROJECT NEXUS"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Status indicator
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Name = "StatusIndicator"
    statusIndicator.Size = UDim2.new(0, 12, 0, 12)
    statusIndicator.Position = UDim2.new(1, -60, 0.5, -6)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    statusIndicator.BorderSizePixel = 0
    statusIndicator.Parent = titleBar
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = statusIndicator
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 35)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -100)
    contentArea.Position = UDim2.new(0, 10, 0, 90)
    contentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentArea
    
    -- Create tabs
    self:CreateExecutorTab(tabContainer, contentArea)
    self:CreateScannerTab(tabContainer, contentArea)
    self:CreateCommandsTab(tabContainer, contentArea)
    self:CreateStatusTab(tabContainer, contentArea)
    
    -- Make draggable
    self:MakeDraggable(mainFrame, titleBar)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Parent to player GUI
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    self.screenGui = screenGui
    self.mainFrame = mainFrame
    self.statusIndicator = statusIndicator
    
    -- Update status indicator
    self:UpdateStatus()
    
    return self
end

-- Create Executor tab
function GUI:CreateExecutorTab(tabContainer, contentArea)
    local tab = self:CreateTab("Executor", tabContainer, 0)
    local content = Instance.new("Frame")
    content.Name = "ExecutorContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = true
    content.Parent = contentArea
    
    -- Code input
    local codeInput = Instance.new("TextBox")
    codeInput.Name = "CodeInput"
    codeInput.Size = UDim2.new(1, -20, 1, -60)
    codeInput.Position = UDim2.new(0, 10, 0, 10)
    codeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    codeInput.BorderSizePixel = 0
    codeInput.Font = Enum.Font.Code
    codeInput.Text = "-- Enter Lua code here\nprint('Hello from Nexus')"
    codeInput.TextColor3 = Color3.fromRGB(200, 200, 200)
    codeInput.TextSize = 14
    codeInput.TextXAlignment = Enum.TextXAlignment.Left
    codeInput.TextYAlignment = Enum.TextYAlignment.Top
    codeInput.ClearTextOnFocus = false
    codeInput.MultiLine = true
    codeInput.Parent = content
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = codeInput
    
    -- Execute button
    local executeBtn = self:CreateButton("Execute", UDim2.new(0, 150, 0, 35), 
        UDim2.new(0, 10, 1, -45), Color3.fromRGB(50, 150, 50))
    executeBtn.Parent = content
    
    executeBtn.MouseButton1Click:Connect(function()
        local code = codeInput.Text
        if code and code ~= "" then
            local success, result = Nexus:Execute(code)
            if success then
                codeInput.Text = "-- Executed successfully\n-- Result: " .. tostring(result)
            else
                codeInput.Text = "-- Execution failed\n-- Error: " .. tostring(result)
            end
        end
    end)
    
    -- Clear button
    local clearBtn = self:CreateButton("Clear", UDim2.new(0, 100, 0, 35),
        UDim2.new(0, 170, 1, -45), Color3.fromRGB(150, 50, 50))
    clearBtn.Parent = content
    
    clearBtn.MouseButton1Click:Connect(function()
        codeInput.Text = ""
    end)
    
    return content
end

-- Create Scanner tab
function GUI:CreateScannerTab(tabContainer, contentArea)
    local tab = self:CreateTab("Scanner", tabContainer, 1)
    local content = Instance.new("ScrollingFrame")
    content.Name = "ScannerContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.Visible = false
    content.Parent = contentArea
    
    -- Scan button
    local scanBtn = self:CreateButton("Scan Game", UDim2.new(0, 150, 0, 35),
        UDim2.new(0, 10, 0, 10), Color3.fromRGB(50, 100, 200))
    scanBtn.Parent = content
    
    -- Results area
    local resultsLabel = Instance.new("TextLabel")
    resultsLabel.Name = "Results"
    resultsLabel.Size = UDim2.new(1, -20, 1, -60)
    resultsLabel.Position = UDim2.new(0, 10, 0, 55)
    resultsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    resultsLabel.BorderSizePixel = 0
    resultsLabel.Font = Enum.Font.Code
    resultsLabel.Text = "Click 'Scan Game' to begin"
    resultsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    resultsLabel.TextSize = 12
    resultsLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultsLabel.TextYAlignment = Enum.TextYAlignment.Top
    resultsLabel.Parent = content
    
    scanBtn.MouseButton1Click:Connect(function()
        resultsLabel.Text = "Scanning..."
        local results = Nexus:ScanCurrentGame()
        if results then
            resultsLabel.Text = Nexus.scanner:ExportResults(results, "text")
        end
    end)
    
    return content
end

-- Create Commands tab
function GUI:CreateCommandsTab(tabContainer, contentArea)
    local tab = self:CreateTab("Commands", tabContainer, 2)
    local content = Instance.new("Frame")
    content.Name = "CommandsContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = contentArea
    
    local yPos = 10
    
    -- Player target input
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0, 100, 0, 30)
    targetLabel.Position = UDim2.new(0, 10, 0, yPos)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Text = "Target Player:"
    targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetLabel.TextSize = 12
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = content
    
    local targetInput = Instance.new("TextBox")
    targetInput.Name = "TargetInput"
    targetInput.Size = UDim2.new(1, -120, 0, 30)
    targetInput.Position = UDim2.new(0, 110, 0, yPos)
    targetInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    targetInput.BorderSizePixel = 0
    targetInput.Font = Enum.Font.Gotham
    targetInput.PlaceholderText = "Enter player name"
    targetInput.Text = ""
    targetInput.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetInput.TextSize = 12
    targetInput.Parent = content
    
    yPos = yPos + 45
    
    -- Command buttons
    local commands = {
        {name = "Kill Player", cmd = "kill", color = Color3.fromRGB(200, 50, 50)},
        {name = "Kick Player", cmd = "kick", color = Color3.fromRGB(200, 100, 50)},
        {name = "Ban Player", cmd = "ban", color = Color3.fromRGB(150, 50, 50)},
        {name = "Inject Admin", cmd = "admin", color = Color3.fromRGB(50, 150, 200)},
        {name = "Crash Server", cmd = "crash", color = Color3.fromRGB(255, 50, 50)},
    }
    
    for i, cmdInfo in ipairs(commands) do
        local btn = self:CreateButton(cmdInfo.name, UDim2.new(0, 170, 0, 35),
            UDim2.new(0, 10 + ((i-1) % 3) * 180, 0, yPos + math.floor((i-1) / 3) * 45),
            cmdInfo.color)
        btn.Parent = content
        
        btn.MouseButton1Click:Connect(function()
            local target = targetInput.Text
            Nexus:Command(cmdInfo.cmd, target)
        end)
    end
    
    return content
end

-- Create Status tab
function GUI:CreateStatusTab(tabContainer, contentArea)
    local tab = self:CreateTab("Status", tabContainer, 3)
    local content = Instance.new("TextLabel")
    content.Name = "StatusContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Font = Enum.Font.Code
    content.Text = "Loading status..."
    content.TextColor3 = Color3.fromRGB(200, 200, 200)
    content.TextSize = 12
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.Visible = false
    content.Parent = contentArea
    
    return content
end

-- Create tab button
function GUI:CreateTab(name, parent, index)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Tab"
    tab.Size = UDim2.new(0, 120, 0, 30)
    tab.Position = UDim2.new(0, index * 125, 0, 0)
    tab.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tab.BorderSizePixel = 0
    tab.Font = Enum.Font.GothamBold
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(150, 150, 150)
    tab.TextSize = 12
    tab.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tab
    
    tab.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    return tab
end

-- Create button
function GUI:CreateButton(text, size, position, color)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    return button
end

-- Switch between tabs
function GUI:SwitchTab(tabName)
    local contentArea = self.mainFrame:FindFirstChild("ContentArea")
    if not contentArea then return end
    
    for _, child in ipairs(contentArea:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("ScrollingFrame") then
            child.Visible = child.Name == tabName .. "Content"
        end
    end
end

-- Make frame draggable
function GUI:MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Toggle GUI visibility
function GUI:Toggle()
    self.visible = not self.visible
    self.mainFrame.Visible = self.visible
end

-- Update status indicator
function GUI:UpdateStatus()
    if not self.statusIndicator then return end
    
    spawn(function()
        while self.screenGui do
            local status = Nexus:GetStatus()
            if status.compromised then
                self.statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            elseif status.connected then
                self.statusIndicator.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
            else
                self.statusIndicator.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
            wait(2)
        end
    end)
end

return GUI
