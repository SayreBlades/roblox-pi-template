-- PlayerDataManager: Handles saving/loading player data with DataStores
-- Creates leaderstats and manages persistence

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

print("[PlayerDataManager] Starting...")

-- Check if we're in Studio (DataStore may not work)
local isStudio = RunService:IsStudio()

-- Try to get DataStoreService (may fail in Studio)
local DataStoreService = game:GetService("DataStoreService")
local dataStore = nil

local success, err = pcall(function()
	dataStore = DataStoreService:GetDataStore(GameConfig.DATASTORE_NAME)
end)

if not success then
	warn("[PlayerDataManager] DataStore not available:", err)
end

-- Cache player data in memory for quick access
local playerDataCache = {}

-- Default data for new players
local function getDefaultData()
	return {
		Meatballs = GameConfig.STARTING_MEATBALLS,
		SauceMultiplier = GameConfig.BASE_CLICK_VALUE,
		SpoonsOwned = 0,
	}
end

-- Save player data to DataStore
local function savePlayerData(player: Player)
	if not dataStore then return false end
	
	local userId = tostring(player.UserId)
	local data = playerDataCache[userId]
	
	if not data then
		warn("[PlayerDataManager] No data to save for", player.Name)
		return false
	end
	
	local success, err = pcall(function()
		dataStore:SetAsync(userId, data)
	end)
	
	if success then
		print("[PlayerDataManager] Saved data for", player.Name)
	else
		warn("[PlayerDataManager] Failed to save data for", player.Name, ":", err)
	end
	
	return success
end

-- Load player data from DataStore
local function loadPlayerData(player: Player)
	local userId = tostring(player.UserId)
	local data = nil
	
	-- Only try DataStore if available
	if dataStore then
		local success, result = pcall(function()
			return dataStore:GetAsync(userId)
		end)
		
		if success and result then
			print("[PlayerDataManager] Loaded data for", player.Name)
			data = result
		elseif not success then
			warn("[PlayerDataManager] DataStore error:", result)
		end
	end
	
	-- Use default data if no saved data
	if not data then
		print("[PlayerDataManager] Using default data for", player.Name)
		data = getDefaultData()
	end
	
	playerDataCache[userId] = data
	return data
end

-- Create leaderstats folder for player
local function createLeaderstats(player: Player, data)
	print("[PlayerDataManager] Creating leaderstats for", player.Name)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local meatballs = Instance.new("IntValue")
	meatballs.Name = "Meatballs"
	meatballs.Value = data.Meatballs
	meatballs.Parent = leaderstats
	
	-- Store multiplier as an attribute (not shown on leaderboard)
	player:SetAttribute("SauceMultiplier", data.SauceMultiplier)
	player:SetAttribute("SpoonsOwned", data.SpoonsOwned)
	
	-- Sync leaderstats changes back to cache
	meatballs.Changed:Connect(function(newValue)
		local userId = tostring(player.UserId)
		if playerDataCache[userId] then
			playerDataCache[userId].Meatballs = newValue
		end
	end)
	
	print("[PlayerDataManager] Leaderstats created! Meatballs:", data.Meatballs)
end

-- Handle player joining
local function onPlayerAdded(player: Player)
	print("[PlayerDataManager] Player joined:", player.Name)
	
	-- Load data
	local data = loadPlayerData(player)
	
	-- Create leaderstats
	createLeaderstats(player, data)
	
	-- Start autosave loop (only if DataStore works)
	if dataStore then
		local userId = tostring(player.UserId)
		task.spawn(function()
			while player.Parent do
				task.wait(GameConfig.AUTOSAVE_INTERVAL)
				
				-- Sync attributes back to cache before saving
				if playerDataCache[userId] then
					playerDataCache[userId].SauceMultiplier = player:GetAttribute("SauceMultiplier") or 1
					playerDataCache[userId].SpoonsOwned = player:GetAttribute("SpoonsOwned") or 0
				end
				
				savePlayerData(player)
			end
		end)
	end
end

-- Handle player leaving
local function onPlayerRemoving(player: Player)
	local userId = tostring(player.UserId)
	print("[PlayerDataManager] Player leaving:", player.Name)
	
	-- Sync final state
	if playerDataCache[userId] then
		playerDataCache[userId].SauceMultiplier = player:GetAttribute("SauceMultiplier") or 1
		playerDataCache[userId].SpoonsOwned = player:GetAttribute("SpoonsOwned") or 0
	end
	
	-- Save and clean up
	savePlayerData(player)
	playerDataCache[userId] = nil
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in game (for studio testing)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

print("[PlayerDataManager] Initialized! Studio mode:", isStudio)
