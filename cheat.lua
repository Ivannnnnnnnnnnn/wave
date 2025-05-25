loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local settings = {
    espEnabled = true,
    aimAssistEnabled = true,
    aimFOV = 100,
    aimPart = "Head",
    aimBind = Enum.UserInputType.MouseButton2,
    espColor = Color3.fromRGB(255, 0, 0)
}

local aiming = false
local espTable = {}
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = settings.aimFOV
fovCircle.Thickness = 2
fovCircle.Transparency = 0.4
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Visible = true

local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = true
    box.Transparency = 0.3
    box.Color = settings.espColor
    box.Visible = false
    return {box = box, player = player}
end

local function getClosestTarget()
    local closest, shortest = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild(settings.aimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[settings.aimPart].Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < settings.aimFOV and dist < shortest then
                    closest, shortest = player, dist
                end
            end
        end
    end
    return closest
end

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == settings.aimBind then
        aiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == settings.aimBind then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = settings.aimFOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espTable[player] then
                espTable[player] = createESP(player)
            end
            local esp = espTable[player]
            local pos, visible = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if visible and settings.espEnabled and head and humanoid then
                local scale = 1 / (Camera.CFrame.Position - head.Position).Magnitude * 100
                local size = Vector2.new(40 * scale, 80 * scale)
                esp.box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                esp.box.Size = size
                esp.box.Color = settings.espColor
                esp.box.Visible = true
            else
                esp.box.Visible = false
            end
        end
    end
    if settings.aimAssistEnabled and aiming then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(settings.aimPart) then
            local partPos = target.Character[settings.aimPart].Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, partPos)
        end
    end
end)

local UI = Rayfield:CreateWindow({
    Name = "Wave | Universal FPS Cheat",
    LoadingTitle = "Wave Loading...",
    ConfigurationSaving = {Enabled = false}
})

local aimbotTab = UI:CreateTab("Aimbot", 4483362458)
aimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = true,
    Callback = function(v)
        settings.aimAssistEnabled = v
    end
})
aimbotTab:CreateSlider({
    Name = "Aimbot FOV Radius",
    Range = {10, 300},
    Increment = 5,
    CurrentValue = settings.aimFOV,
    Callback = function(v)
        settings.aimFOV = v
        fovCircle.Radius = v
    end
})

local espTab = UI:CreateTab("ESP", 4483362458)
espTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = true,
    Callback = function(v)
        settings.espEnabled = v
    end
})
espTab:CreateColorPicker({
    Name = "ESP Box Color",
    Color = settings.espColor,
    Callback = function(color)
        settings.espColor = color
    end
})
