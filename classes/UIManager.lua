-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_min = math.min
local math_floor = math.floor

local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local instance = setmetatable({}, UIManager)

    instance.smallFont = love.graphics.newFont(18)
    instance.mediumFont = love.graphics.newFont(24)
    instance.largeFont = love.graphics.newFont(36)

    return instance
end

function UIManager:drawGameUI(health, currentLevel, dragonLevel, experience, hoopsPassed, enemiesDefeated, levelTarget, score,
                             specialAbilityTimer, specialAbilityCooldown, colors, screenWidth, screenHeight)
    -- Health bar
    local barWidth, barHeight = 200, 20
    local barX, barY = 20, 20

    -- Background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    -- Health fill
    local healthWidth = (health / 100) * barWidth
    local r, g = health > 50 and (1 - (health - 50) / 50) or 1, health > 50 and 1 or (health / 50)
    love.graphics.setColor(r, g, 0)
    love.graphics.rectangle("fill", barX, barY, healthWidth, barHeight)

    -- Border
    love.graphics.setColor(colors.ui)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)

    -- Stats
    love.graphics.setColor(colors.text)
    love.graphics.setFont(self.smallFont)
    love.graphics.print("Level: " .. currentLevel, 20, 50)
    love.graphics.print("Dragon Level: " .. dragonLevel, 20, 75)
    love.graphics.print("EXP: " .. experience .. "/" .. (dragonLevel * 100), 20, 100)
    love.graphics.print("Hoops: " .. hoopsPassed .. "/" .. levelTarget, 20, 125)
    love.graphics.print("Enemies: " .. enemiesDefeated, 20, 150)
    love.graphics.print("Score: " .. score, 20, 175)

    -- Special ability cooldown
    local abilityReady = specialAbilityTimer <= 0
    love.graphics.setColor(abilityReady and colors.goldenHoop or colors.ui)
    love.graphics.print("Special: " .. (abilityReady and "READY" or math_floor(specialAbilityTimer) .. "s"), 20, 200)

    -- Progress indicators
    local progressWidth = 200
    local hoopProgress = math_min(hoopsPassed / levelTarget, 1)
    local enemyProgress = math_min(enemiesDefeated / math_floor(levelTarget * 0.6), 1)

    -- Hoop progress
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", screenWidth - progressWidth - 20, 20, progressWidth, 8)
    love.graphics.setColor(colors.hoop)
    love.graphics.rectangle("fill", screenWidth - progressWidth - 20, 20, progressWidth * hoopProgress, 8)

    -- Enemy progress
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", screenWidth - progressWidth - 20, 35, progressWidth, 8)
    love.graphics.setColor(colors.enemy)
    love.graphics.rectangle("fill", screenWidth - progressWidth - 20, 35, progressWidth * enemyProgress, 8)

    -- Progress labels
    love.graphics.setColor(colors.text)
    love.graphics.print("Hoops", screenWidth - progressWidth - 100, 20)
    love.graphics.print("Enemies", screenWidth - progressWidth - 100, 35)
end

function UIManager:drawGameOver(score, dragonLevel, screenWidth)
    love.graphics.setFont(self.largeFont)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("Game Over", 0, 150, screenWidth, "center")

    love.graphics.setFont(self.mediumFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. score, 0, 250, screenWidth, "center")
    love.graphics.printf("Dragon Level: " .. dragonLevel, 0, 300, screenWidth, "center")
    love.graphics.printf("Click/Tap to Restart", 0, 380, screenWidth, "center")
end

function UIManager:drawLevelComplete(currentLevel, score, dragonLevel, screenWidth)
    love.graphics.setFont(self.largeFont)
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.printf("Level " .. currentLevel .. " Complete!", 0, 150, screenWidth, "center")

    love.graphics.setFont(self.mediumFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Score: " .. score, 0, 250, screenWidth, "center")
    love.graphics.printf("Dragon Level: " .. dragonLevel, 0, 300, screenWidth, "center")
    love.graphics.printf("Click/Tap for Next Level", 0, 380, screenWidth, "center")
end

return UIManager