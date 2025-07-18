-- Simplified full script (no NameESP)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI setup
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "AimlockESP_GUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Nyxo's AimHub | ESP | FullBright"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

local closeButton = Instance.new("TextButton", frame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20

local guiToggleKey = Enum.KeyCode.G
local toggleGuiBtn = Instance.new("TextButton", frame)
toggleGuiBtn.Size = UDim2.new(1, -20, 0, 30)
toggleGuiBtn.Position = UDim2.new(0, 10, 0, 40)
toggleGuiBtn.Text = "Set GUI Toggle Hotkey: G"
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleGuiBtn.TextColor3 = Color3.new(1,1,1)
toggleGuiBtn.Font = Enum.Font.SourceSans
toggleGuiBtn.TextSize = 18

local statusBox = Instance.new("Frame", frame)
statusBox.Size = UDim2.new(0, 30, 0, 30)
statusBox.Position = UDim2.new(0, 10, 0, 80)
statusBox.BackgroundColor3 = Color3.fromRGB(255,0,0)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(0, 180, 0, 30)
label.Position = UDim2.new(0, 50, 0, 80)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.SourceSans
label.TextSize = 18
label.Text = "Aimlock: Off"

local hotkeyButton = Instance.new("TextButton", frame)
hotkeyButton.Size = UDim2.new(1, -20, 0, 30)
hotkeyButton.Position = UDim2.new(0, 10, 0, 120)
hotkeyButton.Text = "Set Aimlock Hotkey: F"
hotkeyButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
hotkeyButton.TextColor3 = Color3.new(1,1,1)
hotkeyButton.Font = Enum.Font.SourceSans
hotkeyButton.TextSize = 18

local espToggleButton = Instance.new("TextButton", frame)
espToggleButton.Size = UDim2.new(1, -20, 0, 30)
espToggleButton.Position = UDim2.new(0, 10, 0, 160)
espToggleButton.Text = "ESP: Off"
espToggleButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
espToggleButton.TextColor3 = Color3.new(1,1,1)
espToggleButton.Font = Enum.Font.SourceSans
espToggleButton.TextSize = 18

local fullbrightButton = Instance.new("TextButton", frame)
fullbrightButton.Size = UDim2.new(1, -20, 0, 30)
fullbrightButton.Position = UDim2.new(0, 10, 0, 200)
fullbrightButton.Text = "Fullbright: Off"
fullbrightButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
fullbrightButton.TextColor3 = Color3.new(1,1,1)
fullbrightButton.Font = Enum.Font.SourceSans
fullbrightButton.TextSize = 18

-- State
local aimlockOn = false
local holdingRightClick = false
local lockedPlayer = nil
local toggleKey = Enum.KeyCode.F
local waitingForHotkey = false
local espOn = false
local waitingForGuiHotkey = false
local guiToggleKey = Enum.KeyCode.G
local adornments = {}
local fullbrightOn = false
local Lighting = game:GetService("Lighting")

local function setToggleKey(newKey)
	toggleKey = newKey
	hotkeyButton.Text = "Set Aimlock Hotkey: " .. tostring(newKey):gsub("Enum.KeyCode.", "")
end

local function setGuiToggleKey(newKey)
	guiToggleKey = newKey
	toggleGuiBtn.Text = "Set GUI Toggle Hotkey: " .. tostring(newKey):gsub("Enum.KeyCode.", "")
end

local function highlightCharacter(char)
	for _, part in pairs(char:GetChildren()) do
		if part:IsA("BasePart") and not adornments[part] then
			local adorn = Instance.new("BoxHandleAdornment")
			adorn.Adornee = part
			adorn.AlwaysOnTop = true
			adorn.ZIndex = 10
			adorn.Size = part.Size
			adorn.Transparency = 0.5
			adorn.Color3 = Color3.new(0, 1, 0)
			adorn.Parent = part
			adornments[part] = adorn
		end
	end
end

local function updateEsp()
	if not espOn then
		for _, adorn in pairs(adornments) do adorn:Destroy() end
		adornments = {}
		return
	end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			highlightCharacter(player.Character)
		end
	end
end

local function setFullbright(state)
	fullbrightOn = state
	if fullbrightOn then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.new(1,1,1)
		fullbrightButton.Text = "Fullbright: On"
		fullbrightButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		Lighting.Brightness = 1
		Lighting.ClockTime = 12
		Lighting.FogEnd = 1000
		Lighting.GlobalShadows = true
		Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
		fullbrightButton.Text = "Fullbright: Off"
		fullbrightButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
end

-- Handle respawns
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(0.2)
		if espOn then updateEsp() end
	end)
end)

for _, player in pairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function()
		wait(0.2)
		if espOn then updateEsp() end
	end)
end

-- Input
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == toggleKey then
		aimlockOn = not aimlockOn
		statusBox.BackgroundColor3 = aimlockOn and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
		label.Text = "Aimlock: " .. (aimlockOn and "On" or "Off")
		if not aimlockOn then lockedPlayer = nil end
	elseif input.KeyCode == guiToggleKey then
		screenGui.Enabled = not screenGui.Enabled
	elseif waitingForHotkey and input.UserInputType == Enum.UserInputType.Keyboard then
		setToggleKey(input.KeyCode)
		waitingForHotkey = false
	elseif waitingForGuiHotkey and input.UserInputType == Enum.UserInputType.Keyboard then
		setGuiToggleKey(input.KeyCode)
		waitingForGuiHotkey = false
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 and aimlockOn then
		holdingRightClick = true
		local minAngle = math.rad(5)
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local dir = (player.Character.Head.Position - Camera.CFrame.Position).Unit
				local angle = math.acos(Camera.CFrame.LookVector:Dot(dir))
				if angle < minAngle then
					minAngle = angle
					lockedPlayer = player
				end
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		holdingRightClick = false
		lockedPlayer = nil
	end
end)

hotkeyButton.MouseButton1Click:Connect(function()
	waitingForHotkey = true
	hotkeyButton.Text = "Press a key..."
end)

toggleGuiBtn.MouseButton1Click:Connect(function()
	waitingForGuiHotkey = true
	toggleGuiBtn.Text = "Press a key..."
end)

espToggleButton.MouseButton1Click:Connect(function()
	espOn = not espOn
	espToggleButton.Text = "ESP: " .. (espOn and "On" or "Off")
	espToggleButton.BackgroundColor3 = espOn and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	if not espOn then
		for _, adorn in pairs(adornments) do adorn:Destroy() end
		adornments = {}
	end
end)

fullbrightButton.MouseButton1Click:Connect(function()
	setFullbright(not fullbrightOn)
end)

closeButton.MouseButton1Click:Connect(function()
	RunService:UnbindFromRenderStep("AimlockRender")
	for _, adorn in pairs(adornments) do adorn:Destroy() end
	screenGui:Destroy()
end)

RunService:BindToRenderStep("AimlockRender", Enum.RenderPriority.Camera.Value + 1, function()
	if aimlockOn and holdingRightClick and lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild("Head") then
		local head = lockedPlayer.Character.Head
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
	end
	if espOn then updateEsp() end
end)

setFullbright(false)
screenGui.Enabled = true
