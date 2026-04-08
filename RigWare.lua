local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "RigWare",
   LoadingTitle = "Injecting...",
   LoadingSubtitle = "RigWare: Undetected",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "ESP_Config",
      FileName = "Visuals"
   }
})


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local AIM_PART = "Head"
local SMOOTHNESS = 0.25
local FOV_RADIUS = 150
local TEAM_CHECK = false
local PREDICTION = 0.08
local ESP_ENABLED = false
local TRACERS_ENABLED = false

local AIMBOT_MASTER = false
local CURSOR_AIMBOT = false        -- New: Cursor Aimbot Toggle
local holding = false
local currentTarget = nil
local AquaColor = Color3.fromRGB(0, 255, 255)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Radius = FOV_RADIUS
fovCircle.Filled = false
fovCircle.Color = AquaColor
fovCircle.Transparency = 0.6
fovCircle.Visible = false

-- Validation
local function isValidTarget(player)
    if not player or player == LocalPlayer then return false end
    if TEAM_CHECK and player.Team == LocalPlayer.Team then return false end
   
    local character = player.Character
    if not character then return false end
   
    local humanoid = character:FindFirstChild("Humanoid")
    local targetPart = character:FindFirstChild(AIM_PART)
   
    if not humanoid or humanoid.Health <= 0 or not targetPart then return false end
    return true, targetPart
end

-- Get Closest Target
local function getClosestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local closestDist = FOV_RADIUS
   
    for _, player in ipairs(Players:GetPlayers()) do
        local valid, targetPart = isValidTarget(player)
        if valid and targetPart then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Camera Aimbot (Original Silent Aim)
local function aimAt(target)
    if not target or not target.Character then return end
    local targetPart = target.Character:FindFirstChild(AIM_PART)
    if not targetPart then return end
   
    local predictedPos = targetPart.Position + (targetPart.Velocity * PREDICTION)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
   
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, SMOOTHNESS)
end

-- New: Cursor Aimbot (Moves Mouse)
local function cursorAimAt(target)
    if not target or not target.Character then return end
    local targetPart = target.Character:FindFirstChild(AIM_PART)
    if not targetPart then return end
   
    local predictedPos = targetPart.Position + (targetPart.Velocity * PREDICTION)
    local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
   
    if onScreen then
        local mousePos = UserInputService:GetMouseLocation()
        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
        
        -- Move mouse towards target with smoothness
        local newMousePos = mousePos:Lerp(targetScreenPos, SMOOTHNESS)
        
        -- This is the most reliable way in most Roblox executors
        mousemoverel((newMousePos.X - mousePos.X), (newMousePos.Y - mousePos.Y))
    end
end

-- ESP Function (unchanged)
local function CreateVisuals(Player)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    Box.Color = AquaColor
    Tracer.Color = AquaColor
    Box.Thickness = 1
    Tracer.Thickness = 1

    RunService.RenderStepped:Connect(function()
        local valid, _ = isValidTarget(Player)
        if valid and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
           
            if OnScreen then
                if ESP_ENABLED then
                    local SizeY = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - 
                                  Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                    Box.Size = Vector2.new(SizeY * 0.6, SizeY)
                    Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                    Box.Visible = true
                else 
                    Box.Visible = false 
                end
                
                if TRACERS_ENABLED then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y)
                    Tracer.Visible = true
                else 
                    Tracer.Visible = false 
                end
            else 
                Box.Visible = false 
                Tracer.Visible = false 
            end
        else 
            Box.Visible = false 
            Tracer.Visible = false 
        end
    end)
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holding = false
        currentTarget = nil
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = mousePos
    fovCircle.Radius = FOV_RADIUS
    fovCircle.Visible = AIMBOT_MASTER or CURSOR_AIMBOT

    if (AIMBOT_MASTER or CURSOR_AIMBOT) and holding then
        if not currentTarget or not isValidTarget(currentTarget) then
            currentTarget = getClosestTarget()
        end
       
        if currentTarget then
            if CURSOR_AIMBOT then
                cursorAimAt(currentTarget)
            elseif AIMBOT_MASTER then
                aimAt(currentTarget)
            end
        end
    end
end)

-- Initialize ESP
for _, p in pairs(Players:GetPlayers()) do 
    CreateVisuals(p) 
end
Players.PlayerAdded:Connect(CreateVisuals)

--- UI TABS ---
local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateToggle({
   Name = "Master Aimbot (Camera)",
   CurrentValue = false,
   Callback = function(v) 
       AIMBOT_MASTER = v 
       if v then CURSOR_AIMBOT = false end  -- Disable the other mode
   end,
})

CombatTab:CreateToggle({
   Name = "Cursor Aimbot (Mouse)",
   CurrentValue = false,
   Callback = function(v) 
       CURSOR_AIMBOT = v 
       if v then AIMBOT_MASTER = false end  -- Disable the other mode
   end,
})

CombatTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Callback = function(v) TEAM_CHECK = v end,
})

CombatTab:CreateSlider({
   Name = "Prediction Strength",
   Range = {0, 0.2},
   Increment = 0.01,
   CurrentValue = 0.08,
   Callback = function(v) PREDICTION = v end,
})

CombatTab:CreateSlider({
   Name = "Smoothness",
   Range = {0.01, 1},
   Increment = 0.05,
   CurrentValue = 0.25,
   Callback = function(v) SMOOTHNESS = v end,
})

local VisualTab = Window:CreateTab("Visuals")

VisualTab:CreateToggle({
   Name = "Aqua Boxes",
   CurrentValue = false,
   Callback = function(v) ESP_ENABLED = v end,
})

VisualTab:CreateToggle({
   Name = "Aqua Tracers",
   CurrentValue = false,
   Callback = function(v) TRACERS_ENABLED = v end,
})

VisualTab:CreateSlider({
   Name = "FOV Circle Size",
   Range = {50, 800},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(v) FOV_RADIUS = v end,
})

Rayfield:Notify({
   Title = "RigWare Successfully Injected",
   Content = "Last Detection Never",
   Duration = 10,
   Image = 4483362458,
})
