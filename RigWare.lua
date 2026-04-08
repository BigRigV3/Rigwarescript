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


-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer



-- // Storage
local ESPData = {}

-- // Helper: Create Drawing Objects
local function CreateESP(Player)
    if ESPData[Player] then return end
    
    ESPData[Player] = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text")
    }
    
    local d = ESPData[Player]
    -- Box Defaults
    d.Box.Thickness = 1
    d.Box.Filled = false
    d.Box.Visible = false
    -- Tracer Defaults
    d.Tracer.Thickness = 1
    d.Tracer.Visible = false
    -- Name Defaults
    d.Name.Size = 16
    d.Name.Center = true
    d.Name.Outline = true
    d.Name.Visible = false
end

-- // Helper: Remove Drawing Objects
local function RemoveESP(Player)
    if ESPData[Player] then
        for _, obj in pairs(ESPData[Player]) do
            obj:Remove()
        end
        ESPData[Player] = nil
    end
end



local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateSection("Aimbot Core")

CombatTab:CreateToggle({
    Name = "Master Enable",
    CurrentValue = false,
    Flag = "Aim_Enabled",
    Callback = function(v) if not v then AimActive = false end end
})

CombatTab:CreateDropdown({
    Name = "Activation Mode",
    Options = {"Hold", "Toggle"},
    CurrentOption = {"Hold"},
    MultipleOptions = false,
    Flag = "Aim_Mode",
    Callback = function() AimActive = false end
})

CombatTab:CreateKeybind({
   Name = "Aim Keybind",
   CurrentKeybind = "MouseButton2",
   HoldToInteract = false,
   Flag = "Aim_Bind",
   Callback = function(Key)
      SelectedBind = Key
      if Rayfield.Flags.Aim_Mode.CurrentOption[1] == "Toggle" then
          AimActive = not AimActive
      end
   end,
})

CombatTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "Aim_Part",
    Callback = function() end
})

CombatTab:CreateSlider({
    Name = "Smoothing",
    Range = {0, 20},
    Increment = 1,
    CurrentValue = 5,
    Flag = "Aim_Smooth",
    Callback = function() end
})

CombatTab:CreateSection("Targeting Rules")

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "Team_Check",
    Callback = function() end
})

CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Flag = "Show_FOV",
    Callback = function() end
})

CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {10, 800},
    Increment = 10,
    CurrentValue = 150,
    Flag = "FOV_Radius",
    Callback = function() end
})

CombatTab:CreateSection("Triggerbot")

CombatTab:CreateToggle({
    Name = "Enable Triggerbot",
    CurrentValue = false,
    Flag = "Trigger_Enabled",
    Callback = function() end
})





-- // --- VISUALS TAB --- //
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local MainSection = VisualsTab:CreateSection("ESP Toggles")

local TeamToggle = VisualsTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "Team_Check",
    Callback = function() end,
})

local BoxToggle = VisualsTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Flag = "Box_Enabled",
    Callback = function() end,
})

local TracerToggle = VisualsTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Flag = "Tracer_Enabled",
    Callback = function() end,
})

local NameToggle = VisualsTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "Name_Enabled",
    Callback = function() end,
})

local SettingsSection = VisualsTab:CreateSection("Settings & Colors")

local DistSlider = VisualsTab:CreateSlider({
    Name = "Max Distance",
    Range = {0, 10000},
    Increment = 100,
    Suffix = " Studs",
    CurrentValue = 2000,
    Flag = "ESP_Dist",
    Callback = function() end,
})

local BoxColor = VisualsTab:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "Box_Col",
    Callback = function() end,
})

local TracerColor = VisualsTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "Tracer_Col",
    Callback = function() end,
})

-- // --- CORE RENDER LOOP --- //
RunService.RenderStepped:Connect(function()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            -- Create objects if they don't exist for this player
            if not ESPData[Player] then CreateESP(Player) end
            
            local Drawings = ESPData[Player]
            local Char = Player.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            -- Logic Variables
            local IsEnemy = true
            if Rayfield.Flags.Team_Check.CurrentValue and Player.Team == LocalPlayer.Team then
                IsEnemy = false
            end

            -- Update Visibility
            if HRP and Hum and Hum.Health > 0 and IsEnemy then
                local Pos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
                local Distance = (Camera.CFrame.Position - HRP.Position).Magnitude
                
                if OnScreen and Distance <= Rayfield.Flags.ESP_Dist.CurrentValue then
                    
                    -- Box Logic
                    if Rayfield.Flags.Box_Enabled.CurrentValue then
                        -- Calculate 2D Box Size based on distance
                        local Top = Camera:WorldToViewportPoint(HRP.Position + Vector3.new(0, 3.5, 0))
                        local Bottom = Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 4.5, 0))
                        local Height = math.abs(Top.Y - Bottom.Y)
                        local Width = Height * 0.6
                        
                        Drawings.Box.Size = Vector2.new(Width, Height)
                        Drawings.Box.Position = Vector2.new(Pos.X - (Width / 2), Pos.Y - (Height / 2))
                        Drawings.Box.Color = Rayfield.Flags.Box_Col.Color
                        Drawings.Box.Visible = true
                    else
                        Drawings.Box.Visible = false
                    end
                    
                    -- Tracer Logic
                    if Rayfield.Flags.Tracer_Enabled.CurrentValue then
                        Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        Drawings.Tracer.To = Vector2.new(Pos.X, Pos.Y)
                        Drawings.Tracer.Color = Rayfield.Flags.Tracer_Col.Color
                        Drawings.Tracer.Visible = true
                    else
                        Drawings.Tracer.Visible = false
                    end
                    
                    -- Name Logic
                    if Rayfield.Flags.Name_Enabled.CurrentValue then
                        Drawings.Name.Position = Vector2.new(Pos.X, Pos.Y - (Drawings.Box.Size.Y / 2) - 20)
                        Drawings.Name.Text = string.format("%s [%d]", Player.Name, math.floor(Distance))
                        Drawings.Name.Color = Color3.new(1, 1, 1)
                        Drawings.Name.Visible = true
                    else
                        Drawings.Name.Visible = false
                    end
                else
                    Drawings.Box.Visible = false
                    Drawings.Tracer.Visible = false
                    Drawings.Name.Visible = false
                end
            else
                -- Off-screen, dead, or same team
                Drawings.Box.Visible = false
                Drawings.Tracer.Visible = false
                Drawings.Name.Visible = false
            end
        end
    end
end)

-- Cleanup
Players.PlayerRemoving:Connect(RemoveESP)




-- // Internal Variables
local AimActive = false
local SelectedBind = Enum.UserInputType.MouseButton2

-- // FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

-- // --- FUNCTIONS --- //

local function GetClosestPlayer()
    local Closest = nil
    local MaxDist = Rayfield.Flags.FOV_Radius.CurrentValue
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local OnSameTeam = (v.Team == LocalPlayer.Team)
            if not Rayfield.Flags.Team_Check.CurrentValue or not OnSameTeam then
                local Part = v.Character:FindFirstChild(Rayfield.Flags.Aim_Part.CurrentOption[1])
                if Part then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local MousePos = UserInputService:GetMouseLocation()
                        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                        if Dist < MaxDist then
                            MaxDist = Dist
                            Closest = Part
                        end
                    end
                end
            end
        end
    end
    return Closest
end

-- // --- UI TABS --- //



-- // --- INPUT & LOOPS --- //

UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if Rayfield.Flags.Aim_Mode.CurrentOption[1] == "Hold" then
        if i.KeyCode == SelectedBind or i.UserInputType == SelectedBind then
            AimActive = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if Rayfield.Flags.Aim_Mode.CurrentOption[1] == "Hold" then
        if i.KeyCode == SelectedBind or i.UserInputType == SelectedBind then
            AimActive = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Rayfield.Flags.Show_FOV.CurrentValue
    FOVCircle.Radius = Rayfield.Flags.FOV_Radius.CurrentValue
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)

    if Rayfield.Flags.Aim_Enabled.CurrentValue and AimActive then
        local Target = GetClosestPlayer()
        if Target then
            local ScreenPos = Camera:WorldToViewportPoint(Target.Position)
            local MousePos = UserInputService:GetMouseLocation()
            local Smoothness = Rayfield.Flags.Aim_Smooth.CurrentValue
            if mousemoverel then
                mousemoverel((ScreenPos.X - MousePos.X) / Smoothness, (ScreenPos.Y - MousePos.Y) / Smoothness)
            end
        end
    end

    if Rayfield.Flags.Trigger_Enabled.CurrentValue then
        local MouseTarget = LocalPlayer:GetMouse().Target
        if MouseTarget and MouseTarget.Parent:FindFirstChild("Humanoid") then
            local TargetPlayer = Players:GetPlayerFromCharacter(MouseTarget.Parent)
            if TargetPlayer and (not Rayfield.Flags.Team_Check.CurrentValue or TargetPlayer.Team ~= LocalPlayer.Team) then
                if mouse1click then mouse1click() end
            end
        end
    end
end)

Rayfield:Notify({
   Title = "RigWare Successfully Injected",
   Content = "Last Detection Never",
   Duration = 5,
   Image = 4483362458,
})
