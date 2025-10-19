-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sqrt = math.sqrt
local math_random = math.random

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, vx, vy, enemyType, dragonLevel)
    local instance = setmetatable({}, Enemy)

    instance.x = x
    instance.y = y
    instance.vx = vx
    instance.vy = vy
    instance.type = enemyType
    instance.dragonLevel = dragonLevel or 1

    -- Set properties based on enemy type and dragon level
    if enemyType == "goblin" then
        instance.size = 25
        instance.health = 30 + dragonLevel * 5
        instance.damage = 10
        instance.expValue = 15
        instance.scoreValue = 20
        instance.color = {0.3, 0.7, 0.3}
    elseif enemyType == "orc" then
        instance.size = 35
        instance.health = 50 + dragonLevel * 8
        instance.damage = 15
        instance.expValue = 25
        instance.scoreValue = 35
        instance.color = {0.2, 0.5, 0.2}
    elseif enemyType == "wizard" then
        instance.size = 30
        instance.health = 40 + dragonLevel * 6
        instance.damage = 20
        instance.expValue = 35
        instance.scoreValue = 50
        instance.color = {0.5, 0.3, 0.7}
    elseif enemyType == "gargoyle" then
        instance.size = 40
        instance.health = 70 + dragonLevel * 10
        instance.damage = 25
        instance.expValue = 50
        instance.scoreValue = 75
        instance.color = {0.4, 0.4, 0.4}
    end

    instance.maxHealth = instance.health

    return instance
end

function Enemy:update(dt, dragonX, dragonY)
    -- Simple AI: move toward dragon
    local dx = dragonX - self.x
    local dy = dragonY - self.y
    local distance = math_sqrt(dx * dx + dy * dy)

    if distance > 0 then
        local speed = 80 -- Base speed
        self.x = self.x + (dx / distance) * speed * dt
        self.y = self.y + (dy / distance) * speed * dt
    end
end

function Enemy:isOffScreen(screenWidth, screenHeight)
    local padding = self.size + 20
    return self.x < -padding or self.x > screenWidth + padding or
           self.y < -padding or self.y > screenHeight + padding
end

function Enemy:checkCollision(x, y, size)
    local distance = math_sqrt((self.x - x)^2 + (self.y - y)^2)
    return distance < (self.size / 2 + size / 2)
end

function Enemy:draw()
    love.graphics.setColor(self.color)

    if self.type == "goblin" then
        -- Goblin: small green creature
        love.graphics.circle("fill", self.x, self.y, self.size / 2)
        love.graphics.setColor(0.1, 0.4, 0.1)
        love.graphics.circle("fill", self.x, self.y - 3, self.size / 4) -- Head
    elseif self.type == "orc" then
        -- Orc: larger green creature
        love.graphics.circle("fill", self.x, self.y, self.size / 2)
        love.graphics.setColor(0.1, 0.3, 0.1)
        love.graphics.rectangle("fill", self.x - 8, self.y - 15, 16, 10) -- Shoulders
    elseif self.type == "wizard" then
        -- Wizard: purple robed figure
        love.graphics.circle("fill", self.x, self.y, self.size / 2)
        love.graphics.setColor(0.3, 0.2, 0.5)
        love.graphics.rectangle("fill", self.x - 6, self.y + 5, 12, 15) -- Robe
    elseif self.type == "gargoyle" then
        -- Gargoyle: gray stone creature
        love.graphics.circle("fill", self.x, self.y, self.size / 2)
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.polygon("fill",
            self.x, self.y - 15,
            self.x - 10, self.y + 10,
            self.x + 10, self.y + 10
        ) -- Wings
    end

    -- Health bar
    local barWidth = self.size
    local barHeight = 4
    local barX = self.x - barWidth / 2
    local barY = self.y - self.size / 2 - 8

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    local healthWidth = (self.health / self.maxHealth) * barWidth
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", barX, barY, healthWidth, barHeight)
end

return Enemy