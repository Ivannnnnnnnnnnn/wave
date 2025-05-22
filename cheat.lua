local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function loadIcon(name)
    local success, img = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/Ivannnnnnnnnnnn/wave/main/assets/"..name..".png")
    end)
    if success then return "rbxassetid://"..tostring(game:GetService("HttpService"):GenerateGUID(false)) end
    return ""
end

local WaveUI = Instance.new("ScreenGui")
WaveUI.Name = "WaveUI"
WaveUI.ResetOnSpawn = false
WaveUI.Parent = game.CoreGui
WaveUI.Enabled = false

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
SplashText.TextTransparency = 0

local splashTweenIn = TweenService:Create(SplashText, TweenInfo.new(1.5), {TextTransparency=0, TextStrokeTransparency=0})
local splashTweenOut = TweenService:Create(SplashText, TweenInfo.new(1.5), {TextTransparency=1, TextStrokeTransparency=1})

splashTweenIn:Play()
splashTweenIn.Completed:Wait()
wait(1.5)
splashTweenOut:Play()
splashTweenOut.Completed:Wait()
SplashFrame:Destroy()
WaveUI.Enabled = true

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
Title.Position = UDim2.new(0, 0, 0, 0)

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(0, 50, 1, -50)
TabBar.Position = UDim2.new(0, 0, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local TabNames = {"aimbot", "visuals", "local"}
local Tabs = {}
local Pages = {}

local tabDefaultColor = Color3.fromRGB(50, 50, 50)
local tabSelectedColor = Color3.fromRGB(70, 130, 230)
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
    btn.BackgroundColor3 = tabDefaultColor
    btn.BorderSizePixel = 0
    btn.Image = icons[name == "local" and "localp" or name] or ""
    btn.ScaleType = Enum.ScaleType.Fit
    btn.AutoButtonColor = false
    btn.Name = name.."Tab"

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
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
    return page
end

local function switchTab(name)
    for tabName, page in pairs(Pages) do
        page.Visible = (tabName == name)
        Tabs[tabName].BackgroundColor3 = tabDefaultColor
    end
    Tabs[name].BackgroundColor3 = tabSelectedColor
    currentPage = name
end

for i, name in ipairs(TabNames) do
    createTab(name, i)
    createPage(name)
end

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
                if showBoxes and player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if rootOnScreen then
                        local box = Instance.new("Frame", espFolder)
                        local sizeY = math.abs(rootPos.Y - screenPos.Y) * 2
                        local sizeX = sizeY / 2
                        box.Position = UDim2.new(0, screenPos.X - sizeX/2, 0, screenPos.Y - sizeY/2)
                        box.Size = UDim2.new(0, sizeX, 0, sizeY)
                        box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        box.BorderSizePixel = 1
                        box.BackgroundTransparency = 0.7
                    end
                end
            end
        end
    end
end)

local localPage = Pages["local"]
local bhopEnabled = false

local bhopBtn = Instance.new("TextButton", localPage)
bhopBtn.Size = UDim2.new(0, 150, 0, 40)
bhopBtn.Position = UDim2.new(0, 20, 0, 20)
bhopBtn.Text = "Bunnyhop: OFF"
bhopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bhopBtn.TextColor3 = Color3.new(1, 1, 1)
bhopBtn.Font = Enum.Font.SourceSansBold
bhopBtn.TextSize = 18
bhopBtn.BorderSizePixel = 0
bhopBtn.AutoButtonColor = false
bhopBtn.MouseButton1Click:Connect(function()
    bhopEnabled = not bhopEnabled
    bhopBtn.Text = "Bunnyhop: " .. (bhopEnabled and "ON" or "OFF")
end)

local jumping = false
RunService.Heartbeat:Connect(function()
    if bhopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and not jumping and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid:GetState() == Enum.HumanoidStateType.Landed or humanoid:GetState() == Enum.HumanoidStateType.Running then
            jumping = true
            humanoid.Jump = true
            wait(0.1)
            jumping = false
        end
    end
end)

local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        guiVisible = not guiVisible
        WaveUI.Enabled = guiVisible
    end
end)

switchTab("aimbot")
