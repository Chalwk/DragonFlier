-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sqrt = math.sqrt

local Fireball = {}
Fireball.__index = Fireball

function Fireball.new(x, y, targetX, targetY, dragonLevel)
    local instance = setmetatable({}, Fireball)

    instance.x = x
    instance.y = y
    instance.size = 8 + dragonLevel * 2
    instance.speed = 400
    instance.damage = 15 + dragonLevel * 5

    -- Calculate direction
    local dx = targetX - x
    local dy = targetY - y
    local distance = math_sqrt(dx * dx + dy * dy)

    instance.vx = (dx / distance) * instance.speed
    instance.vy = (dy / distance) * instance.speed

    return instance
end

function Fireball:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

function Fireball:isOffScreen(screenWidth, screenHeight)
    return self.x < -20 or self.x > screenWidth + 20 or
           self.y < -20 or self.y > screenHeight + 20
end

function Fireball:checkCollision(x, y, size)
    local distance = math_sqrt((self.x - x)^2 + (self.y - y)^2)
    return distance < (self.size / 2 + size / 2)
end

function Fireball:draw()
    -- Fireball core
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("fill", self.x, self.y, self.size / 2)

    -- Fireball outer glow
    love.graphics.setColor(1, 0.3, 0, 0.6)
    love.graphics.circle("fill", self.x, self.y, self.size / 1.5)

    -- Fire trail effect
    love.graphics.setColor(1, 0.5, 0, 0.4)
    love.graphics.circle("fill", self.x - self.vx * 0.02, self.y - self.vy * 0.02, self.size / 2)
    love.graphics.setColor(1, 0.3, 0, 0.2)
    love.graphics.circle("fill", self.x - self.vx * 0.04, self.y - self.vy * 0.04, self.size / 3)
end

return Fireball