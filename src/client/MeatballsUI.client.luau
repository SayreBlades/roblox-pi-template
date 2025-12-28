-- MeatballsUI: Displays the player's Meatballs count and upgrade buttons
-- Updates automatically when leaderstats change

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Wait for remote events/functions
local purchaseEvent = ReplicatedStorage:WaitForChild("PurchaseUpgrade")
local upgradeInfoFunction = ReplicatedStorage:WaitForChild("GetUpgradeInfo")

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MeatballsUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ============================================
-- MEATBALLS COUNTER (top center)
-- ============================================

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 280, 0, 70)
container.Position = UDim2.new(0.5, -140, 0, 20)
container.BackgroundColor3 = Color3.fromRGB(200, 30, 30)  -- Marinara red
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = container

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(139, 20, 20)
stroke.Thickness = 3
stroke.Parent = container

local emoji = Instance.new("TextLabel")
emoji.Name = "Emoji"
emoji.Size = UDim2.new(0, 50, 1, -10)
emoji.Position = UDim2.new(0, 10, 0, 5)
emoji.BackgroundTransparency = 1
emoji.Text = "🍝"
emoji.TextScaled = true
emoji.Parent = container

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

-- ============================================
-- UPGRADE BUTTON (bottom right)
-- ============================================

local upgradeFrame = Instance.new("Frame")
upgradeFrame.Name = "UpgradeFrame"
upgradeFrame.Size = UDim2.new(0, 200, 0, 120)
upgradeFrame.Position = UDim2.new(1, -220, 1, -140)
upgradeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
upgradeFrame.BorderSizePixel = 0
upgradeFrame.Parent = screenGui

local upgradeCorner = Instance.new("UICorner")
upgradeCorner.CornerRadius = UDim.new(0, 12)
upgradeCorner.Parent = upgradeFrame

local upgradeStroke = Instance.new("UIStroke")
upgradeStroke.Color = Color3.fromRGB(30, 30, 30)
upgradeStroke.Thickness = 2
upgradeStroke.Parent = upgradeFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🥄 UPGRADES"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Parent = upgradeFrame

-- Buy Spoon Button
local spoonButton = Instance.new("TextButton")
spoonButton.Name = "SpoonButton"
spoonButton.Size = UDim2.new(1, -20, 0, 50)
spoonButton.Position = UDim2.new(0, 10, 0, 40)
spoonButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)  -- Green
spoonButton.BorderSizePixel = 0
spoonButton.Text = "Buy Spoon\n💰 10"
spoonButton.TextColor3 = Color3.new(1, 1, 1)
spoonButton.TextScaled = true
spoonButton.Font = Enum.Font.FredokaOne
spoonButton.Parent = upgradeFrame

local spoonCorner = Instance.new("UICorner")
spoonCorner.CornerRadius = UDim.new(0, 8)
spoonCorner.Parent = spoonButton

-- Power display
local powerLabel = Instance.new("TextLabel")
powerLabel.Name = "PowerLabel"
powerLabel.Size = UDim2.new(1, 0, 0, 20)
powerLabel.Position = UDim2.new(0, 0, 0, 95)
powerLabel.BackgroundTransparency = 1
powerLabel.Text = "Click Power: 1"
powerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
powerLabel.TextScaled = true
powerLabel.Font = Enum.Font.FredokaOne
powerLabel.Parent = upgradeFrame

-- ============================================
-- LOGIC
-- ============================================

local originalContainerSize = container.Size
local currentMeatballs = 0

-- Pop animation for counter
local function popCounter()
	local growInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local shrinkInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	
	local growTween = TweenService:Create(container, growInfo, {
		Size = UDim2.new(0, 300, 0, 80)
	})
	local shrinkTween = TweenService:Create(container, shrinkInfo, {
		Size = originalContainerSize
	})
	
	growTween:Play()
	growTween.Completed:Connect(function()
		shrinkTween:Play()
	end)
end

-- Update the meatball display
local function updateDisplay(value: number)
	currentMeatballs = value
	counter.Text = tostring(value) .. " Meatballs"
	popCounter()
	updateUpgradeButton()
end

-- Update upgrade button state
function updateUpgradeButton()
	local success, info = pcall(function()
		return upgradeInfoFunction:InvokeServer("Spoon")
	end)
	
	if success and info then
		spoonButton.Text = "Buy Spoon\n💰 " .. tostring(info.cost)
		powerLabel.Text = "Click Power: " .. tostring(info.currentPower)
		
		-- Enable/disable based on affordability
		if currentMeatballs >= info.cost then
			spoonButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)  -- Green
			spoonButton.Active = true
		else
			spoonButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)  -- Gray
			spoonButton.Active = false
		end
	end
end

-- Handle spoon button click
spoonButton.MouseButton1Click:Connect(function()
	purchaseEvent:FireServer("Spoon")
	-- Button will update when meatballs change
end)

-- Setup leaderstats listener
local function setupLeaderstatsListener()
	local leaderstats = player:WaitForChild("leaderstats")
	local meatballs = leaderstats:WaitForChild("Meatballs")
	
	-- Set initial value (no pop)
	currentMeatballs = meatballs.Value
	counter.Text = tostring(meatballs.Value) .. " Meatballs"
	updateUpgradeButton()
	
	-- Listen for changes
	meatballs.Changed:Connect(function(newValue)
		updateDisplay(newValue)
	end)
end

-- Listen for attribute changes (for power updates after purchase)
player.AttributeChanged:Connect(function(attributeName)
	if attributeName == "SauceMultiplier" or attributeName == "SpoonsOwned" then
		updateUpgradeButton()
	end
end)

-- Start
setupLeaderstatsListener()

print("[MeatballsUI] Initialized with upgrade button")
