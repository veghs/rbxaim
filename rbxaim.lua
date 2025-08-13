-- Simple Universal Roblox Script GUI with ESP + Aimhack + Teleport (CTRL+Click) with Hungarian QWERTZ fix
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local FullbrightEnabled = false
local OriginalSky = nil
local OriginalLighting = game:GetService("Lighting")

-- Cleanup
pcall(function() CoreGui:FindFirstChild("SimpleGUI"):Destroy() end)
pcall(function() CoreGui:FindFirstChild("SimpleESP"):Destroy() end)

-- GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "SimpleGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 580)
Frame.Position = UDim2.new(0.5, -125, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "Vegh's Universal"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local ESPToggle = Instance.new("TextButton", Frame)
ESPToggle.Position = UDim2.new(0, 10, 0, 40)
ESPToggle.Size = UDim2.new(1, -20, 0, 30)
ESPToggle.Text = "Toggle ESP"
ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.SourceSans
ESPToggle.TextSize = 18

local FullbrightToggle = Instance.new("TextButton", Frame)
FullbrightToggle.Position = UDim2.new(0, 10, 0, 240)
FullbrightToggle.Size = UDim2.new(1, -20, 0, 30)
FullbrightToggle.Text = "Fullbright: OFF"
FullbrightToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FullbrightToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FullbrightToggle.Font = Enum.Font.SourceSans
FullbrightToggle.TextSize = 18


local ColorPicker = Instance.new("TextBox", Frame)
ColorPicker.PlaceholderText = "RGB (255,255,255)"
ColorPicker.Position = UDim2.new(0, 10, 0, 80)
ColorPicker.Size = UDim2.new(1, -20, 0, 30)
ColorPicker.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ColorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorPicker.Font = Enum.Font.SourceSans
ColorPicker.TextSize = 16

local HotkeyBox = Instance.new("TextBox", Frame)
HotkeyBox.PlaceholderText = "Hotkey to Hide GUI"
HotkeyBox.Position = UDim2.new(0, 10, 0, 120)
HotkeyBox.Size = UDim2.new(1, -20, 0, 30)
HotkeyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HotkeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
HotkeyBox.Font = Enum.Font.SourceSans
HotkeyBox.TextSize = 16

local AimHotkeyBox = Instance.new("TextBox", Frame)
AimHotkeyBox.PlaceholderText = "Hotkey to Toggle Aimhack"
AimHotkeyBox.Position = UDim2.new(0, 10, 0, 160)
AimHotkeyBox.Size = UDim2.new(1, -20, 0, 30)
AimHotkeyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimHotkeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AimHotkeyBox.Font = Enum.Font.SourceSans
AimHotkeyBox.TextSize = 16

local TeleportToggle = Instance.new("TextButton", Frame)
TeleportToggle.Position = UDim2.new(0, 10, 0, 200)
TeleportToggle.Size = UDim2.new(1, -20, 0, 30)
TeleportToggle.Text = "Teleport CTRL+Click: OFF"
TeleportToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TeleportToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportToggle.Font = Enum.Font.SourceSans
TeleportToggle.TextSize = 18

local CloseButton = Instance.new("TextButton", Frame)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20

-- Variables
local ESPEnabled = false
local ESPColor = Color3.new(1,1,1)
local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "SimpleESP"

local AimbotEnabled = false
local RightMouseDown = false
local CurrentTarget = nil

local TeleportEnabled = false

-- Hungarian QWERTZ layout map for keys to logical keys
local qwertzMap = {
    ["Z"] = "Y",
    ["Y"] = "Z",
}

local function physicalToLogicalKey(keyName)
    return qwertzMap[keyName] or keyName
end

-- Functions
local function CreateESP(plr)
	if plr ~= LocalPlayer then
		if ESPFolder:FindFirstChild(plr.Name) then
			ESPFolder[plr.Name]:Destroy()
		end
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local highlight = Instance.new("Highlight", ESPFolder)
			highlight.Name = plr.Name
			highlight.Adornee = plr.Character
			highlight.FillColor = ESPColor
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
		end
	end
end

local function ToggleESP()
	ESPEnabled = not ESPEnabled
	if ESPEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				CreateESP(plr)
			end
		end
	else
		ESPFolder:ClearAllChildren()
	end
end

local function ToggleFullbright()
	FullbrightEnabled = not FullbrightEnabled
	if FullbrightEnabled then
		FullbrightToggle.Text = "Fullbright: ON"
		OriginalSky = OriginalLighting:FindFirstChildOfClass("Sky")
		if OriginalSky then
			OriginalSky.Parent = nil
		end

		OriginalLighting.Ambient = Color3.new(1, 1, 1)
		OriginalLighting.ColorShift_Top = Color3.new(1, 1, 1)
		OriginalLighting.ColorShift_Bottom = Color3.new(1, 1, 1)
		OriginalLighting.OutdoorAmbient = Color3.new(1, 1, 1)
		OriginalLighting.Brightness = 3
		OriginalLighting.ClockTime = 14
		OriginalLighting.FogEnd = 100000
		OriginalLighting.GlobalShadows = false
	else
		FullbrightToggle.Text = "Fullbright: OFF"
		if OriginalSky then
			OriginalSky.Parent = OriginalLighting
		end

		OriginalLighting.Ambient = Color3.new(0.5, 0.5, 0.5)
		OriginalLighting.ColorShift_Top = Color3.new(0, 0, 0)
		OriginalLighting.ColorShift_Bottom = Color3.new(0, 0, 0)
		OriginalLighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
		OriginalLighting.Brightness = 1
		OriginalLighting.ClockTime = 14
		OriginalLighting.FogEnd = 1000
		OriginalLighting.GlobalShadows = true
	end
end

local function IsPlayerAlive(plr)
	if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
		return plr.Character.Humanoid.Health > 0
	end
	return false
end

local function GetClosestPlayer()
	local closest
	local closestMag = math.huge
	local mousePos = UserInputService:GetMouseLocation()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and IsPlayerAlive(plr) and plr.Character and plr.Character:FindFirstChild("Head") then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
				if mag < closestMag and mag < 120 then
					closest = plr
					closestMag = mag
				end
			end
		end
	end
	return closest
end

local function matchesHotkey(input, hotkeyText)
	local key = physicalToLogicalKey(input.KeyCode.Name)
	return key:lower() == (hotkeyText or ""):lower()
end

-- Events
ESPToggle.MouseButton1Click:Connect(function()
	local rgb = string.split(ColorPicker.Text, ",")
	if #rgb == 3 then
		local r = tonumber(rgb[1]) or 255
		local g = tonumber(rgb[2]) or 255
		local b = tonumber(rgb[3]) or 255
		ESPColor = Color3.fromRGB(r, g, b)
	end
	ToggleESP()
end)

FullbrightToggle.MouseButton1Click:Connect(function()
	ToggleFullbright()
end)

TeleportToggle.MouseButton1Click:Connect(function()
	TeleportEnabled = not TeleportEnabled
	TeleportToggle.Text = "Teleport CTRL+Click: " .. (TeleportEnabled and "ON" or "OFF")
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		if ESPEnabled then
			task.wait(0.1)
			CreateESP(plr)
		end
	end)
end)

for _, plr in pairs(Players:GetPlayers()) do
	plr.CharacterAdded:Connect(function()
		if ESPEnabled then
			task.wait(0.1)
			CreateESP(plr)
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightMouseDown = true
	end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if matchesHotkey(input, HotkeyBox.Text) then
			Frame.Visible = not Frame.Visible
		end
		if matchesHotkey(input, AimHotkeyBox.Text) then
			AimbotEnabled = not AimbotEnabled
			if not AimbotEnabled then
				CurrentTarget = nil
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightMouseDown = false
		CurrentTarget = nil
	end
end)

Mouse.Button1Down:Connect(function()
	if TeleportEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local targetPos = Mouse.Hit.p
		if targetPos then
			local character = LocalPlayer.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
			end
		end
	end
end)

local RenderConn, InputBeganConn, InputEndedConn

RenderConn = RunService.RenderStepped:Connect(function()
	if AimbotEnabled and RightMouseDown then
		if currentTarget and (not ESPFolder:FindFirstChild(currentTarget.Name) or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Head") or currentTarget.Character.Humanoid.Health <= 0) then
			currentTarget = nil
		end
		
		if not currentTarget then
			local target = GetClosestPlayer()
			if target and ESPFolder:FindFirstChild(target.Name) then
				currentTarget = target
			end
		end
		
		if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character.Head.Position)
		end
	else
		currentTarget = nil
	end
end)

InputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightMouseDown = true
	end
end)

InputEndedConn = UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightMouseDown = false
		CurrentTarget = nil
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	AimbotEnabled = false
	ESPEnabled = false
	TeleportEnabled = false
	RightMouseDown = false
	CurrentTarget = nil
	ESPFolder:Destroy()
	ScreenGui:Destroy()
	if RenderConn then RenderConn:Disconnect() end
	if InputBeganConn then InputBeganConn:Disconnect() end
	if InputEndedConn then InputEndedConn:Disconnect() end
end)

-- Speedwalk Label
local SpeedLabel = Instance.new("TextLabel", Frame)
SpeedLabel.Text = "WalkSpeed"
SpeedLabel.Position = UDim2.new(0, 10, 0, 280)
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextSize = 16
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Speedwalk Box
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.PlaceholderText = "Default: 16"
SpeedBox.Position = UDim2.new(0, 10, 0, 305)
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 16
SpeedBox.Text = ""
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)

-- Speedwalk Hotkey Box
local SpeedHotkeyBox = Instance.new("TextBox", Frame)
SpeedHotkeyBox.PlaceholderText = "Hotkey to Set Speed"
SpeedHotkeyBox.Position = UDim2.new(0, 10, 0, 345)
SpeedHotkeyBox.Size = UDim2.new(1, -20, 0, 30)
SpeedHotkeyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedHotkeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedHotkeyBox.Font = Enum.Font.SourceSans
SpeedHotkeyBox.TextSize = 16
Instance.new("UICorner", SpeedHotkeyBox).CornerRadius = UDim.new(0, 6)

-- Speedwalk Button
local SpeedButton = Instance.new("TextButton", Frame)
SpeedButton.Position = UDim2.new(0, 10, 0, 385)
SpeedButton.Size = UDim2.new(1, -20, 0, 30)
SpeedButton.Text = "Set Speed"
SpeedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.SourceSans
SpeedButton.TextSize = 18
Instance.new("UICorner", SpeedButton).CornerRadius = UDim.new(0, 6)

-- Function to apply speed
local function ApplySpeed()
    local speed = tonumber(SpeedBox.Text)
    if speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

-- Button click sets speed
SpeedButton.MouseButton1Click:Connect(function()
    ApplySpeed()
end)

-- Hotkey to set speed
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if matchesHotkey(input, SpeedHotkeyBox.Text) then
            ApplySpeed()
        end
    end
end)

-- Scale Label
local ScaleLabel = Instance.new("TextLabel", Frame)
ScaleLabel.Text = "Player Scale"
ScaleLabel.Position = UDim2.new(0, 10, 0, 425)
ScaleLabel.Size = UDim2.new(1, -20, 0, 20)
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleLabel.Font = Enum.Font.SourceSansBold
ScaleLabel.TextSize = 16
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Scale Box
local ScaleBox = Instance.new("TextBox", Frame)
ScaleBox.PlaceholderText = "Default: 1 (e.g., 0.5)"
ScaleBox.Position = UDim2.new(0, 10, 0, 450)
ScaleBox.Size = UDim2.new(1, -20, 0, 30)
ScaleBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ScaleBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleBox.Font = Enum.Font.SourceSans
ScaleBox.TextSize = 16
Instance.new("UICorner", ScaleBox).CornerRadius = UDim.new(0, 6)

-- Scale Button
local ScaleButton = Instance.new("TextButton", Frame)
ScaleButton.Position = UDim2.new(0, 10, 0, 490)
ScaleButton.Size = UDim2.new(1, -20, 0, 30)
ScaleButton.Text = "Set Scale"
ScaleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ScaleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleButton.Font = Enum.Font.SourceSans
ScaleButton.TextSize = 18
Instance.new("UICorner", ScaleButton).CornerRadius = UDim.new(0, 6)

-- Function to apply scale
local function ApplyScale()
    local scale = tonumber(ScaleBox.Text)
    if scale and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        for _, scaleObj in ipairs(LocalPlayer.Character.Humanoid:GetChildren()) do
            if scaleObj:IsA("NumberValue") and scaleObj.Name:match("Scale") then
                scaleObj.Value = scale
            end
        end
    end
end

ScaleButton.MouseButton1Click:Connect(function()
    ApplyScale()
end)

-- Never Ragdoll Toggle
local RagdollToggle = Instance.new("TextButton", Frame)
RagdollToggle.Position = UDim2.new(0, 10, 0, 530)
RagdollToggle.Size = UDim2.new(1, -20, 0, 30)
RagdollToggle.Text = "Never Ragdoll: OFF"
RagdollToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RagdollToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RagdollToggle.Font = Enum.Font.SourceSans
RagdollToggle.TextSize = 18
Instance.new("UICorner", RagdollToggle).CornerRadius = UDim.new(0, 6)

local NeverRagdoll = false

local function ForceStand(char)
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        if humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        humanoid.Sit = false
    end
end

local function SetupForceStand()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        -- Check every frame
        RunService.Stepped:Connect(function()
            if NeverRagdoll then
                ForceStand(char)
            end
        end)
    end
end

RagdollToggle.MouseButton1Click:Connect(function()
    NeverRagdoll = not NeverRagdoll
    RagdollToggle.Text = "Never Ragdoll: " .. (NeverRagdoll and "ON" or "OFF")
    if NeverRagdoll then
        SetupForceStand()
    end
end)

-- Re-apply when you respawn
LocalPlayer.CharacterAdded:Connect(function()
    if NeverRagdoll then
        task.wait(0.5)
        SetupForceStand()
    end
end)
