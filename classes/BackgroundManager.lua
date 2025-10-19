-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_pi = math.pi
local math_sin = math.sin
local math_cos = math.cos

local table_insert = table.insert

local BackgroundManager = {}
BackgroundManager.__index = BackgroundManager

function BackgroundManager.new()
    local instance = setmetatable({}, BackgroundManager)
    return instance
end

function BackgroundManager:drawMenuBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Mythical sky gradient
    for y = 0, screenHeight, 4 do
        local progress = y / screenHeight
        local pulse = (math_sin(time * 2 + progress * 4) + 1) * 0.1

        local r = 0.1 + progress * 0.2 + pulse
        local g = 0.1 + progress * 0.1 + pulse
        local b = 0.3 + progress * 0.4 + pulse

        love.graphics.setColor(r, g, b, 0.8)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Floating mythical islands
    love.graphics.setColor(0.2, 0.5, 0.2, 0.3)
    for i = 1, 6 do
        local x = (screenWidth / 7) * i
        local y = screenHeight / 2 + math_sin(time + i) * 40
        local size = 60 + math_sin(time * 0.5 + i) * 20

        love.graphics.ellipse("fill", x, y, size, size / 3)
        love.graphics.setColor(0.3, 0.6, 0.3, 0.4)
        love.graphics.ellipse("fill", x, y - 10, size * 0.8, size / 4)
    end

    -- Distant mountains
    love.graphics.setColor(0.15, 0.15, 0.25, 0.6)
    for i = 1, 8 do
        local x = (screenWidth / 9) * i
        local height = 80 + math_sin(time * 0.3 + i) * 20
        love.graphics.polygon("fill",
            x - 40, screenHeight,
            x, screenHeight - height,
            x + 40, screenHeight
        )
    end
end

function BackgroundManager:drawGameBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Sky with moving clouds effect
    for y = 0, screenHeight, 3 do
        local progress = y / screenHeight
        local wave = math_sin(progress * 6 + time) * 0.1
        local r = 0.15 + wave
        local g = 0.15 + progress * 0.1 + wave
        local b = 0.25 + progress * 0.3 + wave

        love.graphics.setColor(r, g, b, 0.6)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Moving clouds
    love.graphics.setColor(0.8, 0.8, 0.9, 0.3)
    for i = 1, 5 do
        local x = (math_sin(time * 0.2 + i) * 0.5 + 0.5) * screenWidth
        local y = (i / 6) * screenHeight
        local size = 80 + math_sin(time + i) * 20
        love.graphics.ellipse("fill", x, y, size, size / 3)
        love.graphics.ellipse("fill", x - 30, y - 10, size * 0.7, size / 4)
        love.graphics.ellipse("fill", x + 30, y - 10, size * 0.7, size / 4)
    end

    -- Floating magical orbs
    love.graphics.setColor(0.4, 0.7, 1, 0.2)
    for i = 1, 8 do
        local x = (math_sin(time * 0.4 + i * 0.7) * 0.5 + 0.5) * screenWidth
        local y = (math_cos(time * 0.3 + i) * 0.5 + 0.5) * screenHeight
        local size = 3 + math_sin(time + i) * 2
        love.graphics.circle("fill", x, y, size)
    end
end

function BackgroundManager:drawGameOverBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Dark, stormy sky
    for y = 0, screenHeight, 4 do
        local progress = y / screenHeight
        local r = 0.2 + progress * 0.1
        local g = 0.1 + progress * 0.05
        local b = 0.1 + progress * 0.05
        love.graphics.setColor(r, g, b, 0.9)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Broken hoops
    love.graphics.setColor(0.6, 0.2, 0.2, 0.3)
    for i = 1, 6 do
        local x = (screenWidth / 7) * i
        local y = screenHeight / 2 + math_sin(time * 0.7 + i) * 30

        love.graphics.circle("line", x, y, 25)
        love.graphics.line(x - 18, y - 18, x + 18, y + 18)
        love.graphics.line(x + 18, y - 18, x - 18, y + 18)
    end

    -- Lightning effect
    local pulse = (math_sin(time * 4) + 1) * 0.05
    love.graphics.setColor(0.8, 0.8, 1, 0.1 + pulse * 0.1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
end

function BackgroundManager:drawLevelCompleteBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Victory sky gradient
    for y = 0, screenHeight, 3 do
        local progress = y / screenHeight
        local pulse = (math_sin(time * 4 + progress * 6) + 1) * 0.05

        local r = 0.3 + progress * 0.2 + pulse
        local g = 0.2 + progress * 0.3 + pulse
        local b = 0.4 + pulse
        love.graphics.setColor(r, g, b, 0.7)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Celebration sparkles
    love.graphics.setColor(1, 1, 0.8, 0.5)
    for i = 1, 15 do
        local x = (math_sin(time * 0.6 + i * 0.4) * 0.5 + 0.5) * screenWidth
        local y = (math_cos(time * 0.5 + i * 0.3) * 0.5 + 0.5) * screenHeight
        local size = 4 + math_sin(time * 2 + i) * 2

        love.graphics.circle("fill", x, y, size)

        -- Add smaller surrounding sparkles
        if i % 3 == 0 then
            love.graphics.circle("fill", x + 6, y, size * 0.6)
            love.graphics.circle("fill", x - 6, y, size * 0.6)
            love.graphics.circle("fill", x, y + 6, size * 0.6)
            love.graphics.circle("fill", x, y - 6, size * 0.6)
        end
    end

    -- Magical arches
    love.graphics.setColor(0.7, 0.8, 1, 0.3)
    for i = 1, 3 do
        local centerY = screenHeight + 50
        local radius = 150 + i * 80
        love.graphics.arc("line", "open", screenWidth / 2, centerY, radius, math_pi, 2 * math_pi)
    end
end

return BackgroundManager