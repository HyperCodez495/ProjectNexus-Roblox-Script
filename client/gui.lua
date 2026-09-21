--[[
    Nexus Client - Professional UI
    Modern interface for serverside control
]]

local Nexus = _G.NexusInstance
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- Theme colors
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(24, 24, 28),
    Elevated = Color3.fromRGB(30, 30, 35),
    Border = Color3.fromRGB(45, 45, 50),
    
    Primary = Color3.fromRGB(99, 102, 241),  -- Indigo
    PrimaryDark = Color3.fromRGB(79, 82, 221),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 146, 60),
    Danger = Color3.fromRGB(239, 68, 68),
    
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    TextMuted = Color3.fromRGB(110, 110, 120),
}

local GUI = {}
GUI.__index = GUI

function GUI.new()
    local self = setmetatable({}, GUI)
    self.screenGui = nil
    self.container = nil
    self.visible = false
    self.currentTab = "executor"
    self.animations = {}
    return self
end

-- Create main interface
function GUI:Create()
    local player = game:GetService("Players").LocalPlayer
    
    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 720, 0, 480)
    container.Position = UDim2.new(0.5, -360, 0.5, -240)
    container.BackgroundColor3 = Theme.Background
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = sg
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = 0
    shadow.Parent = container
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Theme.Surface
    header.BorderSizePixel = 0
    header.Parent = container
    
    -- Header accent line
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 1, 0)
    accent.BackgroundColor3 = Theme.Primary
    accent.BorderSizePixel = 0
    accent.Parent = header
    
    -- Logo/Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "NEXUS"
    title.TextColor3 = Theme.TextPrimary
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Version badge
    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Size = UDim2.new(0, 40, 0, 18)
    version.Position = UDim2.new(0, 90, 0.5, -9)
    version.BackgroundColor3 = Theme.Primary
    version.Font = Enum.Font.Gotham
    version.Text = "v2.0"
    version.TextColor3 = Theme.TextPrimary
    version.TextSize = 10
    version.Parent = header
    
    -- Status indicator
    local statusContainer = Instance.new("Frame")
    statusContainer.Name = "Status"
    statusContainer.Size = UDim2.new(0, 120, 0, 24)
    statusContainer.Position = UDim2.new(1, -140, 0.5, -12)
    statusContainer.BackgroundColor3 = Theme.Elevated
    statusContainer.BorderSizePixel = 0
    statusContainer.Parent = header
    
    local statusDot = Instance.new("Frame")
    statusDot.Name = "Dot"
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 8, 0.5, -4)
    statusDot.BackgroundColor3 = Theme.TextMuted
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusContainer
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = statusDot
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "Text"
    statusText.Size = UDim2.new(1, -24, 1, 0)
    statusText.Position = UDim2.new(0, 24, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.Gotham
    statusText.Text = "IDLE"
    statusText.TextColor3 = Theme.TextSecondary
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusContainer
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
    closeBtn.BackgroundColor3 = Theme.Elevated
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.TextSize = 20
    closeBtn.Parent = header
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover effect
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Danger}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Elevated}):Play()
    end)
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, -48)
    sidebar.Position = UDim2.new(0, 0, 0, 48)
    sidebar.BackgroundColor3 = Theme.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    
    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -180, 1, -48)
    content.Position = UDim2.new(0, 180, 0, 48)
    content.BackgroundColor3 = Theme.Background
    content.BorderSizePixel = 0
    content.Parent = container
    
    -- Create tabs
    self:CreateTabButton("Executor", "rbxassetid://4489494891", sidebar, 0)
    self:CreateTabButton("Scanner", "rbxassetid://4489494891", sidebar, 1)
    self:CreateTabButton("Commands", "rbxassetid://4489494891", sidebar, 2)
    self:CreateTabButton("Status", "rbxassetid://4489494891", sidebar, 3)
    
    -- Create tab contents
    self:CreateExecutorContent(content)
    self:CreateScannerContent(content)
    self:CreateCommandsContent(content)
    self:CreateStatusContent(content)
    
    -- Make draggable
    self:MakeDraggable(container, header)
    
    -- Parent to PlayerGui
    sg.Parent = player:WaitForChild("PlayerGui")
    
    self.screenGui = sg
    self.container = container
    self.statusDot = statusDot
    self.statusText = statusText
    
    -- Start status updates
    self:StartStatusUpdates()
    
    -- Show executor tab by default
    self:SwitchTab("executor")
    
    return self
end

-- Create tab button
function GUI:CreateTabButton(name, icon, parent, index)
    local btn = Instance.new("TextButton")
    btn.Name = name:lower()
    btn.Size = UDim2.new(1, -16, 0, 42)
    btn.Position = UDim2.new(0, 8, 0, 8 + (index * 48))
    btn.BackgroundColor3 = Theme.Background
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.Gotham
    btn.Text = ""
    btn.Parent = parent
    
    -- Selection indicator
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = Theme.Primary
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    -- Click handler
    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(name:lower())
    end)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        if self.currentTab ~= name:lower() then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Elevated}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if self.currentTab ~= name:lower() then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end)
    
    return btn
end

-- Create executor content
function GUI:CreateExecutorContent(parent)
    local frame = Instance.new("Frame")
    frame.Name = "executor_content"
    frame.Size = UDim2.new(1, -32, 1, -32)
    frame.Position = UDim2.new(0, 16, 0, 16)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = parent
    
    -- Code editor
    local editorBg = Instance.new("Frame")
    editorBg.Name = "EditorBg"
    editorBg.Size = UDim2.new(1, 0, 1, -54)
    editorBg.BackgroundColor3 = Theme.Surface
    editorBg.BorderSizePixel = 0
    editorBg.Parent = frame
    
    local editor = Instance.new("TextBox")
    editor.Name = "Editor"
    editor.Size = UDim2.new(1, -16, 1, -16)
    editor.Position = UDim2.new(0, 8, 0, 8)
    editor.BackgroundTransparency = 1
    editor.Font = Enum.Font.Code
    editor.PlaceholderText = "-- Enter code here..."
    editor.Text = ""
    editor.TextColor3 = Theme.TextPrimary
    editor.TextSize = 14
    editor.TextXAlignment = Enum.TextXAlignment.Left
    editor.TextYAlignment = Enum.TextYAlignment.Top
    editor.ClearTextOnFocus = false
    editor.MultiLine = true
    editor.Parent = editorBg
    
    -- Button container
    local btnContainer = Instance.new("Frame")
    btnContainer.Name = "Buttons"
    btnContainer.Size = UDim2.new(1, 0, 0, 40)
    btnContainer.Position = UDim2.new(0, 0, 1, -48)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = frame
    
    -- Execute button
    local execBtn = self:CreateButton("Execute", UDim2.new(0, 120, 1, 0), UDim2.new(0, 0, 0, 0), Theme.Primary)
    execBtn.Parent = btnContainer
    
    execBtn.MouseButton1Click:Connect(function()
        local code = editor.Text
        if Nexus and code ~= "" then
            local success, result = Nexus:Execute(code)
            if success then
                self:ShowNotification("Code executed successfully", Theme.Success)
            else
                self:ShowNotification("Execution failed: " .. tostring(result), Theme.Danger)
            end
        end
    end)
    
    -- Clear button
    local clearBtn = self:CreateButton("Clear", UDim2.new(0, 100, 1, 0), UDim2.new(0, 128, 0, 0), Theme.Elevated)
    clearBtn.Parent = btnContainer
    
    clearBtn.MouseButton1Click:Connect(function()
        editor.Text = ""
    end)
    
    return frame
end

-- Create scanner content
function GUI:CreateScannerContent(parent)
    local frame = Instance.new("Frame")
    frame.Name = "scanner_content"
    frame.Size = UDim2.new(1, -32, 1, -32)
    frame.Position = UDim2.new(0, 16, 0, 16)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = parent
    
    -- Scan button
    local scanBtn = self:CreateButton("Start Scan", UDim2.new(0, 140, 0, 40), UDim2.new(0, 0, 0, 0), Theme.Primary)
    scanBtn.Parent = frame
    
    -- Results area
    local resultsBg = Instance.new("Frame")
    resultsBg.Name = "ResultsBg"
    resultsBg.Size = UDim2.new(1, 0, 1, -56)
    resultsBg.Position = UDim2.new(0, 0, 0, 48)
    resultsBg.BackgroundColor3 = Theme.Surface
    resultsBg.BorderSizePixel = 0
    resultsBg.Parent = frame
    
    local resultsScroll = Instance.new("ScrollingFrame")
    resultsScroll.Name = "Results"
    resultsScroll.Size = UDim2.new(1, -16, 1, -16)
    resultsScroll.Position = UDim2.new(0, 8, 0, 8)
    resultsScroll.BackgroundTransparency = 1
    resultsScroll.BorderSizePixel = 0
    resultsScroll.ScrollBarThickness = 4
    resultsScroll.ScrollBarImageColor3 = Theme.Border
    resultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    resultsScroll.Parent = resultsBg
    
    local resultsText = Instance.new("TextLabel")
    resultsText.Name = "Text"
    resultsText.Size = UDim2.new(1, 0, 1, 0)
    resultsText.BackgroundTransparency = 1
    resultsText.Font = Enum.Font.Code
    resultsText.Text = "Click 'Start Scan' to analyze the current game for vulnerabilities"
    resultsText.TextColor3 = Theme.TextSecondary
    resultsText.TextSize = 12
    resultsText.TextXAlignment = Enum.TextXAlignment.Left
    resultsText.TextYAlignment = Enum.TextYAlignment.Top
    resultsText.TextWrapped = true
    resultsText.Parent = resultsScroll
    
    scanBtn.MouseButton1Click:Connect(function()
        resultsText.Text = "Scanning game... This may take a moment."
        task.wait(0.1)
        
        if Nexus then
            local results = Nexus:ScanCurrentGame()
            if results and Nexus.scanner then
                local output = Nexus.scanner:ExportResults(results, "text")
                resultsText.Text = output
                
                -- Adjust canvas size
                local textSize = TextService:GetTextSize(output, 12, Enum.Font.Code, Vector2.new(resultsScroll.AbsoluteSize.X, math.huge))
                resultsScroll.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 16)
            end
        end
    end)
    
    return frame
end

-- Create commands content
function GUI:CreateCommandsContent(parent)
    local frame = Instance.new("Frame")
    frame.Name = "commands_content"
    frame.Size = UDim2.new(1, -32, 1, -32)
    frame.Position = UDim2.new(0, 16, 0, 16)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = parent
    
    -- Target input
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0, 100, 0, 32)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Font = Enum.Font.GothamMedium
    targetLabel.Text = "Target Player:"
    targetLabel.TextColor3 = Theme.TextPrimary
    targetLabel.TextSize = 13
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = frame
    
    local targetBg = Instance.new("Frame")
    targetBg.Size = UDim2.new(1, -110, 0, 32)
    targetBg.Position = UDim2.new(0, 110, 0, 0)
    targetBg.BackgroundColor3 = Theme.Surface
    targetBg.BorderSizePixel = 0
    targetBg.Parent = frame
    
    local targetInput = Instance.new("TextBox")
    targetInput.Name = "TargetInput"
    targetInput.Size = UDim2.new(1, -16, 1, 0)
    targetInput.Position = UDim2.new(0, 8, 0, 0)
    targetInput.BackgroundTransparency = 1
    targetInput.Font = Enum.Font.Gotham
    targetInput.PlaceholderText = "Username"
    targetInput.Text = ""
    targetInput.TextColor3 = Theme.TextPrimary
    targetInput.TextSize = 13
    targetInput.TextXAlignment = Enum.TextXAlignment.Left
    targetInput.Parent = targetBg
    
    -- Command grid
    local commands = {
        {name = "Kill", cmd = "kill", color = Theme.Danger},
        {name = "Kick", cmd = "kick", color = Theme.Warning},
        {name = "Ban", cmd = "ban", color = Theme.Danger},
        {name = "Inject Admin", cmd = "admin", color = Theme.Primary},
        {name = "Crash Server", cmd = "crash", color = Theme.Danger},
        {name = "Give God", cmd = "god", color = Theme.Success},
    }
    
    for i, cmdInfo in ipairs(commands) do
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3
        
        local btn = self:CreateButton(cmdInfo.name, UDim2.new(0, 160, 0, 40), 
            UDim2.new(0, col * 168, 0, 48 + row * 48), cmdInfo.color)
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            local target = targetInput.Text
            if Nexus and target ~= "" then
                Nexus:Command(cmdInfo.cmd, target)
                self:ShowNotification(cmdInfo.name .. " executed on " .. target, Theme.Success)
            end
        end)
    end
    
    return frame
end

-- Create status content
function GUI:CreateStatusContent(parent)
    local frame = Instance.new("Frame")
    frame.Name = "status_content"
    frame.Size = UDim2.new(1, -32, 1, -32)
    frame.Position = UDim2.new(0, 16, 0, 16)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = parent
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Code
    statusLabel.Text = "Loading system status..."
    statusLabel.TextColor3 = Theme.TextPrimary
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Parent = frame
    
    return frame
end

-- Create button
function GUI:CreateButton(text, size, position, color)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Theme.TextPrimary
    btn.TextSize = 13
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = self:LightenColor(color, 1.2)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
    end)
    
    return btn
end

-- Switch tabs
function GUI:SwitchTab(tabName)
    self.currentTab = tabName
    
    -- Update sidebar buttons
    local sidebar = self.container:FindFirstChild("Sidebar")
    if sidebar then
        for _, btn in ipairs(sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                local indicator = btn:FindFirstChild("Indicator")
                local label = btn:FindFirstChild("Label")
                
                if btn.Name == tabName then
                    -- Active state
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Elevated}):Play()
                    if indicator then
                        indicator.Visible = true
                        TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 1, 0)}):Play()
                    end
                    if label then
                        TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Theme.TextPrimary}):Play()
                    end
                else
                    -- Inactive state
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    if indicator then
                        indicator.Visible = false
                        indicator.Size = UDim2.new(0, 3, 0, 0)
                    end
                    if label then
                        TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
                    end
                end
            end
        end
    end
    
    -- Update content visibility
    local content = self.container:FindFirstChild("Content")
    if content then
        for _, child in ipairs(content:GetChildren()) do
            if child.Name:find("_content$") then
                child.Visible = (child.Name == tabName .. "_content")
            end
        end
    end
end

-- Make frame draggable
function GUI:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Toggle visibility
function GUI:Toggle()
    self.visible = not self.visible
    self.container.Visible = self.visible
end

-- Show notification
function GUI:ShowNotification(text, color)
    -- Simple notification system
    print("[NEXUS] " .. text)
end

-- Start status updates
function GUI:StartStatusUpdates()
    spawn(function()
        while self.screenGui do
            if Nexus then
                local status = Nexus:GetStatus()
                
                if status.compromised then
                    self.statusDot.BackgroundColor3 = Theme.Success
                    self.statusText.Text = "COMPROMISED"
                elseif status.initialized then
                    self.statusDot.BackgroundColor3 = Theme.Warning
                    self.statusText.Text = "ACTIVE"
                else
                    self.statusDot.BackgroundColor3 = Theme.TextMuted
                    self.statusText.Text = "IDLE"
                end
            end
            
            wait(2)
        end
    end)
end

-- Utility: Lighten color
function GUI:LightenColor(color, factor)
    return Color3.new(
        math.min(color.R * factor, 1),
        math.min(color.G * factor, 1),
        math.min(color.B * factor, 1)
    )
end

return GUI
