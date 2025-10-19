-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_sqrt = math.sqrt
local math_max = math.max
local math_min = math.min

local Dragon = {}
Dragon.__index = Dragon

function Dragon.new()
    local instance = setmetatable({}, Dragon)

    instance.x = 0
    instance.y = 0
    instance.size = 40
    instance.speed = 200
    instance.color = {0.8, 0.2, 0.2} -- Red dragon

    return instance
end

function Dragon:update(dt, screenWidth, screenHeight)
    -- Keyboard controls (WASD and Arrow keys)
    local dx, dy = 0, 0

    if love.keyboard.isDown("w", "up") then dy = dy - 1 end
    if love.keyboard.isDown("s", "down") then dy = dy + 1 end
    if love.keyboard.isDown("a", "left") then dx = dx - 1 end
    if love.keyboard.isDown("d", "right") then dx = dx + 1 end

    -- Normalize diagonal movement
    if dx ~= 0 or dy ~= 0 then
        local len = math_sqrt(dx * dx + dy * dy)
        dx, dy = dx / len, dy / len
    end

    -- Apply movement
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    self:constrainToScreen(screenWidth, screenHeight)
end

function Dragon:constrainToScreen(screenWidth, screenHeight)
    local padding = self.size / 2
    self.x = math_max(padding, math_min(screenWidth - padding, self.x))
    self.y = math_max(padding, math_min(screenHeight - padding, self.y))
end

function Dragon:draw()
    -- Draw dragon body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.size / 2)

    -- Draw dragon wings
    love.graphics.setColor(0.6, 0.1, 0.1)
    love.graphics.ellipse("fill", self.x - 15, self.y, 20, 10)
    love.graphics.ellipse("fill", self.x + 15, self.y, 20, 10)

    -- Draw dragon head and details
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.circle("fill", self.x, self.y - 8, 12)

    -- Draw eyes
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x - 4, self.y - 10, 3)
    love.graphics.circle("fill", self.x + 4, self.y - 10, 3)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", self.x - 4, self.y - 10, 1.5)
    love.graphics.circle("fill", self.x + 4, self.y - 10, 1.5)

    -- Draw horns
    love.graphics.setColor(0.9, 0.9, 0.5)
    love.graphics.polygon("fill",
        self.x - 8, self.y - 20,
        self.x - 12, self.y - 30,
        self.x - 6, self.y - 22
    )
    love.graphics.polygon("fill",
        self.x + 8, self.y - 20,
        self.x + 12, self.y - 30,
        self.x + 6, self.y - 22
    )
end

return Dragon