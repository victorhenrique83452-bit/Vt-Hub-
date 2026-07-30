local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    AimbotEnabled = false,
    FOV = 90,
    ESPEnabled = true,
    TeamCheck = true,
    PlayerESP = true,
    NameESP = true,
    DistanceESP = true,
    TracerESP = false,
    HealthESP = true,
    WallCheck = true,
    AimPart = "Head",
    AimSmoothness = 4,
    EnableCircle = true,
    CircleSize = 150,
    CircleThickness = 4,
    CircleTransparency = 0,
    ExcludeList = {},
}

local espObjects = {}
local fovCircle = nil

local function IsVisible(character, targetPart)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    local ray = workspace:Raycast(origin, (targetPart.Position - origin), raycastParams)
    if not ray then return true end
    if ray.Instance and (ray.Instance == targetPart or ray.Instance:IsDescendantOf(character)) then return true end
    return false
end

local function CreateESP(player)
    if espObjects[player] then return end
    local esp = {
        Box = Drawing.new("Square"),
        HealthBar = Drawing.new("Line"),
        HealthBg = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
    }
    esp.Box.Thickness = 2
    esp.Box.Color = Color3.fromRGB(0, 150, 255)
    esp.Box.Filled = false
    esp.Box.Transparency = 0.4
    esp.HealthBar.Color = Color3.fromRGB(255, 0, 0)
    esp.HealthBar.Thickness = 3
    esp.HealthBg.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthBg.Thickness = 3
    esp.HealthBg.Transparency = 0.5
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Size = 14
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Size = 12
    esp.Tracer.Color = Color3.fromRGB(0, 150, 255)
    esp.Tracer.Thickness = 1.5
    esp.Tracer.Transparency = 0.5
    espObjects[player] = esp
end

local function UpdateESP(player)
    local esp = espObjects[player]
    if not esp or not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
    local humanoid = player.Character.Humanoid
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if Config.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        esp.Box.Visible = false
        esp.HealthBar.Visible = false
        esp.HealthBg.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Visible = false
        return
    end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        esp.Box.Visible = false
        esp.HealthBar.Visible = false
        esp.HealthBg.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Tracer.Visible = false
        return
    end
    
    local scale = 4.5
    local boxSize = Vector2.new(scale * 5, scale * 6.5)
    local boxPos = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)
    
    if Config.PlayerESP then
        esp.Box.Visible = true
        esp.Box.Position = boxPos
        esp.Box.Size = boxSize
    else
        esp.Box.Visible = false
    end
    
    if Config.HealthESP then
        local healthPercent = math.max(0, humanoid.Health / humanoid.MaxHealth)
        local barHeight = boxSize.Y * healthPercent
        local barPos = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y - barHeight)
        esp.HealthBar.Visible = true
        esp.HealthBg.Visible = true
        esp.HealthBar.From = barPos
        esp.HealthBar.To = Vector2.new(barPos.X, barPos.Y + barHeight)
        esp.HealthBg.From = Vector2.new(boxPos.X - 5, boxPos.Y)
        esp.HealthBg.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y)
        local r = 255 * (1 - healthPercent)
        local g = 255 * healthPercent
        esp.HealthBar.Color = Color3.fromRGB(r, g, 0)
    else
        esp.HealthBar.Visible = false
        esp.HealthBg.Visible = false
    end
    
    if Config.NameESP then
        esp.Name.Visible = true
        esp.Name.Position = Vector2.new(screenPos.X, boxPos.Y - 20)
        esp.Name.Text = player.Name
    else
        esp.Name.Visible = false
    end
    
    if Config.DistanceESP then
        local distance = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
        esp.Distance.Visible = true
        esp.Distance.Position = Vector2.new(screenPos.X, boxPos.Y + boxSize.Y + 15)
        esp.Distance.Text = distance .. "m"
    else
        esp.Distance.Visible = false
    end
    
    if Config.TracerESP then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        esp.Tracer.Visible = true
        esp.Tracer.From = center
        esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
    else
        esp.Tracer.Visible = false
    end
end

local function CreateFOVCircle()
    if fovCircle then fovCircle:Remove() end
    if not Config.EnableCircle then return end
    fovCircle = Drawing.new("Circle")
    fovCircle.Radius = Config.CircleSize
    fovCircle.Thickness = Config.CircleThickness
    fovCircle.Color = Color3.fromRGB(0, 150, 255)
    fovCircle.Filled = false
    fovCircle.Transparency = Config.CircleTransparency / 100
    fovCircle.Visible = true
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function IsPlayerExcluded(player)
    if not player then return false end
    for _, excludedName in ipairs(Config.ExcludeList) do
        if player.Name == excludedName then return true end
    end
    return false
end

local function GetClosestTarget()
    local bestTarget = nil
    local bestDistance = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local fovRadius = (Config.FOV / 180) * 400
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or IsPlayerExcluded(player) then continue end
        if not player.Character then continue end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        if Config.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end
        
        local targetPart = player.Character:FindFirstChild(Config.AimPart)
        if not targetPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if distance > fovRadius then continue end
        
        if Config.WallCheck then
            if not IsVisible(player.Character, targetPart) then continue end
        end
        
        if distance < bestDistance then
            bestTarget = targetPart
            bestDistance = distance
        end
    end
    return bestTarget
end

local function AimAt(targetPart)
    if not targetPart then return end
    local targetPos = targetPart.Position
    local currentPos = Camera.CFrame.Position
    local direction = (targetPos - currentPos).Unit
    local newCFrame = CFrame.new(currentPos, currentPos + direction)
    
    if Config.AimSmoothness > 0 then
        local smoothFactor = math.max(0, math.min(1, Config.AimSmoothness / 10))
        local currentAngle = Camera.CFrame.LookVector
        local targetAngle = newCFrame.LookVector
        local smoothAngle = currentAngle:Lerp(targetAngle, smoothFactor)
        newCFrame = CFrame.new(currentPos, currentPos + smoothAngle)
    end
    
    Camera.CFrame = newCFrame
end

local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VTHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🔵 VT HUB"
    title.TextColor3 = Color3.fromRGB(0, 150, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -40)
    scroll.Position = UDim2.new(0, 0, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 700)
    scroll.ScrollBarThickness = 3
    scroll.Parent = mainFrame
    
    local function createToggle(parent, text, configKey, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 35)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("ImageButton")
        toggleBtn.Size = UDim2.new(0, 50, 0, 28)
        toggleBtn.Position = UDim2.new(1, -55, 0, 3)
        toggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 80)
        toggleBtn.BackgroundTransparency = 0.3
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = toggleBtn
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = Config[configKey] and "ON" or "OFF"
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnText.TextScaled = true
        btnText.Font = Enum.Font.GothamBold
        btnText.Parent = toggleBtn
        
        toggleBtn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            toggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 80)
            btnText.Text = Config[configKey] and "ON" or "OFF"
            if configKey == "EnableCircle" then CreateFOVCircle() end
        end)
        
        return frame
    end
    
    local function createSlider(parent, text, configKey, min, max, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 45)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(Config[configKey])
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local sliderBtn = Instance.new("ImageButton")
        sliderBtn.Size = UDim2.new(0, 120, 0, 25)
        sliderBtn.Position = UDim2.new(0.7, 0, 0, 20)
        sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        sliderBtn.BackgroundTransparency = 0.3
        sliderBtn.BorderSizePixel = 0
        sliderBtn.Parent = frame
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 4)
        sliderCorner.Parent = sliderBtn
        
        local sliderText = Instance.new("TextLabel")
        sliderText.Size = UDim2.new(1, 0, 1, 0)
        sliderText.BackgroundTransparency = 1
        sliderText.Text = tostring(Config[configKey])
        sliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderText.TextScaled = true
        sliderText.Font = Enum.Font.GothamBold
        sliderText.Parent = sliderBtn
        
        sliderBtn.MouseButton1Click:Connect(function()
            local val = Config[configKey] + 5
            if val > max then val = min end
            Config[configKey] = val
            label.Text = text .. ": " .. tostring(Config[configKey])
            sliderText.Text = tostring(Config[configKey])
            if configKey == "FOV" and fovCircle then
                fovCircle.Radius = (Config.FOV / 180) * 400
            end
            if configKey == "CircleSize" then CreateFOVCircle() end
            if configKey == "CircleThickness" and fovCircle then
                fovCircle.Thickness = Config.CircleThickness
            end
        end)
        
        return frame
    end
    
    local function createDropdown(parent, text, options, configKey, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 35)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 150, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(0, 120, 0, 28)
        btn.Position = UDim2.new(0.65, 0, 0, 3)
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = Config[configKey]
        btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnText.TextScaled = true
        btnText.Font = Enum.Font.GothamMedium
        btnText.Parent = btn
        
        local currentIndex = 1
        for i, v in ipairs(options) do
            if v == Config[configKey] then
                currentIndex = i
                break
            end
        end
        
        btn.MouseButton1Click:Connect(function()
            currentIndex = currentIndex % #options + 1
            Config[configKey] = options[currentIndex]
            btnText.Text = options[currentIndex]
        end)
        
        return frame
    end
    
    local function createCategory(parent, title, yPos)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 200)
        frame.Position = UDim2.new(0, 5, 0, yPos)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local catCorner = Instance.new("UICorner")
        catCorner.CornerRadius = UDim.new(0, 8)
        catCorner.Parent = frame
        
        local catTitle = Instance.new("TextLabel")
        catTitle.Size = UDim2.new(1, 0, 0, 30)
        catTitle.BackgroundTransparency = 1
        catTitle.Text = title
        catTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
        catTitle.TextScaled = true
        catTitle.Font = Enum.Font.GothamBold
        catTitle.TextXAlignment = Enum.TextXAlignment.Left
        catTitle.Parent = frame
        
        return frame
    end
    
    local espCat = createCategory(scroll, "📡 ESP", 0)
    local espY = 35
    createToggle(espCat, "Player ESP", "PlayerESP", espY)
    espY = espY + 40
    createToggle(espCat, "Name ESP", "NameESP", espY)
    espY = espY + 40
    createToggle(espCat, "Distance ESP", "DistanceESP", espY)
    espY = espY + 40
    createToggle(espCat, "Health ESP", "HealthESP", espY)
    espY = espY + 40
    createToggle(espCat, "Tracer ESP", "TracerESP", espY)
    espY = espY + 40
    createToggle(espCat, "Team Check", "TeamCheck", espY)
    
    local aimCat = createCategory(scroll, "🎯 AIMBOT", 210)
    local aimY = 35
    createToggle(aimCat, "Enable Aimbot", "AimbotEnabled", aimY)
    aimY = aimY + 40
    createToggle(aimCat, "Wall Check", "WallCheck", aimY)
    aimY = aimY + 40
    createDropdown(aimCat, "Aim Part", {"Head", "HumanoidRootPart"}, "AimPart", aimY)
    aimY = aimY + 45
    createSlider(aimCat, "FOV", "FOV", 30, 180, aimY)
    aimY = aimY + 50
    createSlider(aimCat, "Smoothness", "AimSmoothness", 1, 10, aimY)
    
    local circleCat = createCategory(scroll, "⭕ FOV CIRCLE", 420)
    local circleY = 35
    createToggle(circleCat, "Enable Circle", "EnableCircle", circleY)
    circleY = circleY + 40
    createSlider(circleCat, "Circle Size", "CircleSize", 50, 300, circleY)
    circleY = circleY + 50
    createSlider(circleCat, "Thickness", "CircleThickness", 1, 10, circleY)
    circleY = circleY + 50
    createSlider(circleCat, "Transparency", "CircleTransparency", 0, 100, circleY)
    
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    
    local closeText = Instance.new("TextLabel")
    closeText.Size = UDim2.new(1, 0, 1, 0)
    closeText.BackgroundTransparency = 1
    closeText.Text = "✕"
    closeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeText.TextScaled = true
    closeText.Font = Enum.Font.GothamBold
    closeText.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

CreateFOVCircle()
CreateUI()

RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not espObjects[player] then CreateESP(player) end
                UpdateESP(player)
            end
        end
    else
        for _, esp in pairs(espObjects) do
            esp.Box.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBg.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Tracer.Visible = false
        end
    end
    
    if Config.AimbotEnabled then
        if UserInputService:IsKeyDown(Enum.KeyCode.Le
