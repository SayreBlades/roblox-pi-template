-- PotManager: Creates a pot for each player and handles clicking
-- Each player has their own pot positioned near spawn

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- Create RemoteEvent for click feedback (client will listen)
local clickFeedbackEvent = Instance.new("RemoteEvent")
clickFeedbackEvent.Name = "ClickFeedback"
clickFeedbackEvent.Parent = ReplicatedStorage

-- Store each player's pot
local playerPots = {}

-- Create the sauce pot for a player
local function createPot(player: Player)
	-- Create pot container (Model)
	local potModel = Instance.new("Model")
	potModel.Name = player.Name .. "_Pot"
	
	-- Create the main pot (cylinder)
	local pot = Instance.new("Part")
	pot.Name = "Pot"
	pot.Shape = Enum.PartType.Cylinder
	pot.Size = GameConfig.POT_SIZE
	pot.Color = GameConfig.POT_COLOR
	pot.Material = GameConfig.POT_MATERIAL
	pot.Anchored = true
	pot.CanCollide = true
	
	-- Rotate cylinder to be upright (cylinders default to horizontal)
	pot.CFrame = CFrame.new(GameConfig.POT_OFFSET) * CFrame.Angles(0, 0, math.rad(90))
	pot.Parent = potModel
	
	-- Add ClickDetector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 20
	clickDetector.Parent = pot
	
	-- Handle clicks
	clickDetector.MouseClick:Connect(function(clickingPlayer)
		-- Only the pot owner can click their pot
		if clickingPlayer ~= player then
			return
		end
		
		-- Get click power from player's multiplier
		local multiplier = player:GetAttribute("SauceMultiplier") or 1
		local meatballsEarned = multiplier
		
		-- Award meatballs
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local meatballs = leaderstats:FindFirstChild("Meatballs")
			if meatballs then
				meatballs.Value += meatballsEarned
			end
		end
		
		-- Fire feedback event to client
		clickFeedbackEvent:FireClient(player, {
			amount = meatballsEarned,
			potPosition = pot.Position,
		})
	end)
	
	-- Add floating text above pot
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "PotLabel"
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 4, 0)
	billboardGui.Adornee = pot
	billboardGui.Parent = pot
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "🍝 STIR THE SAUCE!"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Parent = billboardGui
	
	potModel.Parent = Workspace
	playerPots[player] = potModel
	
	print("[PotManager] Created pot for", player.Name)
	
	return potModel
end

-- Remove pot when player leaves
local function removePot(player: Player)
	local pot = playerPots[player]
	if pot then
		pot:Destroy()
		playerPots[player] = nil
		print("[PotManager] Removed pot for", player.Name)
	end
end

-- Handle player joining
local function onPlayerAdded(player: Player)
	-- Wait for leaderstats to be created by PlayerDataManager
	player:WaitForChild("leaderstats")
	
	-- Create their pot
	createPot(player)
end

-- Handle player leaving
local function onPlayerRemoving(player: Player)
	removePot(player)
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in game (for studio testing)
for _, player in Players:GetPlayers() do
	if player:FindFirstChild("leaderstats") then
		createPot(player)
	else
		task.spawn(function()
			player:WaitForChild("leaderstats")
			createPot(player)
		end)
	end
end

print("[PotManager] Initialized")
