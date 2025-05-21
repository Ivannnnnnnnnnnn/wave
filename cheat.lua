local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = players.LocalPlayer
local cam = workspace.CurrentCamera

local WaveUI = Instance.new("ScreenGui")
WaveUI.Name = "WaveUI"
WaveUI.ResetOnSpawn = false
WaveUI.Parent = game.CoreGui

local Main = Instance.new("Frame", WaveUI)
Main.Size = UDim2.new(0, 400, 0, 300)
Main.Position = UDim2.new(0.5, -200, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(0, 50, 1, 0)
TabBar.Position = UDim2.new(0, 0, 0, 0)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local TabNames = {"aimbot", "visuals", "local"}
local Tabs, Pages = {}
local currentPage = nil

-- Simple color constants
local tabDefaultColor = Color3.fromRGB(50, 50, 50)
local tabSelectedColor = Color3.fromRGB(70, 130, 230)

local function switchTab(name)
    for tabName, page in pairs(Pages) do
        page.Visible = (tabName == name)
        Tabs[tabName].BackgroundColor3 = tabDefaultColor
    end
    Tabs[name].BackgroundColor3 = tabSelectedColor
    currentPage = name
end

local function createTab(name, index)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Position = UDim2.new(0, 0, 0, (index - 1) * 50)
    btn.Text = name:sub(1,1):upper() .. name:sub(2)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = tabDefaultColor
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    Tabs[name] = btn
end

local function createPage(name)
    local page = Instance.new("Frame", Main)
    page.Size = UDim2.new(1, -50, 1, 0) -- leave space for tab bar
    page.Position = UDim2.new(0, 50, 0, 0)
    page.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    page.Visible = false
    Pages[name] = page
    return page
end

-- Create Tabs and Pages
for i, name in ipairs(TabNames) do
    createTab(name, i)
    createPage(name)
end

-- =====================
-- Aimbot page buttons
local aimbotPage = Pages["aimbot"]
local aimbotEnabled = false

local aimbotBtn = Instance.new("TextButton", aimbotPage)
aimbotBtn.Size = UDim2.new(0, 150, 0, 40)
aimbotBtn.Position = UDim2.new(0, 20, 0, 20)
aimbotBtn.Text = "Aimbot: OFF"
aimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimbotBtn.TextColor3 = Color3.new(1, 1, 1)
aimbotBtn.Font = Enum.Font.SourceSansBold
aimbotBtn.TextSize = 18
aimbotBtn.BorderSizePixel = 0
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

-- =====================
-- Visuals page buttons
local visualsPage = Pages["visuals"]

local showBoxes, showNames = false, false

local espToggle = Instance.new("TextButton", visualsPage)
espToggle.Size = UDim2.new(0, 150, 0, 40)
espToggle.Position = UDim2.new(0, 20, 0, 20)
espToggle.Text = "ESP Boxes: OFF"
espToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.Font = Enum.Font.SourceSansBold
espToggle.TextSize = 18
espToggle.BorderSizePixel = 0
espToggle.MouseButton1Click:Connect(function()
    showBoxes = not showBoxes
    espToggle.Text = "ESP Boxes: " .. (showBoxes and "ON" or "OFF")
end)

local nameToggle = Instance.new("TextButton", visualsPage)
nameToggle.Size = UDim2.new(0, 150, 0, 40)
nameToggle.Position = UDim2.new(0, 20, 0, 80)
nameToggle.Text = "Name ESP: OFF"
nameToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nameToggle.TextColor3 = Color3.new(1, 1, 1)
nameToggle.Font = Enum.Font.SourceSansBold
nameToggle.TextSize = 18
nameToggle.BorderSizePixel = 0
nameToggle.MouseButton1Click:Connect(function()
    showNames = not showNames
    nameToggle.Text = "Name ESP: " .. (showNames and "ON" or "OFF")
end)

local espFolder = Instance.new("Folder", WaveUI)
espFolder.Name = "ESPFolder"

rs.RenderStepped:Connect(function()
    espFolder:ClearAllChildren()
    if not (showBoxes or showNames) then return end

    for _, p in ipairs(players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = cam:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                if showNames then
                    local name = Instance.new("TextLabel", espFolder)
                    name.Text = p.Name
                    name.Position = UDim2.new(0, pos.X, 0, pos.Y - 15)
                    name.Size = UDim2.new(0, 100, 0, 20)
                    name.TextColor3 = Color3.new(1,1,1)
                    name.BackgroundTransparency = 1
                    name.Font = Enum.Font.SourceSansBold
                    name.TextSize = 14
                end
                if showBoxes then
                    local box = Instance.new("Frame", espFolder)
                    box.Size = UDim2.new(0, 40, 0, 60)
                    box.Position = UDim2.new(0, pos.X - 20, 0, pos.Y - 30)
                    box.BackgroundColor3 = Color3.new(1,0,0)
                    box.BorderSizePixel = 0
                    box.BackgroundTransparency = 0.5
                end
            end
        end
    end
end)

-- =====================
-- Local page controls
local localPage = Pages["local"]

local wsInput = Instance.new("TextBox", localPage)
wsInput.Size = UDim2.new(0, 150, 0, 40)
wsInput.Position = UDim2.new(0, 20, 0, 20)
wsInput.PlaceholderText = "WalkSpeed (default 16)"
wsInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
wsInput.TextColor3 = Color3.new(1, 1, 1)
wsInput.Font = Enum.Font.SourceSansBold
wsInput.TextSize = 18
wsInput.ClearTextOnFocus = false
wsInput.BorderSizePixel = 0
wsInput.FocusLost:Connect(function(enterPressed)
    local val = tonumber(wsInput.Text)
    if val and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = val
    end
end)

local jpInput = Instance.new("TextBox", localPage)
jpInput.Size = UDim2.new(0, 150, 0, 40)
jpInput.Position = UDim2.new(0, 20, 0, 80)
jpInput.PlaceholderText = "JumpPower (default 50)"
jpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jpInput.TextColor3 = Color3.new(1, 1, 1)
jpInput.Font = Enum.Font.SourceSansBold
jpInput.TextSize = 18
jpInput.ClearTextOnFocus = false
jpInput.BorderSizePixel = 0
jpInput.FocusLost:Connect(function(enterPressed)
    local val = tonumber(jpInput.Text)
    if val and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.JumpPower = val
    end
end)

-- Show the first tab by default
switchTab("aimbot")

-- Close GUI on Insert keypress
uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        WaveUI.Enabled = not WaveUI.Enabled
    end
end)
