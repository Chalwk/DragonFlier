-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sqrt = math.sqrt

local Hoop = {}
Hoop.__index = Hoop

function Hoop.new(x, y, vx, vy, hoopType)
    local instance = setmetatable({}, Hoop)

    instance.x = x
    instance.y = y
    instance.vx = vx
    instance.vy = vy
    instance.type = hoopType or "normal"
    instance.size = hoopType == "golden" and 45 or 35
    instance.rotation = 0
    instance.rotationSpeed = hoopType == "golden" and 3 or 2

    return instance
end

function Hoop:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.rotation = self.rotation + self.rotationSpeed * dt
end

function Hoop:isOffScreen(screenWidth, screenHeight)
    local padding = self.size + 10
    return self.x < -padding or self.x > screenWidth + padding or
           self.y < -padding or self.y > screenHeight + padding
end

function Hoop:checkCollision(x, y, size)
    local distance = math_sqrt((self.x - x)^2 + (self.y - y)^2)
    return distance < (self.size / 2 + size / 2)
end

function Hoop:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)

    if self.type == "golden" then
        love.graphics.setColor(1, 0.8, 0) -- Gold
        love.graphics.setLineWidth(4)
        love.graphics.circle("line", 0, 0, self.size / 2)

        -- Inner golden ring
        love.graphics.setColor(1, 0.9, 0.3, 0.6)
        love.graphics.circle("line", 0, 0, self.size / 3)

        -- Sparkle effect
        love.graphics.setColor(1, 1, 1)
        -- Draw individual points at the four cardinal directions
        love.graphics.points(
            0, -self.size/4,    -- Top
            self.size/4, 0,     -- Right
            0, self.size/4,     -- Bottom
            -self.size/4, 0     -- Left
        )
    else
        love.graphics.setColor(0.2, 0.6, 1) -- Blue
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", 0, 0, self.size / 2)

        love.graphics.setColor(0.4, 0.7, 1, 0.5)
        love.graphics.circle("line", 0, 0, self.size / 3)
    end

    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

return Hoop