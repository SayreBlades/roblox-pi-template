-- PotManager: Creates a pot for each player and handles clicking
-- Each player has their own pot positioned near spawn

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local AssetIds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AssetIds"))

-- Cache the cauldron template (load once, clone for each player)
local cauldronTemplate = nil

local function loadCauldronTemplate()
	if cauldronTemplate then return cauldronTemplate end
	
	local success, result = pcall(function()
		return InsertService:LoadAsset(AssetIds.Cauldron)
	end)
	
	if success and result then
		local model = result:GetChildren()[1]
		if model then
			-- Remove any scripts from the template
			for _, desc in ipairs(model:GetDescendants()) do
				if desc:IsA("Script") or desc:IsA("LocalScript") then
					desc:Destroy()
				end
			end
			model.Parent = nil  -- Keep in memory, not in workspace
			cauldronTemplate = model
			print("[PotManager] Loaded cauldron template")
			return cauldronTemplate
		end
	end
	
	warn("[PotManager] Failed to load cauldron, using fallback cylinder")
	return nil
end

-- Create RemoteEvent for click feedback (client will listen)
local clickFeedbackEvent = Instance.new("RemoteEvent")
clickFeedbackEvent.Name = "ClickFeedback"
clickFeedbackEvent.Parent = ReplicatedStorage

-- Store each player's pot
local playerPots = {}

-- Create the sauce pot for a player
local function createPot(player: Player)
	-- Try to use cauldron, fallback to cylinder
	local template = loadCauldronTemplate()
	
	local potModel
	local pot  -- The main part to attach ClickDetector to
	
	if template then
		-- Clone the cauldron model
		potModel = template:Clone()
		potModel.Name = player.Name .. "_Pot"
		
		-- Find the primary part or first part for click detection
		pot = potModel.PrimaryPart or potModel:FindFirstChildWhichIsA("BasePart")
		
		-- Make all parts anchored
		for _, part in ipairs(potModel:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
		
		-- Position the cauldron
		potModel:PivotTo(CFrame.new(GameConfig.POT_OFFSET))
	else
		-- Fallback: create cylinder pot
		potModel = Instance.new("Model")
		potModel.Name = player.Name .. "_Pot"
		
		pot = Instance.new("Part")
		pot.Name = "Pot"
		pot.Shape = Enum.PartType.Cylinder
		pot.Size = GameConfig.POT_SIZE
		pot.Color = GameConfig.POT_COLOR
		pot.Material = GameConfig.POT_MATERIAL
		pot.Anchored = true
		pot.CanCollide = true
		pot.CFrame = CFrame.new(GameConfig.POT_OFFSET) * CFrame.Angles(0, 0, math.rad(90))
		pot.Parent = potModel
	end
	
	-- Add ClickDetector to main part
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
	billboardGui.AlwaysOnTop = true  -- Render in front of geometry
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
