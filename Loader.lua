print('Loader Setting Up')
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

--* Configuration *--
local Name = "Damo123vb's%20Application"
local Ownerid = "pLEiJYycEG" 
local APPVersion = "1.0"
local sessionid = ""
local EnteredKey = ""

--* Initial API Handshake *--
local init_url = 'https://keyauth.win/api/1.1/?name=' .. Name .. '&ownerid=' .. Ownerid .. '&type=init&ver=' .. APPVersion
local success, req = pcall(function() return game:HttpGet(init_url) end)

if not success or req == "KeyAuth_Invalid" then 
    warn("Error: Application not found in KeyAuth Dashboard.")
    return
end

local data = HttpService:JSONDecode(req)
if data.success then
    sessionid = data.sessionid
else
    warn("Init Failed: " .. tostring(data.message))
    return
end

--* Load Rayfield UI Library *--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "RigWare Loader",
   LoadingTitle = "Loader",
   LoadingSubtitle = "by BigRig",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false -- We are using our own KeyAuth system below
})

local Tab = Window:CreateTab("Authentication", 4483362458) -- Icon ID
local Section = Tab:CreateSection("License Activation")

--* Rayfield Input Field *--
local Input = Tab:CreateInput({
   Name = "Enter License Key",
   PlaceholderText = "Paste Key Here",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      EnteredKey = Text
   end,
})

--* Activation Button *--
local Button = Tab:CreateButton({
    Name = "Activate License",
    Callback = function()
        if EnteredKey == "" then
            Rayfield:Notify({
                Title = "Input Error",
                Content = "Please enter a key before activating!",
                Duration = 5,
                Image = 4483362458,
            })
            return
        end

        -- Wrap the network request in a pcall to catch "Callback Errors"
        local success, err = pcall(function()
            local license_url = 'https://keyauth.win/api/1.1/?name=' .. Name .. '&ownerid=' .. Ownerid .. '&type=license&key=' .. EnteredKey .. '&ver=' .. APPVersion .. '&sessionid=' .. sessionid
            local license_req = game:HttpGet(license_url)
            local license_data = HttpService:JSONDecode(license_req)

            if license_data and license_data.success then
                Rayfield:Notify({
                    Title = "Success",
                    Content = "Access Granted! Loading script...",
                    Duration = 5,
                    Image = 4483362458,
                })
                
                task.wait(1)
                Rayfield:Destroy() 

                print("Authorized... Executing Main Script...")
                loadstring(game:HttpGet('https://pastebin.com/raw/CLxwZx21'))()
            else
                local msg = (license_data and license_data.message) or "Invalid Key or Connection Error"
                Rayfield:Notify({
                    Title = "Activation Failed",
                    Content = msg,
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        end)

        if not success then
            warn("Callback Error: " .. tostring(err))
            Rayfield:Notify({
                Title = "Critical Error",
                Content = "An internal error occurred. Check the console (F9).",
                Duration = 5,
            })
        end
    end,
})
      -- KeyAuth License Request
      local license_url = 'https://keyauth.win/api/1.1/?name=' .. Name .. '&ownerid=' .. Ownerid .. '&type=license&key=' .. EnteredKey .. '&ver=' .. APPVersion .. '&sessionid=' .. sessionid
      local license_req = game:HttpGet(license_url)
      local license_data = HttpService:JSONDecode(license_req)
      
      if license_data.success then
         Rayfield:Notify({
            Title = "Success",
            Content = "Access Granted! Loading script...",
            Duration = 5,
            Image = 4483362458,
         })
         
         task.wait(1)
         Rayfield:Destroy() -- Close the loader

         ---------------------------------------------------------
         -- YOUR MAIN SCRIPT GOES HERE
         ---------------------------------------------------------
         print("Authorized... Injecting...")
         

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

-- Aimbot Variables
local AIM_PART = "Head"
local SMOOTHNESS = 0.25
local FOV_RADIUS = 150
local TEAM_CHECK = false
local PREDICTION = 0.08
local ESP_ENABLED = false
local TRACERS_ENABLED = false

local AIMBOT_MASTER = false      -- Camera Aimbot
local CURSOR_AIMBOT = false      -- Cursor (Mouse) Aimbot
local holding = false
local currentTarget = nil
local AquaColor = Color3.fromRGB(0, 255, 255)

-- Fly & Movement Variables
local flying = false
local noclipping = false
local flySpeed = 50
local connectionFly
local connectionNoclip
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Radius = FOV_RADIUS
fovCircle.Filled = false
fovCircle.Color = AquaColor
fovCircle.Transparency = 0.6
fovCircle.Visible = false

-- ====================== VALIDATION & TARGETING ======================
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

-- ====================== AIMBOT FUNCTIONS ======================
local function aimAt(target)  -- Camera Aimbot
    if not target or not target.Character then return end
    local targetPart = target.Character:FindFirstChild(AIM_PART)
    if not targetPart then return end
   
    local predictedPos = targetPart.Position + (targetPart.Velocity * PREDICTION)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, SMOOTHNESS)
end

local function cursorAimAt(target)  -- Cursor Aimbot
    if not target or not target.Character then return end
    local targetPart = target.Character:FindFirstChild(AIM_PART)
    if not targetPart then return end
   
    local predictedPos = targetPart.Position + (targetPart.Velocity * PREDICTION)
    local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
   
    if onScreen then
        local mousePos = UserInputService:GetMouseLocation()
        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
        local newMousePos = mousePos:Lerp(targetScreenPos, SMOOTHNESS)
        
        mousemoverel((newMousePos.X - mousePos.X), (newMousePos.Y - mousePos.Y))
    end
end

-- ====================== FLY & NOCLIP ======================
local function startFly()
    if flying then return end
    flying = true

    local BodyVelocity = Instance.new("BodyVelocity")
    local BodyGyro = Instance.new("BodyGyro")
    BodyVelocity.Name = "FlyVelocity"
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = RootPart

    BodyGyro.Name = "FlyGyro"
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.P = 9e4
    BodyGyro.Parent = RootPart

    connectionFly = RunService.Heartbeat:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection -= Vector3.new(0, 1, 0) end

        BodyVelocity.Velocity = moveDirection.Unit * flySpeed
        BodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if not flying then return end
    flying = false
    if connectionFly then connectionFly:Disconnect() end
    local bv = RootPart:FindFirstChild("FlyVelocity")
    local bg = RootPart:FindFirstChild("FlyGyro")
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

local function startNoclip()
    if noclipping then return end
    noclipping = true
    connectionNoclip = RunService.Stepped:Connect(function()
        if not noclipping then return end
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if not noclipping then return end
    noclipping = false
    if connectionNoclip then connectionNoclip:Disconnect() end
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- ====================== ESP ======================
local function CreateVisuals(Player)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    Box.Color = AquaColor
    Tracer.Color = AquaColor
    Box.Thickness = 1
    Tracer.Thickness = 1

    RunService.RenderStepped:Connect(function()
        local valid = isValidTarget(Player)
        if valid and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Root = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
           
            if OnScreen then
                if ESP_ENABLED then
                    local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - 
                                  Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                    Box.Size = Vector2.new(SizeY * 0.6, SizeY)
                    Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                    Box.Visible = true
                else Box.Visible = false end
                
                if TRACERS_ENABLED then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y)
                    Tracer.Visible = true
                else Tracer.Visible = false end
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

-- ====================== INPUT & MAIN LOOP ======================
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

-- Initialize ESP for existing players
for _, p in pairs(Players:GetPlayers()) do 
    CreateVisuals(p) 
end
Players.PlayerAdded:Connect(CreateVisuals)

-- Character Respawn Handler (for Fly/Noclip)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

--- ====================== UI TABS ======================
local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateToggle({
   Name = "Master Aimbot (Camera)",
   CurrentValue = false,
   Callback = function(v) 
       AIMBOT_MASTER = v 
       if v then CURSOR_AIMBOT = false end
   end,
})

CombatTab:CreateToggle({
   Name = "Cursor Aimbot (Mouse)",
   CurrentValue = false,
   Callback = function(v) 
       CURSOR_AIMBOT = v 
       if v then AIMBOT_MASTER = false end
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

local MovementTab = Window:CreateTab("Movement")

MovementTab:CreateToggle({
   Name = "Flight",
   CurrentValue = false,
   Callback = function(Value)
       if Value then startFly() else stopFly() end
   end
})

MovementTab:CreateSlider({
   Name = "Flight Speed",
   Range = {10, 300},
   Increment = 5,
   Suffix = " studs/s",
   CurrentValue = 50,
   Callback = function(Value) flySpeed = Value end
})

MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(Value)
       if Value then startNoclip() else stopNoclip() end
   end
})

MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = " studs/s",
   CurrentValue = Humanoid.WalkSpeed,
   Callback = function(Value)
       if Humanoid then Humanoid.WalkSpeed = Value end
   end
})

MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 5,
   CurrentValue = Humanoid.JumpPower,
   Callback = function(Value)
       if Humanoid then Humanoid.JumpPower = Value end
   end
})

MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           local jumpConn = UserInputService.JumpRequest:Connect(function()
               if Humanoid then
                   Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
               end
           end)
           -- Store connection if you want to disconnect later
       end
   end
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
        
         ---------------------------------------------------------
         
      else
         Rayfield:Notify({
            Title = "Activation Failed",
            Content = "Error: " .. (license_data.message or "Invalid Key"),
            Duration = 5,
            Image = 4483362458,
         })
      end


local InfoTab = Window:CreateTab("Information", 4483362458)
InfoTab:CreateSection("Application Details")
InfoTab:CreateLabel("Users Online: " .. (data.appinfo.numOnlineUsers or "0"))
InfoTab:CreateLabel("App Version: " .. APPVersion)
