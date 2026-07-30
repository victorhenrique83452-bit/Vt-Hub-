local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local isMobileDevice = isMobile()
local screenSize = workspace.CurrentCamera.ViewportSize

local panelScale = 1
if screenSize.X < 600 then
    panelScale = 0.85
elseif screenSize.X < 900 then
    panelScale = 0.92
end

local function createPanel()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NeonPanel"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui

    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.6
    backdrop.Visible = false
    backdrop.Parent = gui

    local floatBtn = Instance.new("ImageButton")
    floatBtn.Name = "FloatButton"
    floatBtn.Size = UDim2.new(0, 56, 0, 56)
    floatBtn.Position = UDim2.new(1, -76, 1, -100)
    floatBtn.BackgroundColor3 = Color3.fromRGB(30, 203, 255)
    floatBtn.BackgroundTransparency = 0.15
    floatBtn.BorderSizePixel = 0
    floatBtn.Image = "rbxassetid://7072640987"
    floatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.ScaleType = Enum.ScaleType.Fit
    floatBtn.Parent = gui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatBtn

    local floatShadow = Instance.new("UIShadow")
    floatShadow.Color = Color3.fromRGB(30, 203, 255)
    floatShadow.Transparency = 0.5
    floatShadow.Offset = Vector2.new(0, 4)
    floatShadow.Blur = 16
    floatShadow.Parent = floatBtn

    local function pulseButton()
        local pulse = TweenService:Create(floatBtn, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.05
        })
        pulse:Play()
    end
    pulseButton()

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    local panelWidth = math.min(800, screenSize.X - 40)
    local panelHeight = math.min(520, screenSize.Y - 60)
    panel.Size = UDim2.new(0, panelWidth, 0, panelHeight)
    panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
    panel.BackgroundColor3 = Color3.fromRGB(20, 26, 36)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(30, 203, 255)
    stroke.Transparency = 0.15
    stroke.Thickness = 1
    stroke.Parent = panel

    local sidebarWidth = isMobileDevice and 60 or 200
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(16, 22, 31)
    sidebar.BackgroundTransparency = 0.3
    sidebar.BorderSizePixel = 0
    sidebar.Parent = panel

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 24)
    sidebarCorner.Parent = sidebar

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0.85, 0, 0, 1)
    divider.Position = UDim2.new(0.075, 0, 0, 60)
    divider.BackgroundColor3 = Color3.fromRGB(30, 42, 58)
    divider.BorderSizePixel = 0
    divider.Parent = sidebar

    local tabs = {"Visual", "Aim", "Performance", "Config"}
    local tabIcons = {"👁️", "🎯", "📊", "⚙️"}
    local tabButtons = {}
    local tabFrames = {}

    local function createTabButton(index, text, icon)
        local btn = Instance.new("TextButton")
        btn.Name = text
        btn.Size = UDim2.new(0.85, 0, 0, 44)
        btn.Position = UDim2.new(0.075, 0, 0, 80 + (index - 1) * 48)
        btn.BackgroundColor3 = Color3.fromRGB(28, 38, 54)
        btn.BackgroundTransparency = 0.8
        btn.BorderSizePixel = 0
        btn.Text = isMobileDevice and icon or icon .. "  " .. text
        btn.TextColor3 = Color3.fromRGB(139, 155, 181)
        btn.TextSize = isMobileDevice and 22 or 15
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.AutoButtonColor = false
        btn.Parent = sidebar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 14)
        btnCorner.Parent = btn

        return btn
    end

    for i, tab in ipairs(tabs) do
        local btn = createTabButton(i, tab, tabIcons[i])
        table.insert(tabButtons, btn)
    end

    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -(sidebarWidth + 20), 1, -24)
    content.Position = UDim2.new(0, sidebarWidth + 10, 0, 12)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = isMobileDevice and 4 or 6
    content.ScrollBarImageColor3 = Color3.fromRGB(30, 203, 255)
    content.ScrollBarImageTransparency = 0.6
    content.CanvasSize = UDim2.new(0, 0, 0, 400)
    content.Parent = panel

    local function createCard(parent, title, icon, x, y, width, height)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, width or 220, 0, height or 150)
        card.Position = UDim2.new(0, x or 0, 0, y or 0)
        card.BackgroundColor3 = Color3.fromRGB(21, 30, 43)
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 0
        card.Parent = parent

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 18)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = Color3.fromRGB(31, 43, 61)
        cardStroke.Thickness = 1
        cardStroke.Parent = card

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, -24, 0, 32)
        header.Position = UDim2.new(0, 12, 0, 10)
        header.BackgroundTransparency = 1
        header.Text = icon .. "  " .. title
        header.TextColor3 = Color3.fromRGB(182, 208, 232)
        header.TextSize = isMobileDevice and 14 or 15
        header.Font = Enum.Font.GothamSemibold
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = card

        return card
    end

    local function createSwitch(parent, x, y, defaultOn)
        local switch = Instance.new("Frame")
        local switchSize = isMobileDevice and 52 or 44
        local knobSize = isMobileDevice and 24 or 20
        switch.Size = UDim2.new(0, switchSize, 0, switchSize * 0.55)
        switch.Position = UDim2.new(0, x or 0, 0, y or 0)
        switch.BackgroundColor3 = defaultOn and Color3.fromRGB(30, 203, 255) or Color3.fromRGB(31, 43, 61)
        switch.BorderSizePixel = 0
        switch.Parent = parent

        local switchCorner = Instance.new("UICorner")
        switchCorner.CornerRadius = UDim.new(1, 0)
        switchCorner.Parent = switch

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, knobSize, 0, knobSize)
        knob.Position = defaultOn and UDim2.new(0, switchSize - knobSize - 3, 0, 2) or UDim2.new(0, 3, 0, 2)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = switch

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        local knobShadow = Instance.new("UIShadow")
        knobShadow.Color = Color3.fromRGB(30, 203, 255)
        knobShadow.Transparency = 0.6
        knobShadow.Offset = Vector2.new(0, 2)
        knobShadow.Blur = 8
        knobShadow.Parent = knob

        local function toggle()
            local isOn = switch.BackgroundColor3 == Color3.fromRGB(30, 203, 255)
            local targetColor = isOn and Color3.fromRGB(31, 43, 61) or Color3.fromRGB(30, 203, 255)
            local targetPos = isOn and UDim2.new(0, 3, 0, 2) or UDim2.new(0, switchSize - knobSize - 3, 0, 2)

            local tween1 = TweenService:Create(switch, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundColor3 = targetColor})
            local tween2 = TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Position = targetPos})
            tween1:Play()
            tween2:Play()
            
            if UserInputService.VibrateEnabled then
                UserInputService:Vibrate(50)
            end
        end

        switch.MouseButton1Click:Connect(toggle)
        switch.TouchTap:Connect(toggle)

        return switch
    end

    local function createSlider(parent, x, y, width, minVal, maxVal, defaultVal, suffix)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, width or 180, 0, 40)
        frame.Position = UDim2.new(0, x or 0, 0, y or 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Valor"
        label.TextColor3 = Color3.fromRGB(138, 163, 192)
        label.TextSize = isMobileDevice and 12 or 13
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.4, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(defaultVal) .. (suffix or "")
        valueLabel.TextColor3 = Color3.fromRGB(155, 180, 212)
        valueLabel.TextSize = isMobileDevice and 12 or 13
        valueLabel.Font = Enum.Font.GothamMedium
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, isMobileDevice and 6 or 4)
        slider.Position = UDim2.new(0, 0, 0, 30)
        slider.BackgroundColor3 = Color3.fromRGB(31, 43, 61)
        slider.BorderSizePixel = 0
        slider.Parent = frame

        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(1, 0)
        sliderCorner.Parent = slider

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(30, 203, 255)
        fill.BorderSizePixel = 0
        fill.Parent = slider

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local thumbSize = isMobileDevice and 22 or 16
        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
        thumb.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -thumbSize/2, 0, -(thumbSize/2 - (isMobileDevice and 6 or 4)/2))
        thumb.BackgroundColor3 = Color3.fromRGB(30, 203, 255)
        thumb.BorderSizePixel = 0
        thumb.Parent = slider

        local thumbCorner = Instance.new("UICorner")
        thumbCorner.CornerRadius = UDim.new(1, 0)
        thumbCorner.Parent = thumb

        local thumbShadow = Instance.new("UIShadow")
        thumbShadow.Color = Color3.fromRGB(30, 203, 255)
        thumbShadow.Transparency = 0.5
        thumbShadow.Offset = Vector2.new(0, 2)
        thumbShadow.Blur = 12
        thumbShadow.Parent = thumb

        local dragging = false

        local function updateSlider(inputPos)
            local absoluteX
            if typeof(inputPos) == "number" then
                absoluteX = inputPos
            else
                absoluteX = inputPos.X
            end
            
            local relativeX = math.clamp((absoluteX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor(minVal + relativeX * (maxVal - minVal))
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            thumb.Position = UDim2.new(relativeX, -thumbSize/2, 0, -(thumbSize/2 - (isMobileDevice and 6 or 4)/2))
            valueLabel.Text = tostring(value) .. (suffix or "")
        end

        local function startDrag(input)
            dragging = true
            updateSlider(input.Position)
            
            local connection
            if input.UserInputType == Enum.UserInputType.Touch then
                connection = UserInputService.TouchMoved:Connect(function(touch)
                    if dragging then
                        updateSlider(touch.Position)
                    end
                end)
                UserInputService.TouchEnded:Connect(function()
                    dragging = false
                    connection:Disconnect()
                end)
            else
                connection = UserInputService.InputChanged:Connect(function(inputChanged)
                    if dragging and inputChanged.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(inputChanged.Position)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inputEnded)
                    if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        connection:Disconnect()
                    end
                end)
            end
        end

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                startDrag(input)
            end
        end)

        return frame
    end

    -- ABA VISUAL
    local visualTab = Instance.new("Frame")
    visualTab.Name = "Visual"
    visualTab.Size = UDim2.new(1, 0, 1, 0)
    visualTab.BackgroundTransparency = 1
    visualTab.Visible = true
    visualTab.Parent = content
    table.insert(tabFrames, visualTab)

    local cardWidth = isMobileDevice and (panelWidth - sidebarWidth - 60) / 2 - 10 or 230
    local cardHeight = isMobileDevice and 140 or 155
    
    local espCard = createCard(visualTab, "ESP", "👻", 0, 0, cardWidth, cardHeight)
    local espSwitchX = cardWidth - 56
    createSwitch(espCard, espSwitchX, 12, true)
    createSwitch(espCard, 12, 50, true)
    createSwitch(espCard, 12, 80, false)
    createSwitch(espCard, 12, 110, true)

    local teamCard = createCard(visualTab, "Team Check", "👥", cardWidth + 12, 0, cardWidth, cardHeight)
    createSwitch(teamCard, cardWidth - 56, 12, true)
    createSwitch(teamCard, 12, 50, false)
    createSwitch(teamCard, 12, 80, true)
    createSwitch(teamCard, 12, 110, true)

    local gfxCard = createCard(visualTab, "Graphics", "🎨", 0, cardHeight + 12, cardWidth, cardHeight)
    
    local qualityBtn = Instance.new("TextButton")
    qualityBtn.Size = UDim2.new(0.8, 0, 0, isMobileDevice and 32 or 28)
    qualityBtn.Position = UDim2.new(0.1, 0, 0, isMobileDevice and 50 or 45)
    qualityBtn.BackgroundColor3 = Color3.fromRGB(16, 26, 38)
    qualityBtn.BorderSizePixel = 0
    qualityBtn.Text = "Alta"
    qualityBtn.TextColor3 = Color3.fromRGB(208, 226, 255)
    qualityBtn.TextSize = isMobileDevice and 12 or 13
    qualityBtn.Font = Enum.Font.GothamMedium
    qualityBtn.Parent = gfxCard

    local qCorner = Instance.new("UICorner")
    qCorner.CornerRadius = UDim.new(1, 0)
    qCorner.Parent = qualityBtn

    local shadowBtn = Instance.new("TextButton")
    shadowBtn.Size = UDim2.new(0.8, 0, 0, isMobileDevice and 32 or 28)
    shadowBtn.Position = UDim2.new(0.1, 0, 0, isMobileDevice and 90 or 85)
    shadowBtn.BackgroundColor3 = Color3.fromRGB(16, 26, 38)
    shadowBtn.BorderSizePixel = 0
    shadowBtn.Text = "Média"
    shadowBtn.TextColor3 = Color3.fromRGB(208, 226, 255)
    shadowBtn.TextSize = isMobileDevice and 12 or 13
    shadowBtn.Font = Enum.Font.GothamMedium
    shadowBtn.Parent = gfxCard

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(1, 0)
    sCorner.Parent = shadowBtn

    -- ABA AIM
    local aimTab = Instance.new("Frame")
    aimTab.Name = "Aim"
    aimTab.Size = UDim2.new(1, 0, 1, 0)
    aimTab.BackgroundTransparency = 1
    aimTab.Visible = false
    aimTab.Parent = content
    table.insert(tabFrames, aimTab)

    local aimCard = createCard(aimTab, "Aim Assist", "🎯", 0, 0, cardWidth, 175)
    createSwitch(aimCard, cardWidth - 56, 12, true)
    createSwitch(aimCard, 12, 50, true)
    createSlider(aimCard, 12, 85, cardWidth - 24, 0, 100, 78, "%")

    local fovCard = createCard(aimTab, "FOV", "🔭", cardWidth + 12, 0, cardWidth, 175)
    createSlider(fovCard, 12, 45, cardWidth - 24, 0, 120, 82, "°")
    createSwitch(fovCard, 12, 120, true)

    -- ABA PERFORMANCE
    local perfTab = Instance.new("Frame")
    perfTab.Name = "Performance"
    perfTab.Size = UDim2.new(1, 0, 1, 0)
    perfTab.BackgroundTransparency = 1
    perfTab.Visible = false
    perfTab.Parent = content
    table.insert(tabFrames, perfTab)

    local fpsCard = createCard(perfTab, "FPS", "📈", 0, 0, cardWidth, 155)
    createSlider(fpsCard, 12, 45, cardWidth - 24, 30, 240, 144, " FPS")
    createSwitch(fpsCard, 12, 110, false)

    local perfGfxCard = createCard(perfTab, "Graphics", "⚡", cardWidth + 12, 0, cardWidth, 155)
    createSlider(perfGfxCard, 12, 45, cardWidth - 24, 0, 100, 65, "%")
    createSwitch(perfGfxCard, 12, 110, true)

    -- ABA CONFIG
    local configTab = Instance.new("Frame")
    configTab.Name = "Configurações"
    configTab.Size = UDim2.new(1, 0, 1, 0)
    configTab.BackgroundTransparency = 1
    configTab.Visible = false
    configTab.Parent = content
    table.insert(tabFrames, configTab)

    local profileCard = createCard(configTab, "Perfil", "👤", 0, 0, cardWidth, 155)
    local profileBtn = Instance.new("TextButton")
    profileBtn.Size = UDim2.new(0.8, 0, 0, isMobileDevice and 32 or 28)
    profileBtn.Position = UDim2.new(0.1, 0, 0, isMobileDevice and 50 or 45)
    profileBtn.BackgroundColor3 = Color3.fromRGB(16, 26, 38)
    profileBtn.BorderSizePixel = 0
    profileBtn.Text = "Competitivo"
    profileBtn.TextColor3 = Color3.fromRGB(208, 226, 255)
    profileBtn.TextSize = isMobileDevice and 12 or 13
    profileBtn.Font = Enum.Font.GothamMedium
    profileBtn.Parent = profileCard

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = profileBtn

    createSwitch(profileCard, 12, 100, true)

    local hotkeyCard = createCard(configTab, "Hotkeys", "⌨️", cardWidth + 12, 0, cardWidth, 155)
    
    local function createKeyDisplay(parent, label, key, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.9, 0, 0, 30)
        frame.Position = UDim2.new(0.05, 0, 0, y or 40)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(138, 163, 192)
        lbl.TextSize = isMobileDevice and 12 or 13
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local keyFrame = Instance.new("Frame")
        keyFrame.Size = UDim2.new(0, 50, 0, 24)
        keyFrame.Position = UDim2.new(0.5, 0, 0.5, -12)
        keyFrame.BackgroundColor3 = Color3.fromRGB(26, 37, 55)
        keyFrame.BorderSizePixel = 0
        keyFrame.Parent = frame

        local kfCorner = Instance.new("UICorner")
        kfCorner.CornerRadius = UDi
