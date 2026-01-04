# MAMA MIA! Sauce Tycoon - Prototype TODO

## Overview
A clicker tycoon game where players stir a giant pot of marinara sauce to earn Meatballs (currency). Each player has their own pot and economy. Data persists between sessions.

## Architecture

```
src/
├── server/
│   ├── PlayerDataManager.server.luau   # DataStore save/load, leaderstats
│   ├── PotManager.server.luau          # Creates pot per player, handles clicks
│   └── UpgradeManager.server.luau      # Processes upgrade purchases
├── client/
│   ├── MeatballsUI.client.luau         # Displays currency, upgrade buttons
│   └── ClickFeedback.client.luau       # Visual/audio feedback on click
├── shared/
│   └── GameConfig.luau                 # Constants (prices, multipliers, etc.)
└── workspace/
    └── (empty - pots created dynamically per player)
```

---

## Phase 1: Core Infrastructure ✅
> Get the foundation working: data, pot, clicking

- [x] Remove old lava scripts
- [x] Create `src/shared/GameConfig.luau` - game constants
- [x] Create `src/server/PlayerDataManager.server.luau`
  - [x] Create DataStore "SauceTycoon"
  - [x] Create leaderstats folder with "Meatballs" IntValue
  - [x] Load player data on join
  - [x] Save player data on leave
  - [x] Autosave every 30 seconds
- [x] Create `src/server/PotManager.server.luau`
  - [x] Spawn a pot (Cylinder) for each player when they join
  - [x] Position pot near player spawn
  - [x] Add ClickDetector to pot
  - [x] Award Meatballs on click (using SauceMultiplier)
  - [x] Fire RemoteEvent to client for feedback
  - [x] Added "STIR THE SAUCE!" billboard text above pot

---

## Phase 2: UI & Feedback ✅
> Make it feel satisfying to click

- [x] Create RemoteEvent in ReplicatedStorage for click feedback (done in PotManager)
- [x] Create `src/client/MeatballsUI.client.luau`
  - [x] ScreenGui with Meatballs counter (TextLabel)
  - [x] Style: Bright red background, white text, FredokaOne font
  - [x] Update display when leaderstats change
  - [x] "Pop" animation when counter updates
- [x] Create `src/client/ClickFeedback.client.luau`
  - [x] Pop-up "+X" text that floats up and fades (gold color)
  - [x] Tween pot scale (1.0 → 1.1 → 1.0) on click
  - [x] Placeholder for sound effect (ready for asset)
  - [x] Object pooling for floating text performance

---

## Phase 3: Upgrade System
> First upgrade: "Buy Spoon" increases click power

- [ ] Add to GameConfig: SPOON_BASE_PRICE = 10, PRICE_MULTIPLIER = 1.15
- [ ] Create `src/server/UpgradeManager.server.luau`
  - [ ] RemoteEvent for purchase requests
  - [ ] Calculate cost: BasePrice * (1.15 ^ AmountOwned)
  - [ ] Deduct Meatballs, increase SauceMultiplier
  - [ ] Save upgrade count to DataStore
- [ ] Add upgrade button to MeatballsUI
  - [ ] Show current cost
  - [ ] Fire RemoteEvent on click
  - [ ] Disable if can't afford

---

## Phase 4: Polish & Testing
> Make sure it all works together

- [ ] Test data persistence (leave and rejoin)
- [ ] Test multiple players (each has own pot)
- [ ] Add visual improvements to pot (red color, neon material)
- [ ] Add "MAMA MIA!" text above pot

---

## Data Structure

### Player Data (saved to DataStore)
```lua
{
    Meatballs = 0,           -- Currency
    SauceMultiplier = 1,     -- Click power
    SpoonsOwned = 0,         -- Upgrade count
}
```

### Leaderstats (visible in-game)
```
leaderstats/
└── Meatballs (IntValue)
```

---

## Key Patterns from Docs

### ClickDetector Usage
```lua
local clickDetector = Instance.new("ClickDetector")
clickDetector.Parent = pot
clickDetector.MouseClick:Connect(function(player)
    -- Award meatballs
end)
```

### DataStore Pattern
```lua
local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("SauceTycoon")

local success, data = pcall(function()
    return dataStore:GetAsync(tostring(player.UserId))
end)
```

### Remote Events (Client → Server)
```lua
-- Server: Listen for purchase
remoteEvent.OnServerEvent:Connect(function(player, upgradeType)
    -- Process purchase
end)

-- Client: Request purchase  
remoteEvent:FireServer("Spoon")
```

### UI Tweening
```lua
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Bounce)
local tween = TweenService:Create(pot, tweenInfo, {Size = originalSize * 1.1})
tween:Play()
```

---

## Current Status
**Phase 1 in progress** - Setting up infrastructure

## Next Steps
1. Create GameConfig with constants
2. Create PlayerDataManager for data persistence
3. Create PotManager for pot spawning and clicking
