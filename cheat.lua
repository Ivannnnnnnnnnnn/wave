--// Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// GUI Setup
local WaveUI = Instance.new("ScreenGui")
WaveUI.Name = "WaveUI"
WaveUI.ResetOnSpawn = false
WaveUI.Parent = game.CoreGui
WaveUI.Enabled = false

-- Splash
local SplashFrame = Instance.new("Frame", WaveUI)
SplashFrame.Size = UDim2.new(0, 400, 0, 100)
SplashFrame.Position = UDim2.new(0.5, -200, 0.5, -50)
SplashFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", SplashFrame).CornerRadius = UDim.new(0,10)

local SplashText = Instance.new("TextLabel", SplashFrame)
SplashText.Size = UDim2.new(1, 0, 1, 0)
SplashText.BackgroundTransparency = 1
SplashText.Font = Enum.Font.GothamBold
SplashText.TextSize = 48
SplashText.Text = "Wave"
SplashText.TextColor3 = Color3.fromRGB(255, 85, 0)
SplashText.TextStrokeTransparency = 0
SplashText.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)

TweenService:Create(SplashText, TweenInfo.new(1.5), {TextTransparency=0, TextStrokeTransparency=0}):Play()
wait(3)
TweenService:Create(SplashText, TweenInfo.new(1.5), {TextTransparency=1, TextStrokeTransparency=1}):Play()
wait(1.5)
SplashFrame:Destroy()
WaveUI.Enabled = true

-- Main Frame
local MainFrame = Instance.new("Frame", WaveUI)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(255, 85, 0)
Title.Text = "Wave"

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(0, 50, 1, -50)
TabBar.Position = UDim2.new(0, 0, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local TabNames = {"aimbot", "visuals", "local"}
local Tabs = {}
local Pages = {}
local currentPage = nil

local icons = {
    aimbot = "https://raw.githubusercontent.com/Ivannnnnnnnnnnn/wave/main/assets/aimbot.png",
    visuals = "https://raw.githubusercontent.com/Ivannnnnnnnnnnn/wave/main/assets/visuals.png",
    localp = "https://raw.githubusercontent.com/Ivannnnnnnnnnnn/wave/main/assets/local.png"
}

local function createTab(name, index)
    local btn = Instance.new("ImageButton", TabBar)
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Position = UDim2.new(0, 0, 0, (index - 1) * 50)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Image = icons[name == "local" and "localp" or name]
    btn.ScaleType = Enum.ScaleType.Fit
    btn.AutoButtonColor = false
    btn.MouseButton1Click:Connect(function()
        for tab, page in pairs(Pages) do
            page.Visible = (tab == name)
            Tabs[tab].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 130, 230)
        currentPage = name
    end)
    Tabs[name] = btn
end

local function createPage(name)
    local page = Instance.new("Frame", MainFrame)
    page.Size = UDim2.new(1, -50, 1, -50)
    page.Position = UDim2.new(0, 50, 0, 50)
    page.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    page.Visible = false
    Pages[name] = page
end

for i, name in ipairs(TabNames) do
    createTab(name, i)
    createPage(name)
end
Pages["aimbot"].Visible = true
Tabs["aimbot"].BackgroundColor3 = Color3.fromRGB(70, 130, 230)

--// AIMBOT
local aimbotEnabled = false
local aimbotBtn = Instance.new("TextButton", Pages["aimbot"])
aimbotBtn.Size = UDim2.new(0, 150, 0, 40)
aimbotBtn.Position = UDim2.new(0, 20, 0, 20)
aimbotBtn.Text = "Aimbot: OFF"
aimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimbotBtn.TextColor3 = Color3.new(1, 1, 1)
aimbotBtn.Font = Enum.Font.SourceSansBold
aimbotBtn.TextSize = 18
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

--// VISUALS
local showBoxes, showNames = false, false

local espToggle = Instance.new("TextButton", Pages["visuals"])
espToggle.Size = UDim2.new(0, 150, 0, 40)
espToggle.Position = UDim2.new(0, 20, 0, 20)
espToggle.Text = "ESP Boxes: OFF"
espToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.Font = Enum.Font.SourceSansBold
espToggle.TextSize = 18
espToggle.MouseButton1Click:Connect(function()
    showBoxes = not showBoxes
    espToggle.Text = "ESP Boxes: " .. (showBoxes and "ON" or "OFF")
end)

local nameToggle = Instance.new("TextButton", Pages["visuals"])
nameToggle.Size = UDim2.new(0, 150, 0, 40)
nameToggle.Position = UDim2.new(0, 20, 0, 80)
nameToggle.Text = "Name ESP: OFF"
nameToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nameToggle.TextColor3 = Color3.new(1, 1, 1)
nameToggle.Font = Enum.Font.SourceSansBold
nameToggle.TextSize = 18
nameToggle.MouseButton1Click:Connect(function()
    showNames = not showNames
    nameToggle.Text = "Name ESP: " .. (showNames and "ON" or "OFF")
end)

local espFolder = Instance.new("Folder", WaveUI)
espFolder.Name = "ESPFolder"

--// RENDER STEPPED
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closestPlayer, minDist = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                local head = player.Character and player.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
        end
    end

    -- ESP
    espFolder:ClearAllChildren()
    if not (showBoxes or showNames) then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                if showNames then
                    local label = Instance.new("TextLabel", espFolder)
                    label.Text = player.Name
                    label.Position = UDim2.new(0, headPos.X, 0, headPos.Y - 15)
                    label.Size = UDim2.new(0, 100, 0, 20)
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.BackgroundTransparency = 1
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 14
                end
                if showBoxes and player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    local box = Instance.new("Frame", espFolder)
                    local height = math.abs(rootPos.Y - headPos.Y) * 2
                    local width = height / 2
                    box.Position = UDim2.new(0, headPos.X - width/2, 0, headPos.Y - height/2)
                    box.Size = UDim2.new(0, width, 0, height)
                    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    box.BackgroundTransparency = 0.6
                    box.BorderSizePixel = 1
                end
            end
        end
    end
end)
