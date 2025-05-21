local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create main GUI
local WaveUI = Instance.new("ScreenGui")
WaveUI.Name = "WaveUI"
WaveUI.ResetOnSpawn = false
WaveUI.Parent = game.CoreGui

local MainFrame = Instance.new("Frame", WaveUI)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Tab bar
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(0, 50, 1, 0)
TabBar.Position = UDim2.new(0, 0, 0, 0)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local TabNames = {"aimbot", "visuals", "local"}
local Tabs = {}
local Pages = {}

local tabDefaultColor = Color3.fromRGB(50, 50, 50)
local tabSelectedColor = Color3.fromRGB(70, 130, 230)

local currentPage = nil

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
    local page = Instance.new("Frame", MainFrame)
    page.Size = UDim2.new(1, -50, 1, 0)
    page.Position = UDim2.new(0, 50, 0, 0)
    page.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    page.Visible = false
    Pages[name] = page
    return page
end

for i, name in ipairs(TabNames) do
    createTab(name, i)
    createPage(name)
end

-- === Aimbot Page ===
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
aimbotBtn.AutoButtonColor = false
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local closestPlayer, closestDistance = nil, math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Team ~= LocalPlayer.Team then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < closestDistance then
                    closestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
    end
end)

-- === Visuals Page ===
local visualsPage = Pages["visuals"]
local showBoxes = false
local showNames = false

local espToggle = Instance.new("TextButton", visualsPage)
espToggle.Size = UDim2.new(0, 150, 0, 40)
espToggle.Position = UDim2.new(0, 20, 0, 20)
espToggle.Text = "ESP Boxes: OFF"
espToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.Font = Enum.Font.SourceSansBold
espToggle.TextSize = 18
espToggle.BorderSizePixel = 0
espToggle.AutoButtonColor = false
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
nameToggle.AutoButtonColor = false
nameToggle.MouseButton1Click:Connect(function()
    showNames = not showNames
    nameToggle.Text = "Name ESP: " .. (showNames and "ON" or "OFF")
end)

local espFolder = Instance.new("Folder", WaveUI)
espFolder.Name = "ESPFolder"

RunService.RenderStepped:Connect(function()
    espFolder:ClearAllChildren()
    if not (showBoxes or showNames) then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                if showNames then
                    local nameLabel = Instance.new("TextLabel", espFolder)
                    nameLabel.Text = player.Name
                    nameLabel.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 15)
                    nameLabel.Size = UDim2.new(0, 100, 0, 20)
                    nameLabel.TextColor3 = Color3.new(1, 1, 1)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Font = Enum.Font.SourceSansBold
                    nameLabel.TextSize = 14
                end

                if showBoxes then
                    local box = Instance.new("Frame", espFolder)
                    box.Size = UDim2.new(0, 40, 0, 60)
                    box.Position = UDim2.new(0, screenPos.X - 20, 0, screenPos.Y - 30)
                    box.BackgroundColor3 = Color3.new(1, 0, 0)
                    box.BorderSizePixel = 0
                    box.BackgroundTransparency = 0.5
                end
            end
        end
    end
end)

-- === Local Page ===
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
wsInput.AutoLocalize = false
wsInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(wsInput.Text)
        if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
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
jpInput.AutoLocalize = false
jpInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(jpInput.Text)
        if val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end
end)

-- Show the first tab by default
switchTab("aimbot")

-- Toggle GUI visibility on Insert key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        WaveUI.Enabled = not WaveUI.Enabled
    end
end)
