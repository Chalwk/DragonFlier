-- Dragon Flier - Love2D Game for Android & Windows
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local Dragon = require("classes/Dragon")
local Hoop = require("classes/Hoop")
local Enemy = require("classes/Enemy")
local Fireball = require("classes/Fireball")
local ParticleSystem = require("classes/ParticleSystem")
local ScreenShake = require("classes/ScreenShake")
local LevelManager = require("classes/LevelManager")
local UIManager = require("classes/UIManager")
local Menu = require("classes/Menu")
local BackgroundManager = require("classes/BackgroundManager")

local math_random = math.random
local math_max = math.max
local math_min = math.min
local table_insert, table_remove = table.insert, table.remove

-- Game variables
local screenWidth, screenHeight
local hoops, enemies, fireballs
local hoopSpawnTimer, enemySpawnTimer
local sounds, colors
local gameState, score, health, dragonLevel, experience, hoopsPassed, enemiesDefeated
local fireballCooldown, fireballTimer
local specialAbilityCooldown, specialAbilityTimer

-- Game systems
local dragon, particleSystem, screenShake, levelManager, uiManager, menu, backgroundManager

local function updateScreenSize()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

local function spawnHoop()
    local side = math_random(4)
    local x, y, vx, vy

    if side == 1 then -- Top
        x = math_random(screenWidth)
        y = -50
        vx = (math_random() - 0.5) * 50
        vy = math_random(80, 150)
    elseif side == 2 then -- Right
        x = screenWidth + 50
        y = math_random(screenHeight)
        vx = -math_random(80, 150)
        vy = (math_random() - 0.5) * 50
    elseif side == 3 then -- Bottom
        x = math_random(screenWidth)
        y = screenHeight + 50
        vx = (math_random() - 0.5) * 50
        vy = -math_random(80, 150)
    else -- Left
        x = -50
        y = math_random(screenHeight)
        vx = math_random(80, 150)
        vy = (math_random() - 0.5) * 50
    end

    local hoopType = math_random() < 0.2 and "golden" or "normal"
    local hoop = Hoop.new(x, y, vx, vy, hoopType)
    table_insert(hoops, hoop)
end

local function spawnEnemy()
    local enemyTypes = {"goblin", "orc", "wizard", "gargoyle"}
    local weights = {40, 30, 20, 10} -- Percentage chances
    local totalWeight = 0
    for _, w in ipairs(weights) do totalWeight = totalWeight + w end

    local roll = math_random(totalWeight)
    local enemyType
    local accumulated = 0

    for i, w in ipairs(weights) do
        accumulated = accumulated + w
        if roll <= accumulated then
            enemyType = enemyTypes[i]
            break
        end
    end

    local side = math_random(4)
    local x, y, vx, vy

    if side == 1 then -- Top
        x = math_random(screenWidth)
        y = -60
        vx = (math_random() - 0.5) * 40
        vy = math_random(60, 120)
    elseif side == 2 then -- Right
        x = screenWidth + 60
        y = math_random(screenHeight)
        vx = -math_random(60, 120)
        vy = (math_random() - 0.5) * 40
    elseif side == 3 then -- Bottom
        x = math_random(screenWidth)
        y = screenHeight + 60
        vx = (math_random() - 0.5) * 40
        vy = -math_random(60, 120)
    else -- Left
        x = -60
        y = math_random(screenHeight)
        vx = math_random(60, 120)
        vy = (math_random() - 0.5) * 40
    end

    local enemy = Enemy.new(x, y, vx, vy, enemyType, dragonLevel)
    table_insert(enemies, enemy)
end

local function shootFireball(targetX, targetY)
    if fireballTimer <= 0 then
        local fireball = Fireball.new(dragon.x, dragon.y, targetX, targetY, dragonLevel)
        table_insert(fireballs, fireball)
        fireballTimer = fireballCooldown
        love.audio.play(sounds.fireball)
        return true
    end
    return false
end

local function useSpecialAbility()
    if specialAbilityTimer <= 0 then
        -- Triple shot special ability
        for i = -1, 1 do
            local angle = i * 0.3
            local fireball = Fireball.new(dragon.x, dragon.y,
                dragon.x + math.cos(angle) * 100,
                dragon.y + math.sin(angle) * 100,
                dragonLevel)
            table_insert(fireballs, fireball)
        end
        specialAbilityTimer = specialAbilityCooldown
        love.audio.play(sounds.special)
        particleSystem:createParticles(dragon.x, dragon.y, {1, 0.5, 0}, 20)
        return true
    end
    return false
end

local function checkHoopCollisions()
    for i = #hoops, 1, -1 do
        local hoop = hoops[i]

        if hoop:checkCollision(dragon.x, dragon.y, dragon.size) then
            local expGain = hoop.type == "golden" and 25 or 10
            local scoreGain = hoop.type == "golden" and 50 or 20

            experience = experience + expGain
            score = score + scoreGain
            hoopsPassed = hoopsPassed + 1

            particleSystem:createParticles(hoop.x, hoop.y,
                hoop.type == "golden" and {1, 0.8, 0} or {0, 0.8, 1}, 12)

            love.audio.play(hoop.type == "golden" and sounds.goldenHoop or sounds.hoop)

            table_remove(hoops, i)
        end
    end
end

local function checkFireballCollisions()
    for i = #fireballs, 1, -1 do
        local fireball = fireballs[i]
        local hit = false

        for j = #enemies, 1, -1 do
            local enemy = enemies[j]

            if fireball:checkCollision(enemy.x, enemy.y, enemy.size) then
                enemy.health = enemy.health - fireball.damage

                particleSystem:createParticles(enemy.x, enemy.y, {1, 0.3, 0}, 8)

                if enemy.health <= 0 then
                    local expGain = enemy.expValue
                    local scoreGain = enemy.scoreValue

                    experience = experience + expGain
                    score = score + scoreGain
                    enemiesDefeated = enemiesDefeated + 1

                    particleSystem:createParticles(enemy.x, enemy.y, {1, 0, 0}, 15)
                    screenShake:trigger(5, 0.3)
                    love.audio.play(sounds.enemyDefeat)

                    table_remove(enemies, j)
                else
                    love.audio.play(sounds.enemyHit)
                end

                hit = true
                break
            end
        end

        if hit or fireball:isOffScreen(screenWidth, screenHeight) then
            table_remove(fireballs, i)
        end
    end
end

local function checkEnemyCollisions()
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]

        if enemy:checkCollision(dragon.x, dragon.y, dragon.size) then
            health = math_max(0, health - enemy.damage)
            particleSystem:createParticles(dragon.x, dragon.y, {1, 0, 0}, 10)
            screenShake:trigger(8, 0.4)
            love.audio.play(sounds.dragonHurt)

            if health <= 0 then
                gameState = "gameOver"
                love.audio.play(sounds.gameOver)
            end

            table_remove(enemies, i)
        end
    end
end

local function checkLevelUp()
    local expNeeded = dragonLevel * 100
    if experience >= expNeeded then
        dragonLevel = dragonLevel + 1
        experience = experience - expNeeded
        health = 100 -- Full heal on level up
        fireballCooldown = math_max(0.1, fireballCooldown - 0.05) -- Faster shooting

        particleSystem:createParticles(dragon.x, dragon.y, {0, 1, 1}, 30)
        screenShake:trigger(10, 0.6)
        love.audio.play(sounds.levelUp)
    end
end

local function startGame()
    gameState = "playing"
    levelManager:reset()
    score = 0
    health = 100
    dragonLevel = 1
    experience = 0
    hoopsPassed = 0
    enemiesDefeated = 0
    hoops = {}
    enemies = {}
    fireballs = {}
    hoopSpawnTimer = 0
    enemySpawnTimer = 0
    fireballTimer = 0
    specialAbilityTimer = 0
    fireballCooldown = 0.3
    specialAbilityCooldown = 10

    dragon.x = screenWidth / 2
    dragon.y = screenHeight / 2
end

local function nextLevel()
    levelManager:nextLevel()
    gameState = "playing"
end

local function handleInput()
    if gameState == "menu" then
        startGame()
    elseif gameState == "gameOver" then
        startGame()
    elseif gameState == "levelComplete" then
        nextLevel()
    end
end

function love.load()
    love.window.setTitle("Dragon Flier")

    -- Initialize managers and systems
    uiManager = UIManager.new()
    menu = Menu.new()
    backgroundManager = BackgroundManager.new()
    dragon = Dragon.new()
    particleSystem = ParticleSystem.new()
    screenShake = ScreenShake.new()
    levelManager = LevelManager.new()

    updateScreenSize()

    -- Load sounds
    sounds = {}
    sounds.background = love.audio.newSource("assets/sounds/mythical_theme.mp3", "stream")
    sounds.gameOver = love.audio.newSource("assets/sounds/game_over.mp3", "static")
    sounds.levelComplete = love.audio.newSource("assets/sounds/level_complete.mp3", "static")
    sounds.levelUp = love.audio.newSource("assets/sounds/level_up.mp3", "static")
    sounds.hoop = love.audio.newSource("assets/sounds/hoop.mp3", "static")
    sounds.goldenHoop = love.audio.newSource("assets/sounds/golden_hoop.mp3", "static")
    sounds.fireball = love.audio.newSource("assets/sounds/fireball.mp3", "static")
    sounds.enemyHit = love.audio.newSource("assets/sounds/enemy_hit.mp3", "static")
    sounds.enemyDefeat = love.audio.newSource("assets/sounds/enemy_defeat.mp3", "static")
    sounds.dragonHurt = love.audio.newSource("assets/sounds/dragon_hurt.mp3", "static")
    sounds.special = love.audio.newSource("assets/sounds/special_ability.mp3", "static")

    -- Set background music
    if sounds.background then
        sounds.background:setLooping(true)
        sounds.background:setVolume(0.4)
        love.audio.play(sounds.background)
    end

    -- Colors
    colors = {
        dragon = {0.8, 0.2, 0.2},
        fireball = {1, 0.5, 0},
        hoop = {0.2, 0.6, 1},
        goldenHoop = {1, 0.8, 0},
        enemy = {0.3, 0.7, 0.3},
        text = {1, 1, 1},
        ui = {0.8, 0.8, 0.8}
    }

    -- Initialize game state
    gameState = "menu"
    hoops = {}
    enemies = {}
    fireballs = {}
    hoopSpawnTimer = 0
    enemySpawnTimer = 0

    -- Set initial dragon position
    dragon.x = screenWidth / 2
    dragon.y = screenHeight / 2
end

function love.update(dt)
    updateScreenSize()

    if gameState == "menu" then
        menu:update(dt)
    elseif gameState == "playing" then
        -- Update dragon
        dragon:update(dt, screenWidth, screenHeight)

        -- Update cooldowns
        fireballTimer = math_max(0, fireballTimer - dt)
        specialAbilityTimer = math_max(0, specialAbilityTimer - dt)

        -- Spawn hoops and enemies
        hoopSpawnTimer = hoopSpawnTimer + dt
        enemySpawnTimer = enemySpawnTimer + dt

        local levelData = levelManager:getCurrentLevelData()
        if hoopSpawnTimer >= 2.0 / levelData.hoopDensity then
            spawnHoop()
            hoopSpawnTimer = 0
        end

        if enemySpawnTimer >= 3.0 / levelData.enemyDensity then
            spawnEnemy()
            enemySpawnTimer = 0
        end

        -- Update game objects
        for i = #hoops, 1, -1 do
            hoops[i]:update(dt)
            if hoops[i]:isOffScreen(screenWidth, screenHeight) then
                table_remove(hoops, i)
            end
        end

        for i = #enemies, 1, -1 do
            enemies[i]:update(dt, dragon.x, dragon.y)
            if enemies[i]:isOffScreen(screenWidth, screenHeight) then
                table_remove(enemies, i)
            end
        end

        for i = #fireballs, 1, -1 do
            fireballs[i]:update(dt)
        end

        -- Update systems
        particleSystem:update(dt)
        screenShake:update(dt)

        -- Check collisions
        checkHoopCollisions()
        checkFireballCollisions()
        checkEnemyCollisions()
        checkLevelUp()

        -- Auto-shoot at nearest enemy
        if #enemies > 0 and fireballTimer <= 0 then
            local nearestEnemy = nil
            local nearestDist = math.huge

            for _, enemy in ipairs(enemies) do
                local dist = math.sqrt((dragon.x - enemy.x)^2 + (dragon.y - enemy.y)^2)
                if dist < nearestDist then
                    nearestDist = dist
                    nearestEnemy = enemy
                end
            end

            if nearestEnemy and nearestDist < 400 then
                shootFireball(nearestEnemy.x, nearestEnemy.y)
            end
        end

        -- Check level completion
        if levelManager:isLevelComplete(hoopsPassed, enemiesDefeated) then
            gameState = "levelComplete"
            love.audio.play(sounds.levelComplete)
        end

        -- Check game over
        if health <= 0 then
            gameState = "gameOver"
            love.audio.play(sounds.gameOver)
        end
    end
end

function love.draw()
    -- Draw background based on game state
    if gameState == "menu" then
        backgroundManager:drawMenuBackground(screenWidth, screenHeight)
    elseif gameState == "playing" then
        backgroundManager:drawGameBackground(screenWidth, screenHeight)
    elseif gameState == "gameOver" then
        backgroundManager:drawGameOverBackground(screenWidth, screenHeight)
    elseif gameState == "levelComplete" then
        backgroundManager:drawLevelCompleteBackground(screenWidth, screenHeight)
    end

    -- Apply screen shake for gameplay states
    local shakeX, shakeY = 0, 0
    if gameState == "playing" then
        shakeX, shakeY = screenShake:getOffset()
    end

    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)

    -- Draw game elements
    if gameState == "menu" then
        menu:draw(screenWidth, screenHeight)
    elseif gameState == "playing" then
        -- Draw hoops
        for _, hoop in ipairs(hoops) do
            hoop:draw()
        end

        -- Draw enemies
        for _, enemy in ipairs(enemies) do
            enemy:draw()
        end

        -- Draw fireballs
        for _, fireball in ipairs(fireballs) do
            fireball:draw()
        end

        -- Draw dragon
        dragon:draw()

        -- Draw particles
        particleSystem:draw()

        -- Draw UI
        uiManager:drawGameUI(health, levelManager.currentLevel, dragonLevel, experience,
                            hoopsPassed, enemiesDefeated, levelManager.levelTarget, score,
                            specialAbilityTimer, specialAbilityCooldown, colors, screenWidth, screenHeight)
    elseif gameState == "gameOver" then
        uiManager:drawGameOver(score, dragonLevel, screenWidth)
    elseif gameState == "levelComplete" then
        uiManager:drawLevelComplete(levelManager.currentLevel, score, dragonLevel, screenWidth)
    end

    love.graphics.pop()
end

-- Input handling
function love.touchpressed(id, x, y, dx, dy, pressure)
    if gameState == "playing" then
        useSpecialAbility()
    else
        handleInput()
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        if gameState == "playing" then
            useSpecialAbility()
        else
            handleInput()
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "playing" then
            gameState = "menu"
        else
            love.event.quit()
        end
    elseif key == "space" and gameState == "playing" then
        useSpecialAbility()
    elseif key == "f1" then
        -- Debug: instant level up
        if gameState == "playing" then
            experience = dragonLevel * 100
            checkLevelUp()
        end
    end
end

-- Handle window resize
function love.resize(w, h)
    updateScreenSize()
    if dragon then
        dragon:constrainToScreen(screenWidth, screenHeight)
    end
end