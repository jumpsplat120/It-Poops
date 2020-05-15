inspect = require("third_party/inspect")

local Vector, Quad, Entity, Static
textures, loaded_objects, player, size, bounds, time = {}, {}, {}, {}, {}, 0

Vector = require("modules/Vector")
Sprite = require("modules/Sprite")
Static = require("modules/Static")
Entity = require("modules/Entity")

function love.load()
	local background, sprites, loaded_objects, win_w, win_h
	
	time, pull      = 0, 0
	win_w, win_h, _ = love.window.getMode()
	
	calculateSize()
	
	loaded_objects = {}
	
	textures = { blank = Static(love.graphics.newImage("assets/blank.png"), "blank") }
	
	calculateBounds()
		
	loadBackgroundTextures()
	loadAnimatedTextures()
	loadObjectTextures()
	
	player = { 
		e     = Entity(Sprite(love.graphics.newImage("assets/sprites/bird.png"), 2, 2, "gliding"), 500, size.win.y / 4),
		jump  = 10,
		score = 0,
		poops = {}
	}
end

function love.update(dt)
	local left, right
	
	right = love.keyboard.isDown("d")
	left  = love.keyboard.isDown("a")
	
	if right then
		player.e:addVelocity(50 * dt, 0)
	elseif left then
		player.e:addVelocity(-50 * dt, 0)
	end

	player.e:update(dt)
	
	if outOfBounds() then endGame() end
	
	for i = 1, #loaded_objects, 1 do
		loaded_objects[i]:update(dt)
	end
	
	for i = 1, #player.poops, 1 do
		player.poops[i]:update(dt)
	end

	time = time + dt
end

function love.draw()
	for i = 1, #loaded_objects, 1 do
		loaded_objects[i]:draw()
	end
end

function love.resize()
	calculateSize()
	calculateBounds()
end

function love.keypressed(k)
	local jump, poop
	
	jump = k == "space"
	poop = k == "e"
	
	if jump then player.e:addVelocity(0, player.jump) end
	
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
	
	t.poop:addImage(objs .. "fallen_poop.png", "fallen")
	
	textures.static = t
end

function loadStaticsFromFolder(path)
	local i, res, succ, val
	
	i    = 1
	res  = Static(love.graphics.newImage(path .. "/1.png"), "1")
	
	succ, val = pcall(love.graphics.newImage, path .. "/2.png")
	
	i = 2
	
	while succ do
		res:addImage(val, tostring(i))

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
	local w, h = size.win.x, size.win.y
	
	bounds = { 
		top    = Entity(textures.blank, 0, -50,  w, 50, nil, "env"),
		bottom = Entity(textures.blank, 0,   h,  w, 50, nil, "env"),
		left   = Entity(textures.blank, -50, 0, 50,  h, nil, "env"),
		right  = Entity(textures.blank,   w, 0, 50,  h, nil, "env")
	}
end

function endGame()
	error("GAME OVER")
end

function outOfBounds()
	return (player.e:collide(bounds.top) and player.e:collide(bounds.bottom) and player.e:collide(bounds.left) and player.e:collide(bounds.right))
end

function createPoop()
	local img, e
	
	img = textures.static.falling_poop
	e   = Entity(img, player.pos.x, player.pos.y, img:getWidth(), img:getHeight(), Vector.fromAngle(math.random(-5, 5)))
	
end

function drawPoops()
	local rw, sw, rh, st, new
	
	rh = size.height.scale
	rw = size.width.scale
	sw = size.width.half * rw
	st = textures.static
	new = {}

	for i = 1, #player.poops, 1 do
		local poop = player.poops[i]
		local x = (time - poop[3]) * -200 * rw

		poop[2] = poop[4] and size.height.window - (50 * rh) or poop[2] + gdt * GRAVITY * ((time - poop[3]) * 35)

		if poop[2] * rh > size.height.window - (25 * rh) then poop[4] = true end

		if poop[4] then
			love.graphics.draw(st.fallen_poop, x + poop[1] * rw, poop[2], 0, rw, rh)
		else
			love.graphics.draw(st.falling_poop, x + poop[1] * rw, poop[2] * rh, 0, rw, rh)
		end
		
		if poop[1] > 0 then new[#new + 1] = player.poops[i] end
	end
	
	player.poops = new
end


function cycle(input, min, max)
	delta = max - min
	
	function down(carry, max)
		carry = carry - delta
		if carry > max then return down(carry, max) else return carry end
	end
	
	function up(carry, min)
		carry = carry + delta
		if carry < min then return up(carry, min) else return carry end
	end
	
	input = input > max and down(input, max) or (input < min and up(input, min) or input)
	
	return input
end