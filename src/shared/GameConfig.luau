-- GameConfig: Central configuration for MAMA MIA! Sauce Tycoon
-- All game constants in one place for easy tuning

local GameConfig = {}

-- Currency
GameConfig.STARTING_MEATBALLS = 0
GameConfig.BASE_CLICK_VALUE = 1

-- Pot settings
GameConfig.POT_SIZE = Vector3.new(8, 4, 8)  -- Cylinder dimensions
GameConfig.POT_COLOR = Color3.fromRGB(200, 30, 30)  -- Marinara red
GameConfig.POT_MATERIAL = Enum.Material.SmoothPlastic
GameConfig.POT_OFFSET = Vector3.new(10, 1.5, 0)  -- Offset from spawn

-- Upgrade: Spoon
GameConfig.SPOON_BASE_PRICE = 10
GameConfig.PRICE_MULTIPLIER = 1.15  -- Cost increases by 15% each purchase
GameConfig.SPOON_POWER_BONUS = 1    -- Each spoon adds +1 to click power

-- Data persistence
GameConfig.AUTOSAVE_INTERVAL = 30  -- Seconds between autosaves
GameConfig.DATASTORE_NAME = "SauceTycoon_v1"

-- Visual feedback
GameConfig.POT_TWEEN_SCALE = 1.1   -- How much pot grows on click
GameConfig.POT_TWEEN_TIME = 0.1    -- Tween duration in seconds

-- Audio (placeholders - asset IDs to be added later)
GameConfig.SOUNDS = {
	Click = nil,       -- Squishy sauce sound
	Purchase = nil,    -- Cash register / success
	MamaMia = nil,     -- "MAMA MIA!" voice clip
}

return GameConfig
