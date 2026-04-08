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
         print("Authorized... Executing Main Script...")
         

		loadstring(game:HttpGet('https://raw.githubusercontent.com/BigRigV3/Rigwarescript/refs/heads/main/RigWare.lua'))()
        
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
