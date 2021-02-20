inspect = require("third_party/inspect")

local Vector, Quad, Entity, Static, Background
textures, loaded_objects, background_objects, gui, player, size, bounds, time, gdt, game_state = {}, {}, {}, {}, {}, {}, {}, 0, 0, "start_game"

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
	--initCityGen()
	createMenus()
	calculateBGObjects()
	calculatePlayer()
end

function love.update(dt)
	print(game_state)
	if game_state == "in_game" then
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
		
		if player.e:oob() then game_state = "end_game" end
	end	
	
	updateObjectTable(background_objects)
	updateObjectTable(loaded_objects)
	updateObjectTable(player.poops)
	
	gdt  = dt
	time = time + dt
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(size.scale.x, size.scale.y)
	drawObjectTable(background_objects)
	drawObjectTable(loaded_objects, 3 * gdt)
	drawObjectTable(player.poops)

	if game_state == "in_game" then 
		player.e:draw(5 * gdt)
		love.graphics.pop()
	else
		love.graphics.pop()
		drawMenu(game_state)
	end
end

function love.resize()
	calculateSize()
	calculateBounds() 
	calculatePlayer()
	calculateBGObjects()
	resizeMenu()
end

function love.mousepressed(x, y, button, is_touch, presses)
	local m_vec = Vector(x, y)
	
	if button == 1 then
		if game_state == "start_game" then
			local s, q
			
			s = gui.start_game.start
			q = gui.start_game.quit
			
			if m_vec:inRect(s.x, s.y, s.w, s.h) then game_state = "in_game" end
			if m_vec:inRect(q.x, q.y, q.w, q.h) then love.event.quit() end
		elseif game_state == "end_game" then
			local r, q
			
			r = gui.end_game.restart
			q = gui.end_game.quit
			
			if m_vec:inRect(r.x, r.y, r.w, r.h) then
				player.e.pos:set(size.win / 2)
				player.e.hitbox.pos:set(size.win / 2)
				player.e.vel:set(0, 0)
				game_state = "in_game"
			end
			if m_vec:inRect(q.x, q.y, q.w, q.h) then love.event.quit() end
		end
	end
end

function love.keypressed(k)
	local jump, poop
	
	jump = k == "space"
	poop = k == "e"
	dbug = k == "q"
	
	if jump then
		player.e.vel:set(player.e.vel.x, player.jump)
	end
	
	if poop then player.poops[#player.poops + 1] = createPoop() end
	
	if dbug then game_state = "end_game" end
end

function loadBackgroundTextures()
	local t, bg
	
	t  = {}
	bg = "assets/background/"
	
	t.sky       = Static(love.graphics.newImage(bg .. "skybox.png"), "sky")
	t.mountains = Static(love.graphics.newImage(bg .. "mountains.png"), "mountains")
	t.city      = Static(love.graphics.newImage(bg .. "cityscape.png"), "city")
	t.sidewalk  = loadStaticsFromFolder(bg .. "sidewalks")
	t.clouds    = loadStaticsFromFolder(bg .. "clouds")
	
	textures.bg = t
end

function drawMenu(menu_type)
	local t = gui[menu_type]
	
	for key, val in pairs(t) do
		val:draw()
	end
end

function createMenus()
	local s, cw, ch
	
	s  = textures.static
	cw = size.win.x / 2
	ch = size.win.y / 2
	
	gui = {
		start_game = {
			title = Entity(s.title, cw - s.title.w / 2, 0),
			start = Entity(s.start, cw - s.start.w / 2, size.win.y / 4),
			quit = Entity(s.quit, cw - s.quit.w / 2, size.win.y / 2)
		},
		end_game = {
			restart = Entity(s.restart, cw - s.start.w / 2, size.win.y / 4),
			quit  = Entity(s.quit, cw - s.quit.w / 2, size.win.y / 2)
		}
	}
end

function cityGen()
	if time % 2 == 0 then
		
	end
end

function resizeMenu()
	local st, en, cw
	
	st = gui.start_game
	en = gui.end_game
	cw = size.win.x / 2
	
	st.title.pos:set(cw - st.title.w / 2, 0)
	st.start.pos:set(cw - st.start.w / 2, size.win.y / 4)
	st.quit.pos:set(cw - st.quit.w / 2, size.win.y / 2)
	
	en.restart.pos:set(cw - en.restart.w / 2, size.win.y / 4)
	en.quit.pos:set(cw - en.quit.w / 2, size.win.y / 2)
end

function loadAnimatedTextures()
	local t, sp
	
	t  = {}
	sp = "assets/sprites/"
	
	t.trees  = loadSpritesFromFolder(sp .. "trees", 1, 2)
	t.people = {}
	t.people.bob = Sprite(love.graphics.newImage(sp .. "people/bob/stand.png"), 1, 3, "stand")
	t.people.bob:addAnimation(love.graphics.newImage(sp .. "people/bob/disgust.png"), 1, 3, "disgust")
	
	textures.sprites = t
end

function loadObjectTextures()
	local t, objs
	
	t    = {}
	objs = "assets/objects/"
	gui  = "assets/gui/"
	
	t.balcony  = Static(love.graphics.newImage(objs .. "balcony.png"), "balcony")
	t.bench    = Static(love.graphics.newImage(objs .. "bench.png"), "bench")
	t.awning   = Static(love.graphics.newImage(objs .. "awning.png"), "awning")
	t.fire_esc = Static(love.graphics.newImage(objs .. "fire_escape.png"), "fire_escape")
	t.chimney  = Static(love.graphics.newImage(objs .. "chimney.png"), "chimney")
	t.poop     = Static(love.graphics.newImage(objs .. "falling_poop.png"), "falling")
	t.title    = Static(love.graphics.newImage(gui .. "title.png"), "title")
	t.start    = Static(love.graphics.newImage(gui .. "start.png"), "start")
	t.quit     = Static(love.graphics.newImage(gui .. "quit.png"), "quit")
	t.restart  = Static(love.graphics.newImage(gui .. "restart.png"), "restart")
	
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
			Background(textures.bg.mountains,                                      size.full.x,                     -60, nil, nil, Vector(-1, 0)),
			Background(textures.bg.mountains,                                              nil,                     -60, nil, nil, Vector(-1, 0)),
			Background(textures.bg.city,                                           size.full.x,                     -35, nil, nil, Vector(-2, 0)),
			Background(textures.bg.city,                                                   nil,                     -35, nil, nil, Vector(-2, 0)),
			Background(textures.bg.sidewalk:random(), 0, size.full.y - textures.bg.sidewalk.h, nil, nil, Vector(-3, 0), "sidewalk"),
			Background(textures.bg.sidewalk:random(), textures.bg.sidewalk.w, size.full.y - textures.bg.sidewalk.h, nil, nil, Vector(-3, 0), "sidewalk"),
			Background(textures.bg.sidewalk:random(), textures.bg.sidewalk.w * 2, size.full.y - textures.bg.sidewalk.h, nil, nil, Vector(-3, 0), "sidewalk"),
			Background(textures.bg.sidewalk:random(), textures.bg.sidewalk.w * 3, size.full.y - textures.bg.sidewalk.h, nil, nil, Vector(-3, 0), "sidewalk"),
			Background(textures.bg.sidewalk:random(), textures.bg.sidewalk.w * 4, size.full.y - textures.bg.sidewalk.h, nil, nil, Vector(-3, 0), "sidewalk"),
			Background(textures.bg.sidewalk:random(), textures.bg.sidewalk.w * 5, size.full.y - textures.bg.sidewalk.h, nil, nil, Vector(-3, 0), "sidewalk")
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
			e     = Entity(Sprite(love.graphics.newImage("assets/sprites/bird.png"), 2, 2, "gliding"), 500, 260, nil, nil, nil, "dyn"),
			jump  = JUMP,
			move  = {
				speed = MOVE,
				max   = 8
			},
			score = 0,
			poops = {}
		}
		
		local w, h
		
		w = player.e.w * .75
		h = player.e.h * .75
		
		--tightening up the hitbox, tweak this to make the game easier :p
		player.e:setHitbox(500 + w / 5, 260 + h / 5, w, h)
	end
end

function updateObjectTable(tbl)
	for i = 1, #tbl, 1 do
		if tbl[i] == nil then break end
		
		tbl[i]:update(dt)
		
		if tbl == background_objects then
			local is_inb = tbl[i]:inb()

			if not is_inb and tbl[i].was_inb then
				tbl[i].x = tbl[i].x + size.full.x * 2
				tbl[i].hitbox.pos.x = tbl[i].x
				tbl[i].was_inb = false
			elseif is_inb then 
				tbl[i].was_inb = true
			end
		elseif tbl == loaded_objects then
			local is_inb = tbl[i]:collide(bounds.inner)

			if not is_inb and tbl[i].was_inb then
				tbl[i].x = tbl[i].x + size.full.x * 2
				tbl[i].hitbox.pos.x = tbl[i].x
				tbl[i].was_inb = false
			elseif is_inb then 
				tbl[i].was_inb = true
			end
		else
			if tbl[i]:oob() then table.remove(tbl, i) end
		end
	end
end

function drawObjectTable(tbl, speed)
	for i = 1, #tbl, 1 do
		tbl[i]:draw(speed)
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
