local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/p4re/hugbug/main/UI.lua"))()
local Skeleton = loadstring(game:HttpGet("https://raw.githubusercontent.com/p4re/hugbug/main/Skeleton.lua"))()

_G.mastervis = false

getgenv().aC8bug = {
	["Silent Aim"] = {["Key"] = Enum.KeyCode.Q, ["Enabled"] = false},
    ["Triggerbot"] = {["Key"] = Enum.KeyCode.T, ["Enabled"] = false},
    ["BunnyHop"] = {["Key"] = Enum.KeyCode.J, ["Enabled"] = false},
    ["Spinbot"] = {["Key"] = Enum.KeyCode.B, ["Enabled"] = false},
    ["Flight"] = {["Key"] = Enum.KeyCode.V, ["Enabled"] = false},
    ["Skeleton"] = {["Key"] = Enum.KeyCode.L, ["Enabled"] = false},
    ["ESP"] = {["Key"] = Enum.KeyCode.P, ["Enabled"] = false},
    ["Packet"] = {["Key"] = Enum.KeyCode.Z, ["Enabled"] = false},
    ["ForceFieldCheck"] = {["Enabled"] = true},
    ["IsVisibleCheck"] = {["Enabled"] = true},
    ["TriggerbotClickDelay"] = {["Value"] = 0.1},
    ["TriggerbotReleaseDelay"] = {["Value"] = 0.025},
    ["BunnyHopSpeed"] = {["Value"] = 0.5},
    ["FlightSpeed"] = {["Value"] = 20},
    ["HitPart"] = {["Value"] = "Head"}
}

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local FindFirstChildOfClass = game.FindFirstChildOfClass
local GetMouseLocation = UserInputService.GetMouseLocation


-- // esp shiet

local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom", -- Middle or Bottom if FollowMouse is on this won't matter...
    Tracer_FollowMouse = false,
    Tracers = true
}
local Team_Check = {
    TeamCheck = false, -- if TeamColor is on this won't matter...
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}
local TeamColor = true

--// SEPARATION
local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = player:GetMouse()

local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0,0)
    quad.PointB = Vector2.new(0,0)
    quad.PointC = Vector2.new(0,0)
    quad.PointD = Vector2.new(0,0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color 
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Visibility(state, lib)
    for u, x in pairs(lib) do
		if _G.mastervis == false then
			x.Visible = false
		else
       		x.Visible = state
		end
    end
end

local function ToColor3(col) --Function to convert, just cuz c;
    local r = col.r --Red value
    local g = col.g --Green value
    local b = col.b --Blue value
    return Color3.new(r,g,b); --Color3 datatype, made of the RGB inputs
end

local black = Color3.fromRGB(0, 0 ,0)
local function ESP(plr)
    local library = {
        --//Tracer and Black Tracer(black border)
        blacktracer = NewLine(Settings.Tracer_Thickness*2, black),
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        --//Box and Black Box(black border)
        black = NewQuad(Settings.Box_Thickness*2, black),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        --//Bar and Green Health Bar (part that moves up/down)
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black)
    }

    local function Colorize(color)
        for u, x in pairs(library) do
            if x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black then
                x.Color = color
            end
        end
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") ~= nil then
                local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)
                    
                    local function Size(item)
                        item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY*2)
                        item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2)
                        item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)
                        item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY*2)
                    end
                    Size(library.box)
                    Size(library.black)

                    --//Tracer 
                    if Settings.Tracers then
                        if Settings.Tracer_Origin == "Middle" then
                            library.tracer.From = camera.ViewportSize*0.5
                            library.blacktracer.From = camera.ViewportSize*0.5
                        elseif Settings.Tracer_Origin == "Bottom" then
                            library.tracer.From = Vector2.new(camera.ViewportSize.X*0.5, camera.ViewportSize.Y) 
                            library.blacktracer.From = Vector2.new(camera.ViewportSize.X*0.5, camera.ViewportSize.Y)
                        end
                        if Settings.Tracer_FollowMouse then
                            library.tracer.From = Vector2.new(mouse.X, mouse.Y+36)
                            library.blacktracer.From = Vector2.new(mouse.X, mouse.Y+36)
                        end
                        library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                        library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                    else 
                        library.tracer.From = Vector2.new(0, 0)
                        library.blacktracer.From = Vector2.new(0, 0)
                        library.tracer.To = Vector2.new(0, 0)
                        library.blacktracer.To = Vector2.new(0, 02)
                    end

                    --// Health Bar
                    local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)).magnitude 
                    local healthoffset = plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth * d

                    library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                    library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2 - healthoffset)

                    library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                    library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY*2)

                    local green = Color3.fromRGB(0, 255, 0)
                    local red = Color3.fromRGB(255, 0, 0)

                    library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth);

                    if Team_Check.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            Colorize(Team_Check.Green)
                        else 
                            Colorize(Team_Check.Red)
                        end
                    else 
                        library.tracer.Color = Settings.Tracer_Color
                        library.box.Color = Settings.Box_Color
                    end
                    if TeamColor == true then
                        Colorize(plr.TeamColor.Color)
                    end
                    Visibility(true, library)
                else 
                    Visibility(false, library)
                end
            else 
                Visibility(false, library)
                if game.Players:FindFirstChild(plr.Name) == nil then
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Updater)()
end

for i, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= player.Name then
        coroutine.wrap(ESP)(v)
    end
end

game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= player.Name then
        coroutine.wrap(ESP)(newplr)
    end
end)

-- // Silent Aim Functions

local function GetScreenPosition(Vector)
    local ScreenPosition, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(ScreenPosition.X, ScreenPosition.Y), OnScreen
end

local function IsPlayerVisible(Player)
    local Target = Player.Character
    local Character = LocalPlayer.Character
    
    if not (Target or Character) then return end 
    
    local Part = FindFirstChild(Target, "Head")
    
    if not Part then return end 
    
    local CastPoints, IgnoreList = {Part.Position, Character, Target}, {Character, Target}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)

   	return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
end

local function GetClosest()
    local Minimum, Closest = math.huge
    local MouseLocation = GetMouseLocation(UserInputService)    

    for _, Player in next, GetPlayers(Players) do
        if Player == LocalPlayer then continue end
		if Player.Team == LocalPlayer.Team and not (Player.Neutral and LocalPlayer.Neutral) then continue end

        local Character = Player.Character
        if not Character then continue end

		if aC8bug["IsVisibleCheck"]["Enabled"] and not IsPlayerVisible(Player) then continue end
       
        local Possibilities = {"Head","HumanoidRootPart"}
        if aC8bug["HitPart"]["Value"] == "Random" then 
            Part = FindFirstChild(Character, Possibilities[math.random(1,2)] )
        elseif aC8bug["HitPart"]["Value"] == "Root" then 
            Part = FindFirstChild(Character, Possibilities[2] )
        elseif aC8bug["HitPart"]["Value"] == "Head" then 
            Part = FindFirstChild(Character, Possibilities[1] )
        end
        local Humanoid = FindFirstChild(Character, "Humanoid")
        if not Part or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

        local ScreenPosition, OnScreen = GetScreenPosition(Part.Position)

        local Distance = (MouseLocation - ScreenPosition).Magnitude

        if Distance <= Minimum and OnScreen then
            Closest = Part
            Minimum = Distance
        end
    end

    return Closest
end

local __namecall
__namecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
	local Main = Arguments[2]

    if aC8bug["Silent Aim"]["Enabled"] and self == workspace and not checkcaller() then
		local Hit = GetClosest()

		if Hit then
	        if Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist" or Method == "FindPartOnRay" or Method == "findPartOnRay" then
                local Origin = Main.Origin
                local Direction = (Hit.Position - Origin).Unit * 15000
                Arguments[2] = Ray.new(Origin, Direction)

                return __namecall(unpack(Arguments))
	        elseif Method == "Raycast" then
                Arguments[3] = (Hit.Position - Main).Unit * 15000

                return __namecall(unpack(Arguments))
	        end
		end
    end

    return __namecall(...)
end))

local __index = nil 
__index = hookmetamethod(game, "__index", newcclosure(function(self, Index)
    if aC8bug["Silent Aim"]["Enabled"] and self == Mouse and not checkcaller() then
        local Hit = GetClosest()

        if Hit then
	        if Index == "Target" or Index == "target" then 
	            return Hit
	        elseif Index == "Hit" or Index == "hit" then 
	            return Hit.CFrame
	        elseif Index == "UnitRay" then 
	            return Ray.new(self.Origin, (self.Hit - self.Origin).Unit)
			else
				 local ScreenPosition, OnScreen = GetScreenPosition(Hit.Position)

				if Index == "X" or Index == "x" then 
		            return ScreenPosition.X 
		        elseif Index == "Y" or Index == "y" then 
		            return ScreenPosition.Y 
		        end
			end
		end
    end

    return __index(self, Index)
end))

RunService.Heartbeat:Connect(function()
    if aC8bug["BunnyHop"]["Enabled"] == true then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            spawn(function()
                if Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and Humanoid.MoveDirection.Magnitude > 0 then
                    Humanoid.UseJumpPower = false
                    Humanoid:ChangeState("Jumping")
                end
            end)
            spawn(function()
                if Humanoid.FloorMaterial == Enum.Material.Air then
                    RootPart.CFrame += Humanoid.MoveDirection * aC8bug["BunnyHopSpeed"]["Value"] 
                end
            end)
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            Humanoid.UseJumpPower = true
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if aC8bug["Spinbot"]["Enabled"] == true then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            spawn(function()
                RootPart.CFrame *= CFrame.Angles(0,math.rad(70),0)
            end)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    task.wait(0.025)
    if aC8bug["Skeleton"]["Enabled"] == false then
        for i,v in next, _G.limbs do
            v.Transparency = 0
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if aC8bug["Flight"]["Enabled"] == true then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local CamCF = Camera.CFrame
            local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not UserInputService:GetFocusedTextBox() then
                local cVector = Vector3.new()
                local RightVector, LookVector, UpVector = CamCF.RightVector, CamCF.LookVector, CamCF.UpVector
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    cVector = cVector + LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    cVector = cVector - LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    cVector = cVector + RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    cVector = cVector - RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    cVector = cVector + UpVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    cVector = cVector - UpVector
                end
                if cVector.Unit.X == cVector.Unit.X then
                    RootPart.AssemblyLinearVelocity  = cVector.Unit * aC8bug["FlightSpeed"]["Value"]*10
                end
                RootPart.Anchored = cVector == Vector3.new()
            end
        end
    end
end)

local Clock = os.clock()
RunService.RenderStepped:Connect(function()
    local Target = GetClosest()

    if Target and (os.clock() - Clock) > aC8bug["TriggerbotClickDelay"]["Value"] then
        if aC8bug["Triggerbot"]["Enabled"] and aC8bug["Silent Aim"]["Enabled"] then
            mouse1press()

            task.wait(aC8bug["TriggerbotReleaseDelay"]["Value"])

            mouse1release()
        end

        Clock = os.clock()
    end
end)

local Combat = Library:NewCategory("Combat")

Combat:NewKeybind("Silent Aim > ", aC8bug["Silent Aim"]["Key"], function(Key)
    aC8bug["Silent Aim"]["Key"] = Key
    if Key == nil then
        aC8bug["Silent Aim"]["Enabled"] = not aC8bug["Silent Aim"]["Enabled"]
		print("silent aim", aC8bug["Triggerbot"]["Enabled"])
    end
end)

Combat:NewKeybind("Triggerbot > ", aC8bug["Triggerbot"]["Key"], function(Key)
    aC8bug["Triggerbot"]["Key"] = Key

    if Key == nil then
        aC8bug["Triggerbot"]["Enabled"] = not aC8bug["Triggerbot"]["Enabled"]
		print("trigger", aC8bug["Triggerbot"]["Enabled"])
    end
end)

Combat:NewSlider("Triggerbot Click Delay", aC8bug["TriggerbotClickDelay"]["Value"], 0.025, 0, 1.5, 3, "s", function(value)
    aC8bug["TriggerbotClickDelay"]["Value"] = value
end)

Combat:NewSlider("Triggerbot Release Delay", aC8bug["TriggerbotReleaseDelay"]["Value"], 0.025, 0, 1.5, 3, "s", function(value)
    aC8bug["TriggerbotReleaseDelay"]["Value"] = value
end)

Combat:NewToggle("Visible Check", aC8bug["IsVisibleCheck"]["Enabled"], function(value)
    aC8bug["IsVisibleCheck"]["Enabled"] = value
end)

Combat:NewToggle("Forcefield Check", aC8bug["ForceFieldCheck"]["Enabled"], function(value)
    aC8bug["ForceFieldCheck"]["Enabled"] = value
end)

Combat:NewDropdown("Target Hit Part", {"Head","Root","Random"}, 1, function(value)
    aC8bug["HitPart"]["Value"] = value
end)

local Movement = Library:NewCategory("Movement")

Combat:NewKeybind("Bunny Hop > ", aC8bug["BunnyHop"]["Key"], function(Key)
    aC8bug["BunnyHop"]["Key"] = Key

    if Key == nil then
        aC8bug["BunnyHop"]["Enabled"] = not aC8bug["BunnyHop"]["Enabled"]
		print("BunnyHop ", aC8bug["BunnyHop"]["Enabled"])
    end
end)

Combat:NewKeybind("Spinbot > ", aC8bug["Spinbot"]["Key"], function(Key)
    aC8bug["Spinbot"]["Key"] = Key

    if Key == nil then
        aC8bug["Spinbot"]["Enabled"] = not aC8bug["Spinbot"]["Enabled"]
		print("Spinbot ", aC8bug["Spinbot"]["Enabled"])
    end
end)

Combat:NewKeybind("Flight > ", aC8bug["Flight"]["Key"], function(Key)
    aC8bug["Flight"]["Key"] = Key

    if Key == nil then
        aC8bug["Flight"]["Enabled"] = not aC8bug["Flight"]["Enabled"]
		print("Flight ", aC8bug["Flight"]["Enabled"])
        if aC8bug["Flight"]["Enabled"] == false then
            if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                RootPart.Anchored = false
            end
        end
    end
end)

Combat:NewSlider("Bunny Hop Speed", aC8bug["BunnyHopSpeed"]["Value"], 0.025, 0.025, 1.5, 3, "", function(value)
    aC8bug["BunnyHopSpeed"]["Value"] = value
end)

Combat:NewSlider("Flight Speed", aC8bug["FlightSpeed"]["Value"], 1, 10, 50, 1, "", function(value)
    aC8bug["FlightSpeed"]["Value"] = value
end)

local Visuals = Library:NewCategory("Visuals")

Combat:NewKeybind("Skeleton > ", aC8bug["Skeleton"]["Key"], function(Key)
    aC8bug["Skeleton"]["Key"] = Key

    if Key == nil then
        aC8bug["Skeleton"]["Enabled"] = not aC8bug["Skeleton"]["Enabled"]
		print("Skeleton ", aC8bug["Skeleton"]["Enabled"])
        if aC8bug["Skeleton"]["Enabled"] == true then
            for i,v in next, _G.limbs do
                v.Transparency = 1
            end
        else
            for i,v in next, _G.limbs do
                v.Transparency = 0
            end
        end
    end
end)

Combat:NewKeybind("ESP > ", aC8bug["ESP"]["Key"], function(Key)
    aC8bug["ESP"]["Key"] = Key

    if Key == nil then
        aC8bug["ESP"]["Enabled"] = not aC8bug["ESP"]["Enabled"]
		print("ESP ", aC8bug["ESP"]["Enabled"])
        if aC8bug["ESP"]["Enabled"] == true then
            _G.mastervis = true
            Visibility()
        else
            _G.mastervis = false
            Visibility()
        end
    end
end)

local Misc = Library:NewCategory("Misc")

Misc:NewKeybind("Packet Freezer > ", aC8bug["Packet"]["Key"], function(Key)
    aC8bug["Packet"]["Key"] = Key

    if Key == nil then
        aC8bug["Packet"]["Enabled"] = not aC8bug["Packet"]["Enabled"]
		print("Packet ", aC8bug["Packet"]["Enabled"])
        if aC8bug["Packet"]["Enabled"] == true then
            game:GetService("NetworkClient"):SetOutgoingKBPSLimit(1)
        else
            game:GetService("NetworkClient"):SetOutgoingKBPSLimit(9e9)
        end
    end
end)
