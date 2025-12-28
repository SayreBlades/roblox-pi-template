-- UpgradeManager: Handles upgrade purchases
-- Validates purchases and updates player stats

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- Create RemoteEvent for purchase requests
local purchaseEvent = Instance.new("RemoteEvent")
purchaseEvent.Name = "PurchaseUpgrade"
purchaseEvent.Parent = ReplicatedStorage

-- Create RemoteFunction to get upgrade info (cost, amount owned)
local upgradeInfoFunction = Instance.new("RemoteFunction")
upgradeInfoFunction.Name = "GetUpgradeInfo"
upgradeInfoFunction.Parent = ReplicatedStorage

-- Calculate the cost of the next upgrade
local function calculateCost(amountOwned: number): number
	local cost = GameConfig.SPOON_BASE_PRICE * (GameConfig.PRICE_MULTIPLIER ^ amountOwned)
	return math.floor(cost)
end

-- Handle upgrade info requests from client
upgradeInfoFunction.OnServerInvoke = function(player: Player, upgradeType: string)
	if upgradeType == "Spoon" then
		local spoonsOwned = player:GetAttribute("SpoonsOwned") or 0
		local cost = calculateCost(spoonsOwned)
		local multiplier = player:GetAttribute("SauceMultiplier") or 1
		
		return {
			owned = spoonsOwned,
			cost = cost,
			currentPower = multiplier,
			nextPower = multiplier + GameConfig.SPOON_POWER_BONUS
		}
	end
	
	return nil
end

-- Handle purchase requests
local function onPurchaseRequest(player: Player, upgradeType: string)
	if upgradeType ~= "Spoon" then
		warn("[UpgradeManager] Unknown upgrade type:", upgradeType)
		return
	end
	
	-- Get player's current stats
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("[UpgradeManager] No leaderstats for", player.Name)
		return
	end
	
	local meatballs = leaderstats:FindFirstChild("Meatballs")
	if not meatballs then
		warn("[UpgradeManager] No Meatballs for", player.Name)
		return
	end
	
	local spoonsOwned = player:GetAttribute("SpoonsOwned") or 0
	local cost = calculateCost(spoonsOwned)
	
	-- Check if player can afford it
	if meatballs.Value < cost then
		print("[UpgradeManager]", player.Name, "can't afford spoon (has", meatballs.Value, "needs", cost, ")")
		return
	end
	
	-- Process purchase
	meatballs.Value -= cost
	
	-- Increase spoons owned
	local newSpoonsOwned = spoonsOwned + 1
	player:SetAttribute("SpoonsOwned", newSpoonsOwned)
	
	-- Increase sauce multiplier (click power)
	local currentMultiplier = player:GetAttribute("SauceMultiplier") or 1
	local newMultiplier = currentMultiplier + GameConfig.SPOON_POWER_BONUS
	player:SetAttribute("SauceMultiplier", newMultiplier)
	
	print("[UpgradeManager]", player.Name, "bought spoon #" .. newSpoonsOwned, 
		"| Cost:", cost, 
		"| New power:", newMultiplier)
	
	-- TODO: Play purchase sound via client event
end

-- Connect to purchase event
purchaseEvent.OnServerEvent:Connect(onPurchaseRequest)

print("[UpgradeManager] Initialized")
