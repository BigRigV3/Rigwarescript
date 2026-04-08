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
local AimActive = false
local SelectedBind = Enum.UserInputType.MouseButton2

local function GetFlagValue(flagName, key, fallback)
    local flag = Rayfield.Flags[flagName]
    if type(flag) ~= "table" then
        return fallback
    end

    local value = flag[key]
    if value == nil then
        return fallback
    end

    return value
end

local function GetColorFlagValue(flagName, fallback)
    local flag = Rayfield.Flags[flagName]
    if type(flag) ~= "table" then
        return fallback
    end

    return flag.Color or flag.CurrentValue or fallback
end

local function NormalizeBind(bind)
    if typeof(bind) == "EnumItem" then
        return bind
    end

    if type(bind) == "string" then
        return Enum.UserInputType[bind] or Enum.KeyCode[bind] or SelectedBind
    end

    return SelectedBind
end

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
      SelectedBind = NormalizeBind(Key)
      local mode = GetFlagValue("Aim_Mode", "CurrentOption", {"Hold"})
      if mode[1] == "Toggle" then
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
    Flag = "Aim_Team_Check",
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
    Flag = "ESP_Team_Check",
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
            if GetFlagValue("ESP_Team_Check", "CurrentValue", false) and Player.Team == LocalPlayer.Team then
                IsEnemy = false
            end

            -- Update Visibility
            if HRP and Hum and Hum.Health > 0 and IsEnemy then
                local Pos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
                local Distance = (Camera.CFrame.Position - HRP.Position).Magnitude
                
                if OnScreen and Distance <= GetFlagValue("ESP_Dist", "CurrentValue", 2000) then
                    
                    -- Box Logic
                    if GetFlagValue("Box_Enabled", "CurrentValue", false) then
                        -- Calculate 2D Box Size based on distance
                        local Top = Camera:WorldToViewportPoint(HRP.Position + Vector3.new(0, 3.5, 0))
                        local Bottom = Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0, 4.5, 0))
                        local Height = math.abs(Top.Y - Bottom.Y)
                        local Width = Height * 0.6
                        
                        Drawings.Box.Size = Vector2.new(Width, Height)
                        Drawings.Box.Position = Vector2.new(Pos.X - (Width / 2), Pos.Y - (Height / 2))
                        Drawings.Box.Color = GetColorFlagValue("Box_Col", Color3.fromRGB(255, 255, 255))
                        Drawings.Box.Visible = true
                    else
                        Drawings.Box.Visible = false
                    end
                    
                    -- Tracer Logic
                    if GetFlagValue("Tracer_Enabled", "CurrentValue", false) then
                        Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        Drawings.Tracer.To = Vector2.new(Pos.X, Pos.Y)
                        Drawings.Tracer.Color = GetColorFlagValue("Tracer_Col", Color3.fromRGB(255, 0, 0))
                        Drawings.Tracer.Visible = true
                    else
                        Drawings.Tracer.Visible = false
                    end
                    
                    -- Name Logic
                    if GetFlagValue("Name_Enabled", "CurrentValue", false) then
                        local boxHeight = Drawings.Box.Visible and Drawings.Box.Size.Y or 40
                        Drawings.Name.Position = Vector2.new(Pos.X, Pos.Y - (boxHeight / 2) - 20)
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
    local MaxDist = GetFlagValue("FOV_Radius", "CurrentValue", 150)
    
    for _, v in pairs(Players:GetPlayers()) do
        local Character = v.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")

        if v ~= LocalPlayer and Character and Character:FindFirstChild("HumanoidRootPart") and Humanoid and Humanoid.Health > 0 then
            local OnSameTeam = (v.Team == LocalPlayer.Team)
            if not GetFlagValue("Aim_Team_Check", "CurrentValue", true) or not OnSameTeam then
                local currentOption = GetFlagValue("Aim_Part", "CurrentOption", {"Head"})
                local targetPartName = currentOption[1] or "Head"
                local Part = Character:FindFirstChild(targetPartName)
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
    local mode = GetFlagValue("Aim_Mode", "CurrentOption", {"Hold"})
    if mode[1] == "Hold" then
        if i.KeyCode == SelectedBind or i.UserInputType == SelectedBind then
            AimActive = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(i)
    local mode = GetFlagValue("Aim_Mode", "CurrentOption", {"Hold"})
    if mode[1] == "Hold" then
        if i.KeyCode == SelectedBind or i.UserInputType == SelectedBind then
            AimActive = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = GetFlagValue("Show_FOV", "CurrentValue", true)
    FOVCircle.Radius = GetFlagValue("FOV_Radius", "CurrentValue", 150)
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)

    if GetFlagValue("Aim_Enabled", "CurrentValue", false) and AimActive then
        local Target = GetClosestPlayer()
        if Target then
            local ScreenPos = Camera:WorldToViewportPoint(Target.Position)
            local MousePos = UserInputService:GetMouseLocation()
            local Smoothness = math.max(GetFlagValue("Aim_Smooth", "CurrentValue", 5), 1)
            if mousemoverel then
                mousemoverel((ScreenPos.X - MousePos.X) / Smoothness, (ScreenPos.Y - MousePos.Y) / Smoothness)
            end
        end
    end

    if GetFlagValue("Trigger_Enabled", "CurrentValue", false) then
        local MouseTarget = LocalPlayer:GetMouse().Target
        if MouseTarget and MouseTarget.Parent:FindFirstChild("Humanoid") then
            local TargetPlayer = Players:GetPlayerFromCharacter(MouseTarget.Parent)
            if TargetPlayer and (not GetFlagValue("Aim_Team_Check", "CurrentValue", true) or TargetPlayer.Team ~= LocalPlayer.Team) then
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
