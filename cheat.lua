local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = players.LocalPlayer
local cam = workspace.CurrentCamera

local WaveUI = Instance.new("ScreenGui")
WaveUI.ResetOnSpawn = false
WaveUI.Name = "WaveUI"
WaveUI.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 400, 0, 300)
Main.Position = UDim2.new(0.5, -200, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Parent = WaveUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 50, 1, 0)
TabBar.Position = UDim2.new(0, 0, 0, 0)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBar.Parent = Main
TabBar.ZIndex = 5

local iconBase = "https://raw.githubusercontent.com/Ivannnnnnnnnnnn/wave/main/assets/"
local icons = {
    aimbot = iconBase.."aimbot.png",
    visuals = iconBase.."visuals.png",
    localtab = iconBase.."local.png",
}

local Tabs, Pages = {}, {}
local currentPage = nil

local function switchTab(name)
    for k, v in pairs(Pages) do
        v.Visible = (k == name)
    end
    currentPage = name
end

local function createTab(name, icon, index)
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 10 + (50 * (index - 1)))
    btn.Image = icon
    btn.BackgroundTransparency = 1
    btn.Parent = TabBar
    btn.ZIndex = 10
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    Tabs[name] = btn
end

local function createPage(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -50, 1, 0)
    page.Position = UDim2.new(0, 50, 0, 0)
    page.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    page.Visible = false
    page.Parent = Main
    page.ZIndex = 5
    Pages[name] = page
    return page
end

createTab("aimbot", icons.aimbot, 1)
createTab("visuals", icons.visuals, 2)
createTab("local", icons.localtab, 3)

local aimbotPage = createPage("aimbot")
local visualsPage = createPage("visuals")
local localPage = createPage("local")

-- Aimbot toggle button
local aimbotEnabled = false
local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Size = UDim2.new(0, 120, 0, 30)
aimbotBtn.Position = UDim2.new(0, 20, 0, 20)
aimbotBtn.Text = "Aimbot: OFF"
aimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimbotBtn.TextColor3 = Color3.new(1, 1, 1)
aimbotBtn.Parent = aimbotPage
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

rs.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    if not uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local closest, dist = nil, math.huge
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") and p.Team ~= lp.Team then
            local headPos, onScreen = cam:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(headPos.X, headPos.Y) - uis:GetMouseLocation()).Magnitude
                if mag < dist then
                    dist = mag
                    closest = p
                end
            end
        end
    end

    if closest and closest.Character and closest.Character:FindFirstChild("Head") then
        cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.Head.Position)
    end
end)

-- ESP toggles
local showBoxes, showNames = false, false

local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 120, 0, 30)
espToggle.Position = UDim2.new(0, 20, 0, 20)
espToggle.Text = "ESP Boxes: OFF"
espToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.Parent = visualsPage
espToggle.MouseButton1Click:Connect(function()
    showBoxes = not showBoxes
    espToggle.Text = "ESP Boxes: " .. (showBoxes and "ON" or "OFF")
end)

local nameToggle = Instance.new("TextButton")
nameToggle.Size = UDim2.new(0, 120, 0, 30)
nameToggle.Position = UDim2.new(0, 20, 0, 60)
nameToggle.Text = "Name ESP: OFF"
nameToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nameToggle.TextColor3 = Color3.new(1, 1, 1)
nameToggle.Parent = visualsPage
nameToggle.MouseButton1Click:Connect(function()
    showNames = not showNames
    nameToggle.Text = "Name ESP: " .. (showNames and "ON" or "OFF")
end)

local espFolder = Instance.new("Folder")
espFolder.Name = "ESPFolder"
espFolder.Parent = WaveUI

rs.RenderStepped:Connect(function()
    espFolder:ClearAllChildren()
    if not (showBoxes or showNames) then return end

    for _, p in ipairs(players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = cam:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                if showNames then
                    local name = Instance.new("TextLabel")
                    name.Text = p.Name
                    name.Position = UDim2.new(0, pos.X, 0, pos.Y - 15)
                    name.Size = UDim2.new(0, 100, 0, 20)
                    name.TextColor3 = Color3.new(1,1,1)
                    name.BackgroundTransparency = 1
                    name.Font = Enum.Font.SourceSansBold
                    name.TextSize = 14
                    name.Parent = espFolder
                end
                if showBoxes then
                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, 40, 0, 60)
                    box.Position = UDim2.new(0, pos.X - 20, 0, pos.Y - 30)
                    box.BackgroundColor3 = Color3.new(1,0,0)
                    box.BorderSizePixel = 0
                    box.BackgroundTransparency = 0.5
                    box.Parent = espFolder
                end
            end
        end
    end
end)

-- Local player settings
local wsSlider = Instance.new("TextBox")
wsSlider.Size = UDim2.new(0, 140, 0, 30)
wsSlider.Position = UDim2.new(0, 20, 0, 20)
wsSlider.PlaceholderText = "Walkspeed (default 16)"
wsSlider.Text = ""
wsSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
wsSlider.TextColor3 = Color3.new(1, 1, 1)
wsSlider.Parent = localPage
wsSlider.FocusLost:Connect(function()
    local val = tonumber(wsSlider.Text)
    if val and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = val
    end
end)

local jpSlider = Instance.new("TextBox")
jpSlider.Size = UDim2.new(0, 140, 0, 30)
jpSlider.Position = UDim2.new(0, 20, 0, 60)
jpSlider.PlaceholderText = "JumpPower (default 50)"
jpSlider.Text = ""
jpSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jpSlider.TextColor3 = Color3.new(1, 1, 1)
jpSlider.Parent = localPage
jpSlider.FocusLost:Connect(function()
    local val = tonumber(jpSlider.Text)
    if val and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        lp.Character.Humanoid.JumpPower = val
    end
end)

switchTab("aimbot")

-- Toggle GUI visibility on Insert key
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        WaveUI.Enabled = not WaveUI.Enabled
    end
end)

-- Manual dragging for Main frame
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                             startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
