local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local splashGui = Instance.new("ScreenGui", game.CoreGui)
splashGui.Name = "WaveSplash"
local letters = {"W", "a", "v", "e"}
local colors = {
    Color3.fromRGB(0, 102, 204),
    Color3.fromRGB(70, 150, 230),
    Color3.fromRGB(173, 216, 230),
    Color3.fromRGB(255, 255, 255)
}
local letterLabels = {}
local totalWidth = 300
local letterWidth = totalWidth / #letters
local height = 100
local startX = 0.5 - (totalWidth / 2) / splashGui.AbsoluteSize.X
for i, letter in ipairs(letters) do
    local lbl = Instance.new("TextLabel", splashGui)
    lbl.Size = UDim2.new(0, letterWidth, 0, height)
    lbl.Position = UDim2.new(startX + ((i-1)*letterWidth) / splashGui.AbsoluteSize.X, 0, 0.5, -height/2)
    lbl.BackgroundTransparency = 1
    lbl.Text = letter
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextScaled = true
    lbl.TextColor3 = colors[i]
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 70, 140)
    letterLabels[i] = lbl
end

task.spawn(function()
    local start = tick()
    local duration = 3
    local alpha = 1
    while tick() - start < duration do
        local t = tick() - start
        local yOffset = math.sin(t * math.pi * 2) * 10
        for i, lbl in ipairs(letterLabels) do
            lbl.Position = UDim2.new(lbl.Position.X.Scale, lbl.Position.X.Offset, 0.5, -height/2 + yOffset)
            if t > duration - 1 then
                alpha = 1 - (t - (duration - 1))
                lbl.TextTransparency = 1 - alpha
                lbl.TextStrokeTransparency = 0.5 + 0.5 * (1 - alpha)
            end
        end
        task.wait()
    end
    splashGui:Destroy()
end)

local settings = {
    espEnabled = true,
    aimEnabled = true,
    teamCheck = true,
    fovVisible = true,
    bhopEnabled = false,
    speedhackEnabled = false,
    speedValue = 20,
    fov = 100,
    aimPart = "Head",
    aimKey = Enum.UserInputType.MouseButton2,
    espColor = Color3.fromRGB(255, 0, 0),
    menuOpen = true,
    antiAimEnabled = false,
    espR = 255,
    espG = 0,
    espB = 0,
}

local espBoxes = {}
local fovCircle = Drawing.new("Circle")
fovCircle.Filled = false
fovCircle.Transparency = 0.6
fovCircle.Thickness = 1
fovCircle.Visible = settings.fovVisible
fovCircle.Color = Color3.new(1, 1, 1)

local aiming = false
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == settings.aimKey then aiming = true end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == settings.aimKey then aiming = false end
end)

local function isEnemy(p)
    return p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (not settings.teamCheck or p.Team ~= LP.Team)
end

local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = true
    box.Transparency = 0.3
    box.Visible = false
    box.Color = settings.espColor
    espBoxes[player] = box
end

local function getClosest()
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character and p.Character:FindFirstChild(settings.aimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character[settings.aimPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < settings.fov and mag < dist then
                    closest, dist = p, mag
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if settings.bhopEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local humanoid = LP.Character.Humanoid
        if UIS:IsKeyDown(Enum.KeyCode.Space) and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if settings.speedhackEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = settings.speedValue
    elseif LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 16
    end
end)

RunService.Heartbeat:Connect(function()
    if settings.antiAimEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local pos = hrp.Position
        hrp.CFrame = CFrame.new(pos.X, pos.Y - 100, pos.Z)
    end
end)

RunService.RenderStepped:Connect(function()
    settings.espColor = Color3.fromRGB(settings.espR, settings.espG, settings.espB)
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = settings.fov
    fovCircle.Visible = settings.fovVisible

    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            if not espBoxes[p] then createESP(p) end
            local esp = espBoxes[p]
            local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                local scale = 1 / (Camera.CFrame.Position - root.Position).Magnitude * 100
                local size = Vector2.new(40 * scale, 80 * scale)
                if vis and settings.espEnabled then
                    esp.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    esp.Size = size
                    esp.Visible = true
                    esp.Color = settings.espColor
                else
                    esp.Visible = false
                end
            end
        elseif espBoxes[p] then
            espBoxes[p].Visible = false
        end
    end

    if settings.aimEnabled and aiming then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild(settings.aimPart) then
            local part = target.Character[settings.aimPart]
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "WaveMenu"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.05, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Visible = settings.menuOpen
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame)

local title = Instance.new("TextLabel", Frame)
title.Text = "Wave"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local currentTab = "Aimbot"
local uiElements = {}
local function clearUI() for _, v in ipairs(uiElements) do v:Destroy() end uiElements = {} end
local baseY = 70 local spacing = 35

local function makeSlider(name, y, settingKey, min, max)
    local label = Instance.new("TextLabel", Frame)
    label.Position = UDim2.new(0, 10, 0, y)
    label.Size = UDim2.new(0, 280, 0, 20)
    label.Text = name .. ": " .. tostring(settings[settingKey])
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    table.insert(uiElements, label)

    local slider = Instance.new("TextButton", Frame)
    slider.Position = UDim2.new(0, 10, 0, y + 20)
    slider.Size = UDim2.new(0, 280, 0, 15)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.Text = ""
    table.insert(uiElements, slider)

    local dragging = false
    slider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    slider.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local relativeX = math.clamp(mouseX - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            local value = min + (max - min) * (relativeX / slider.AbsoluteSize.X)
            settings[settingKey] = math.floor(value)
            label.Text = name .. ": " .. tostring(settings[settingKey])
        end
    end)
end

local function makeToggle(name, y, settingKey)
    local toggle = Instance.new("TextButton", Frame)
    toggle.Position = UDim2.new(0, 10, 0, y)
    toggle.Size = UDim2.new(0, 130, 0, 25)
    toggle.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.SourceSans
    toggle.TextSize = 18
    toggle.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        toggle.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    end)
    table.insert(uiElements, toggle)
end

local function makeDropdown(name, y, options, settingKey)
    local label = Instance.new("TextLabel", Frame)
    label.Position = UDim2.new(0, 10, 0, y)
    label.Size = UDim2.new(0, 280, 0, 25)
    label.Text = name .. ": " .. tostring(settings[settingKey])
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    table.insert(uiElements, label)

    local dropdown = Instance.new("TextButton", Frame)
    dropdown.Position = UDim2.new(0, 10, 0, y + 25)
    dropdown.Size = UDim2.new(0, 280, 0, 25)
    dropdown.Text = "Change"
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.TextColor3 = Color3.new(1,1,1)
    dropdown.Font = Enum.Font.SourceSans
    dropdown.TextSize = 16
    table.insert(uiElements, dropdown)

    dropdown.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, settings[settingKey]) or 1
        local nextIndex = (currentIndex % #options) + 1
        settings[settingKey] = options[nextIndex]
        label.Text = name .. ": " .. tostring(settings[settingKey])
    end)
end

local function drawTabContent()
    clearUI()
    if currentTab == "Aimbot" then
        makeToggle("Aimbot", baseY, "aimEnabled")
        makeToggle("Team Check", baseY + spacing, "teamCheck")
        makeDropdown("Aim Part", baseY + spacing*2, {"Head", "HumanoidRootPart"}, "aimPart")
        makeSlider("FOV", baseY + spacing*4, "fov", 50, 300)
        makeToggle("Show FOV", baseY + spacing*5, "fovVisible")
    elseif currentTab == "Visuals" then
        makeToggle("ESP Boxes", baseY, "espEnabled")
        makeSlider("ESP R", baseY + spacing, "espR", 0, 255)
        makeSlider("ESP G", baseY + spacing*2, "espG", 0, 255)
        makeSlider("ESP B", baseY + spacing*3, "espB", 0, 255)
    elseif currentTab == "Misc" then
        makeToggle("Bunnyhop", baseY, "bhopEnabled")
        makeToggle("Speedhack", baseY + spacing, "speedhackEnabled")
        if settings.speedhackEnabled then
            makeSlider("Speed", baseY + spacing*2, "speedValue", 16, 50)
        end
        makeToggle("Anti-Aim", baseY + spacing*4, "antiAimEnabled")
    end
end

local function makeTabButton(name, x)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 80, 0, 25)
    btn.Position = UDim2.new(0, x, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.AutoButtonColor = false
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)
    btn.MouseButton1Click:Connect(function()
        currentTab = name
        drawTabContent()
    end)
    return btn
end

makeTabButton("Aimbot", 10)
makeTabButton("Visuals", 100)
makeTabButton("Misc", 190)
drawTabContent()

local userFrame = Instance.new("Frame", Frame)
userFrame.Size = UDim2.new(1, -20, 0, 60)
userFrame.Position = UDim2.new(0, 10, 1, -65)
userFrame.BackgroundTransparency = 0.5
userFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", userFrame)

local userImage = Instance.new("ImageLabel", userFrame)
userImage.Size = UDim2.new(0, 50, 0, 50)
userImage.Position = UDim2.new(0, 5, 0.5, -25)
userImage.BackgroundTransparency = 1
userImage.Image = LP.UserId and ("https://www.roblox.com/headshot-thumbnail/image?userId="..LP.UserId.."&width=48&height=48&format=png") or ""
userImage.ScaleType = Enum.ScaleType.Fit
ContentProvider:PreloadAsync({userImage.Image})

local userNameLabel = Instance.new("TextLabel", userFrame)
userNameLabel.Size = UDim2.new(0, 200, 0, 50)
userNameLabel.Position = UDim2.new(0, 65, 0, 0)
userNameLabel.BackgroundTransparency = 1
userNameLabel.Text = LP.Name
userNameLabel.Font = Enum.Font.SourceSansBold
userNameLabel.TextColor3 = Color3.new(1, 1, 1)
userNameLabel.TextSize = 24
userNameLabel.TextXAlignment = Enum.TextXAlignment.Left

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        settings.menuOpen = not settings.menuOpen
        Frame.Visible = settings.menuOpen
    end
end)
