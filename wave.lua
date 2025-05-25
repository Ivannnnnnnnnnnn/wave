local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local settings = {
    espEnabled = true,
    aimEnabled = true,
    teamCheck = true,
    fovVisible = true,
    fov = 100,
    aimPart = "Head",
    aimKey = Enum.UserInputType.MouseButton2,
    espColor = Color3.fromRGB(255, 0, 0),
    menuOpen = true
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
        if isEnemy(p) and p.Character:FindFirstChild(settings.aimPart) then
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

RunService.RenderStepped:Connect(function()
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

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "WaveMenu"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 300)
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

local function clearUI()
    for _, v in ipairs(uiElements) do
        v:Destroy()
    end
    uiElements = {}
end

local function makeToggle(name, y, settingKey)
    local toggle = Instance.new("TextButton", Frame)
    toggle.Position = UDim2.new(0, 10, 0, y)
    toggle.Size = UDim2.new(0, 130, 0, 25)
    toggle.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 16
    toggle.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        toggle.Text = name .. ": " .. (settings[settingKey] and "ON" or "OFF")
    end)
    table.insert(uiElements, toggle)
end

local function makeSlider(name, y, min, max, settingKey)
    local text = Instance.new("TextLabel", Frame)
    text.Position = UDim2.new(0, 10, 0, y)
    text.Size = UDim2.new(0, 150, 0, 20)
    text.Text = name .. ": " .. settings[settingKey]
    text.TextColor3 = Color3.new(1, 1, 1)
    text.BackgroundTransparency = 1
    text.TextSize = 14
    table.insert(uiElements, text)

    local slider = Instance.new("TextButton", Frame)
    slider.Position = UDim2.new(0, 10, 0, y + 20)
    slider.Size = UDim2.new(0, 200, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.Text = ""
    table.insert(uiElements, slider)

    slider.MouseButton1Down:Connect(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local mouse = UIS:GetMouseLocation().X
            local rel = math.clamp(mouse - slider.AbsolutePosition.X, 0, 200)
            local value = math.floor(min + ((rel / 200) * (max - min)))
            settings[settingKey] = value
            text.Text = name .. ": " .. value
        end)
        UIS.InputEnded:Wait()
        if conn then conn:Disconnect() end
    end)
end

local function makeColorPicker(y)
    local colorBtn = Instance.new("TextButton", Frame)
    colorBtn.Position = UDim2.new(0, 10, 0, y)
    colorBtn.Size = UDim2.new(0, 130, 0, 25)
    colorBtn.Text = "ESP Color"
    colorBtn.BackgroundColor3 = settings.espColor
    colorBtn.TextColor3 = Color3.new(1, 1, 1)
    colorBtn.MouseButton1Click:Connect(function()
        local r = math.random(50, 255)
        local g = math.random(50, 255)
        local b = math.random(50, 255)
        settings.espColor = Color3.fromRGB(r, g, b)
        colorBtn.BackgroundColor3 = settings.espColor
    end)
    table.insert(uiElements, colorBtn)
end

local function updateUI()
    clearUI()
    if currentTab == "Aimbot" then
        makeToggle("Aimbot", 70, "aimEnabled")
        makeToggle("Team Check", 100, "teamCheck")
    elseif currentTab == "Visuals" then
        makeToggle("ESP", 70, "espEnabled")
        makeToggle("Show FOV", 100, "fovVisible")
        makeSlider("FOV Radius", 130, 10, 300, "fov")
        makeColorPicker(180)
    elseif currentTab == "Misc" then
    end
end

local tabNames = {"Aimbot", "Visuals", "Misc"}
for i, name in ipairs(tabNames) do
    local tabBtn = Instance.new("TextButton", Frame)
    tabBtn.Size = UDim2.new(0, 90, 0, 25)
    tabBtn.Position = UDim2.new(0, 10 + ((i - 1) * 100), 0, 35)
    tabBtn.Text = name
    tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabBtn.TextColor3 = Color3.new(1, 1, 1)
    tabBtn.TextSize = 14
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = name
        updateUI()
    end)
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        settings.menuOpen = not settings.menuOpen
        Frame.Visible = settings.menuOpen
    end
end)

updateUI()