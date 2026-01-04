-- MeatballsUI: Displays the player's Meatballs count
-- Updates automatically when leaderstats change

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MeatballsUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main container frame
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 280, 0, 70)
container.Position = UDim2.new(0.5, -140, 0, 20)
container.BackgroundColor3 = Color3.fromRGB(200, 30, 30)  -- Marinara red
container.BorderSizePixel = 0
container.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = container

-- Stroke/border for depth
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(139, 20, 20)
stroke.Thickness = 3
stroke.Parent = container

-- Meatball emoji
local emoji = Instance.new("TextLabel")
emoji.Name = "Emoji"
emoji.Size = UDim2.new(0, 50, 1, -10)
emoji.Position = UDim2.new(0, 10, 0, 5)
emoji.BackgroundTransparency = 1
emoji.Text = "🍝"
emoji.TextScaled = true
emoji.Parent = container

-- Meatballs counter
local counter = Instance.new("TextLabel")
counter.Name = "Counter"
counter.Size = UDim2.new(1, -70, 1, 0)
counter.Position = UDim2.new(0, 60, 0, 0)
counter.BackgroundTransparency = 1
counter.Text = "0 Meatballs"
counter.TextColor3 = Color3.new(1, 1, 1)
counter.TextStrokeTransparency = 0.5
counter.TextStrokeColor3 = Color3.new(0, 0, 0)
counter.TextScaled = true
counter.Font = Enum.Font.FredokaOne
counter.TextXAlignment = Enum.TextXAlignment.Left
counter.Parent = container

-- Store original size for tween
local originalSize = container.Size

-- Tween for "pop" effect when value changes
local function popCounter()
	local growInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local shrinkInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	
	local growTween = TweenService:Create(container, growInfo, {
		Size = UDim2.new(0, 300, 0, 80)
	})
	
	local shrinkTween = TweenService:Create(container, shrinkInfo, {
		Size = originalSize
	})
	
	growTween:Play()
	growTween.Completed:Connect(function()
		shrinkTween:Play()
	end)
end

-- Update the display
local function updateDisplay(value: number)
	counter.Text = tostring(value) .. " Meatballs"
	popCounter()
end

-- Wait for leaderstats and connect to changes
local function setupLeaderstatsListener()
	local leaderstats = player:WaitForChild("leaderstats")
	local meatballs = leaderstats:WaitForChild("Meatballs")
	
	-- Set initial value (no pop)
	counter.Text = tostring(meatballs.Value) .. " Meatballs"
	
	-- Listen for changes
	meatballs.Changed:Connect(function(newValue)
		updateDisplay(newValue)
	end)
end

-- Start listening
setupLeaderstatsListener()

print("[MeatballsUI] Initialized")
