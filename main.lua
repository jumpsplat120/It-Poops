inspect = require("third_party/inspect")

local Vector, Quad, Entity, Static, Background
textures, loaded_objects, background_objects, player, size, bounds, time, gdt = {}, {}, {}, {}, {}, {}, 0, 0

Vector     = require("modules/Vector")
Sprite     = require("modules/Sprite")
Static     = require("modules/Static")
Entity     = require("modules/Entity")
Background = require("modules/Background")

function love.load()
	local win_w, win_h, _ = love.window.getMode()
	
	time = 0
	
	calculateSize()
	
	textures = { blank = Static(love.graphics.newImage("assets/blank.png"), "blank") }
	
	calculateBounds()

	loadBackgroundTextures()
	loadAnimatedTextures()
	loadObjectTextures()
	
	calculateBGObjects()
	calculatePlayer()
end

function love.update(dt)
	local left, right
	
	right = love.keyboard.isDown("d")
	left  = love.keyboard.isDown("a")
	
	if math.abs(player.e.vel.x) < player.move.max then
		if right then
			player.e:accelerate(player.move.speed, 0)
		elseif left then
			player.e:accelerate(-player.move.speed, 0)
		end
	end
	
	--wind resistance
	player.e:accelerate(-player.e.vel.x * .1, 0)

	player.e:update(dt)
	
	if player.e:oob() then print("Hit edge") end
	
	updateObjectTable(background_objects)
	updateObjectTable(loaded_objects)
	updateObjectTable(player.poops)
	
	gdt  = dt
	time = time + dt
end

function love.draw()
	love.graphics.scale(size.scale.x, size.scale.y)
	drawObjectTable(background_objects)
	drawObjectTable(loaded_objects)
	drawObjectTable(player.poops)
	player.e:draw(5 * gdt)
end

function love.resize()
	calculateSize()
	calculateBounds() 
	calculatePlayer()
	calculateBGObjects()
end

function love.keypressed(k)
	local jump, poop
	
	jump = k == "space"
	poop = k == "e"
	
	if jump then
		player.e.vel:set(player.e.vel.x, player.jump)
	end
	
	if poop then player.poops[#player.poops + 1] = createPoop() end
end

function loadBackgroundTextures()
	local t, bg
	
	t  = {}
	bg = "assets/background/"
	
	t.sky       = Static(love.graphics.newImage(bg .. "skybox.png"), "sky")
	t.mountains = Static(love.graphics.newImage(bg .. "mountains.png"), "mountains")
	t.city      = Static(love.graphics.newImage(bg .. "cityscape.png"), "city")
	t.clouds    = loadStaticsFromFolder(bg .. "clouds")
	
	textures.bg = t
end

function loadAnimatedTextures()
	local t, sp
	
	t  = {}
	sp = "assets/sprites/"
	
	t.trees = loadSpritesFromFolder(sp .. "trees", 1, 2)
	
	textures.sprites = t
end

function loadObjectTextures()
	local t, objs
	
	t    = {}
	objs = "assets/objects/"
	
	t.balcony  = Static(love.graphics.newImage(objs .. "balcony.png"), "balcony")
	t.bench    = Static(love.graphics.newImage(objs .. "bench.png"), "bench")
	t.awning   = Static(love.graphics.newImage(objs .. "awning.png"), "awning")
	t.fire_esc = Static(love.graphics.newImage(objs .. "fire_escape.png"), "fire_escape")
	t.chimney  = Static(love.graphics.newImage(objs .. "chimney.png"), "chimney")
	t.poop     = Static(love.graphics.newImage(objs .. "falling_poop.png"), "falling")
	
	t.poop:addImage(love.graphics.newImage(objs .. "fallen_poop.png"), "fallen")
	
	textures.static = t
end

function loadStaticsFromFolder(path)
	local i, res, succ, val
	
	i    = 1
	res  = Static(love.graphics.newImage(path .. "/1.png"), 1)
	
	succ, val = pcall(love.graphics.newImage, path .. "/2.png")
	
	i = 2
	
	while succ do
		res:addImage(val, i)

		i = i + 1
		
		succ, val = pcall(love.graphics.newImage, path .. "/" .. i .. ".png")
	end
	
	return res
end

function loadSpritesFromFolder(path, rows, cols)
	local i, res, succ, val
	
	i    = 1
	res  = Sprite(love.graphics.newImage(path .. "/1.png"), rows, cols, "1")
	
	succ, val = pcall(love.graphics.newImage, path .. "/2.png", rows, cols)
	
	i = 2
	
	while succ do
		res:addAnimation(val, tostring(i))

		i = i + 1
		
		succ, val = pcall(love.graphics.newImage, path .. "/" .. i .. ".png", rows, cols)
	end
	
	return res
end

function calculateBGObjects()
	if #background_objects == 0 then
		background_objects = {
			Background(textures.bg.sky),
			Background(textures.bg.clouds:random(),                                        nil, love.math.random(0, 50), nil, nil, Vector(-.5, 0)),
			Background(textures.bg.clouds:random(), size.full.x * love.math.random(5, 10) / 10, love.math.random(0, 50), nil, nil, Vector(-.5, 0)),
			Background(textures.bg.clouds:random(), size.full.x * love.math.random(5, 10) / 10, love.math.random(0, 50), nil, nil, Vector(-.5, 0)),
			Background(textures.bg.mountains,                                      size.full.x,                     nil, nil, nil, Vector(-1, 0)),
			Background(textures.bg.mountains,                                              nil,                     nil, nil, nil, Vector(-1, 0)),
			Background(textures.bg.city,                                           size.full.x,                     nil, nil, nil, Vector(-2, 0)),
			Background(textures.bg.city,                                                   nil,                     nil, nil, nil, Vector(-2, 0))
		}
	end
end

function calculateSize()
	local w, h, _ = love.window.getMode()

	if #size == 0 then
		size = {
			full = Vector(1920, 1080),
			half = Vector(960, 540),
			win  = Vector(w, h)
		}
		
		size.scale = size.win / size.full
	else
		size.win:set(w, h)
		size.scale:set(size.win / size.full)
	end
end

function calculateBounds()
	local x, y, w, h
	
	w = size.full.x
	h = size.full.y
	x = w / 2
	y = h / 2 
	
	bounds = { 
		top    = Entity(textures.blank,   0, -50,  w, 50, nil, "env"),
		bottom = Entity(textures.blank,   0,   h,  w, 50, nil, "env"),
		left   = Entity(textures.blank, -50,   0, 50,  h, nil, "env"),
		right  = Entity(textures.blank,   w,   0, 50,  h, nil, "env"),
		inner  = Entity(textures.blank,   0,   0,  w,  h, nil, "env")
	}
end

function deepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepCopy(orig_key, copies)] = deepCopy(orig_value, copies)
            end
            setmetatable(copy, deepCopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
	
    return copy
end

function calculatePlayer()
	local JUMP, MOVE
	
	JUMP = -13
	MOVE = 4
	
	if #player == 0 then
		player = { 
			e     = Entity(Sprite(love.graphics.newImage("assets/sprites/bird.png"), 2, 2, "gliding"), 500, size.win.y / 4, nil, nil, nil, "dyn"),
			jump  = JUMP,
			move  = {
				speed = MOVE,
				max   = 8
			},
			score = 0,
			poops = {}
		}
	end
end

function updateObjectTable(tbl)
	for i = 1, #tbl, 1 do
		if tbl[i] == nil then break end
		
		tbl[i]:update(dt)
		
		if tbl == background_objects then
			local is_inb = tbl[i]:inb()

			if not is_inb and tbl[i].was_inb then
				tbl[i].pos.x = tbl[i].x + size.full.x * 2
				tbl[i].was_inb = false
			elseif is_inb then 
				tbl[i].was_inb = true
			end
		else
			if tbl[i]:oob() then table.remove(tbl, i) end
		end
	end
end

function drawObjectTable(tbl)
	for i = 1, #tbl, 1 do
		tbl[i]:draw()
	end
end

function endGame()
	error("GAME OVER")
end

function createPoop()
	local img, e
	
	img = textures.static.poop
	e   = Entity(img, player.e.x + player.e.w / 2, player.e.y + player.e.h / 2, img.w, img.h, Vector.fromAngle(math.random(-5, 5)), "dyn")

	return e
end
