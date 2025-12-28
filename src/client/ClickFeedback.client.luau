-- ClickFeedback: Visual and audio feedback when clicking the pot
-- Shows floating "+X" text and tweens the pot

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the ClickFeedback RemoteEvent from server
local clickFeedbackEvent = ReplicatedStorage:WaitForChild("ClickFeedback")

-- Create a ScreenGui for floating text
local feedbackGui = Instance.new("ScreenGui")
feedbackGui.Name = "ClickFeedbackUI"
feedbackGui.ResetOnSpawn = false
feedbackGui.Parent = playerGui

-- Pool of reusable text labels for performance
local textPool = {}
local POOL_SIZE = 10

-- Create text labels for the pool
for i = 1, POOL_SIZE do
	local label = Instance.new("TextLabel")
	label.Name = "FloatingText" .. i
	label.Size = UDim2.new(0, 100, 0, 50)
	label.BackgroundTransparency = 1
	label.Text = "+1"
	label.TextColor3 = Color3.fromRGB(255, 215, 0)  -- Gold color
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(139, 69, 19)  -- Brown stroke
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Visible = false
	label.Parent = feedbackGui
	
	table.insert(textPool, {label = label, inUse = false})
end

-- Get an available label from the pool
local function getLabel()
	for _, item in textPool do
		if not item.inUse then
			item.inUse = true
			return item
		end
	end
	-- All in use, return first one (will recycle)
	return textPool[1]
end

-- Show floating text at a position
local function showFloatingText(amount: number, worldPosition: Vector3)
	local camera = Workspace.CurrentCamera
	if not camera then return end
	
	-- Convert world position to screen position
	local screenPos, onScreen = camera:WorldToScreenPoint(worldPosition)
	if not onScreen then return end
	
	local item = getLabel()
	local label = item.label
	
	-- Reset and position
	label.Text = "+" .. tostring(amount)
	label.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 25)
	label.TextTransparency = 0
	label.TextStrokeTransparency = 0
	label.Visible = true
	
	-- Animate: float up and fade out
	local floatInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local floatTween = TweenService:Create(label, floatInfo, {
		Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y - 100),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	
	floatTween:Play()
	floatTween.Completed:Connect(function()
		label.Visible = false
		item.inUse = false
	end)
end

-- Tween the pot (scale up and back)
local function tweenPot()
	-- Find the player's pot
	local potModel = Workspace:FindFirstChild(player.Name .. "_Pot")
	if not potModel then return end
	
	local pot = potModel:FindFirstChild("Pot")
	if not pot then return end
	
	local originalSize = pot.Size
	local bigSize = originalSize * 1.1
	
	local growInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local shrinkInfo = TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	
	local growTween = TweenService:Create(pot, growInfo, {Size = bigSize})
	local shrinkTween = TweenService:Create(pot, shrinkInfo, {Size = originalSize})
	
	growTween:Play()
	growTween.Completed:Connect(function()
		shrinkTween:Play()
	end)
end

-- Placeholder for sound (to be added later)
local function playClickSound()
	-- TODO: Add sound when asset is ready
	-- print("[ClickFeedback] *squish sound*")
end

-- Handle click feedback from server
local function onClickFeedback(data)
	local amount = data.amount or 1
	local potPosition = data.potPosition or Vector3.new(0, 5, 0)
	
	-- Show floating text above pot
	showFloatingText(amount, potPosition + Vector3.new(0, 3, 0))
	
	-- Tween the pot
	tweenPot()
	
	-- Play sound
	playClickSound()
end

-- Connect to server event
clickFeedbackEvent.OnClientEvent:Connect(onClickFeedback)

print("[ClickFeedback] Initialized")
