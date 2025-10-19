-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local LevelManager = {}
LevelManager.__index = LevelManager

function LevelManager.new()
    local instance = setmetatable({}, LevelManager)

    instance.currentLevel = 1
    instance.levelTarget = 5 -- Start with 5 hoops and 3 enemies

    return instance
end

function LevelManager:getCurrentLevelData()
    -- Level progression: each level gets harder
    local hoopDensity = 1.0 + (self.currentLevel - 1) * 0.2
    local enemyDensity = 0.8 + (self.currentLevel - 1) * 0.25
    local target = 5 + math.floor((self.currentLevel - 1) * 2)

    -- Cap the densities
    hoopDensity = math.min(hoopDensity, 3.0)
    enemyDensity = math.min(enemyDensity, 3.0)

    return {
        hoopDensity = hoopDensity,
        enemyDensity = enemyDensity,
        target = target
    }
end

function LevelManager:nextLevel()
    self.currentLevel = self.currentLevel + 1
    local levelData = self:getCurrentLevelData()
    self.levelTarget = levelData.target
    return self.levelTarget
end

function LevelManager:reset()
    self.currentLevel = 1
    local levelData = self:getCurrentLevelData()
    self.levelTarget = levelData.target
end

function LevelManager:isLevelComplete(hoopsPassed, enemiesDefeated)
    return hoopsPassed >= self.levelTarget and enemiesDefeated >= math.floor(self.levelTarget * 0.6)
end

function LevelManager:getLevelProgress(hoopsPassed, enemiesDefeated)
    local hoopProgress = hoopsPassed / self.levelTarget
    local enemyProgress = enemiesDefeated / math.floor(self.levelTarget * 0.6)
    return (hoopProgress + enemyProgress) / 2
end

return LevelManager