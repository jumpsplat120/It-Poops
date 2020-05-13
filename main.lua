local textures, width, height, time, gdt, pull, GRAVITY, player, size

inspect = require("inspect")

function love.load()
	local path       = "assets/"
	local background = path .. "background/"
	local sprites    = path .. "sprites/"
	local static     = path .. "objects/"
	
	y, x, time, gdt, pull = 0, 0, 0, 0, 0
	
	size = {
		width = {
			full = 1920,
			half = 960
		},
		height = {
			full = 1080,
			half = 540
		}
	}
	
	local temp_imgs = {
		bird = love.graphics.newImage(sprites .. "bird.png"),
		tree = love.graphics.newImage(sprites .. "tree.png")
	}
	
	local bird, tree = {}, {}
	
	bird[1], bird[2], bird[3] = loadQuad(temp_imgs.bird, 2, 2)
	tree[1], tree[2], tree[3] = loadQuad(temp_imgs.tree, 1, 2)
	
	textures = {
		background = {
			skybox     = love.graphics.newImage(background .. "skybox.png"),
			mountains  = love.graphics.newImage(background .. "mountains.png"),
			clouds     = love.graphics.newImage(background .. "clouds.png"),
			cityscape  = love.graphics.newImage(background .. "cityscape.png"),
			foreground = love.graphics.newImage(background .. "level.png")
		},
		sprites = {
			bird = {temp_imgs.bird, bird[1], bird[2], bird[3], 1},
			tree = {temp_imgs.tree, tree[1], tree[2], tree[3], 1}
		},
		static = {
			balcony = love.graphics.newImage(static .. "balcony.png"),
			bench = love.graphics.newImage(static .. "bench.png"),
			awning = love.graphics.newImage(static .. "awning.png"),
			fire_escape = love.graphics.newImage(static .. "fire_escape.png"),
			chimney = love.graphics.newImage(static .. "chimney.png"),
			falling_poop = love.graphics.newImage(static .. "falling_poop.png"),
			fallen_poop = love.graphics.newImage(static .. "fallen_poop.png")
		}
	}

	size.width.window, size.height.window, _ = love.window.getMode()
	size.width.scale, size.height.scale = size.width.window / size.width.full, size.height.window / size.height.full
	
	player = {
		x = 500,
		y = size.height.window / 4,
		speed = 0,
		jump = -10,
		poops = {}
	}
	
	GRAVITY = 18 * size.height.scale
end

function love.update(dt)
	if love.keyboard.isDown("d") then
		player.speed = player.speed + (100 * dt)
	elseif love.keyboard.isDown("a") then
		player.speed = player.speed - (100 * dt)
	end

	player.speed = math.min(player.speed, 10)
	player.x = player.speed + player.x
	
	player.speed = player.speed - (10 * dt)
	player.speed = math.max(player.speed, -10)

	if player.y * size.height.scale > size.height.window - (50 * size.height.scale) then
		error("GAME OVER")
	elseif player.x * size.width.scale > size.width.window then
		error("GAME OVER")
	elseif player.x < 0 then
		error("GAME OVER")
	end

	pull = pull + dt * GRAVITY
	
	player.y = player.y + pull
	gdt = dt
	time = time + dt
end

function love.draw()
	local bg = textures.background
	local sp = textures.sprites
	local rw, rh, hh, hw, sw
	local clouds_pos, mount_pos, city_pos, level_pos
	
	rw = size.width.scale
	rh = size.height.scale
	hh = size.height.half
	hw = size.width.half

	sh = hh * rh
	sw = hw * rw
	
	clouds_pos = cycle(time * -25 * rw, -sw, sw)
	mount_pos  = cycle(time * -60 * rw, -sw, sw)
	city_pos   = cycle(time * -80 * rw, -sw, sw)
	level_pos  = cycle(time * -120 * rw, -sw * 3, sw * 3)
	
	drawBG(clouds_pos, mount_pos, city_pos, sw, rw, rh, hw, hh)
	drawCity(level_pos, sw, rw, sh, rh, hh)
	
	drawPoops()
	drawQuad(sp.bird, 4, player.x * rw, player.y * rh, 0, rw, rh)
end

function love.resize()
	size.width.window, size.height.window, _ = love.window.getMode()
	
	size.width.scale, size.height.scale = size.width.window / size.width.full, size.height.window / size.height.full
	
	GRAVITY = 18 * size.height.scale
end

function love.keypressed(k)
	if k == "space" then
		pull = player.jump * size.height.scale
	end
	
	if k == "e" then
		poop()
	end
end

function intersect(player, obj)
	--if player.pos + 100
end

function poop()
	player.poops[#player.poops + 1] = {player.x, player.y, time}
	print("Pooped at ", player.x, player.y)
end

function drawBG(clouds_pos, mount_pos, city_pos, sw, rw, rh, hw, hh)
	local bg = textures.background
	
	local vertical_adjust, y
	
	vertical_adjust = rh * - 75
	y = vertical_adjust + sh
	
	love.graphics.draw(bg.skybox,    0,                   0, 0, rw, rh)
	love.graphics.draw(bg.clouds,    clouds_pos,          y, 0, rw, rh, hw, hh)
	love.graphics.draw(bg.clouds,    clouds_pos + sw * 2, y, 0, rw, rh, hw, hh)
	love.graphics.draw(bg.mountains, mount_pos,           y, 0, rw, rh, hw, hh)
	love.graphics.draw(bg.mountains, mount_pos + sw * 2,  y, 0, rw, rh, hw, hh)
	love.graphics.draw(bg.cityscape, city_pos,            y, 0, rw, rh, hw, hh)
	love.graphics.draw(bg.cityscape, city_pos + sw * 2,   y, 0, rw, rh, hw, hh)
end

function drawCity(level_pos, sw, rw, sh, rh, hh)
	local sp, right_adjust, fgw, bg, st, ground_item
	
	bg = textures.background
	sp = textures.sprites
	st = textures.static
	fgw = bg.foreground:getWidth()
	right_adjust = fgw * rw
	
	local function ground_height(item_size)
		return size.height.window - ((item_size / 2) * rh) - (rh * 25)
	end
	
	love.graphics.draw(bg.foreground, level_pos, sh, 0, rw, rh, fgw / 2, hh)
	love.graphics.draw(bg.foreground, level_pos + right_adjust, sh, 0, rw, rh, fgw / 2, hh)
	
	drawQuad(sp.tree, 1, level_pos + (-2260 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	drawQuad(sp.tree, 1, level_pos + (-1260 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	drawQuad(sp.tree, 1, level_pos + (-500 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	drawQuad(sp.tree, 1, level_pos + (600 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	drawQuad(sp.tree, 1, level_pos + (1440 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	drawQuad(sp.tree, 1, level_pos + (2760 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	drawQuad(sp.tree, 1, level_pos + (3500 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	drawQuad(sp.tree, 1, level_pos + (4500 * rw), ground_height(sp.tree[4]), 0, rw, rh)
	
	love.graphics.draw(st.balcony, level_pos + (-2740 * rw), (300 * rh), 0, rw, rh)
	love.graphics.draw(st.balcony, level_pos + (960 * rw), (380 * rh), 0, rw, rh)
	love.graphics.draw(st.balcony, level_pos + (3020 * rw), (300 * rh), 0, rw, rh)
	
	love.graphics.draw(st.bench, level_pos + (1900 * rw), (880 * rh), 0, rw, rh)
	
	love.graphics.draw(st.awning, level_pos + (3920 * rw), (600 * rh), 0, rw, rh)
	love.graphics.draw(st.awning, level_pos + (-1840 * rw), (600 * rh), 0, rw, rh)
	love.graphics.draw(st.awning, level_pos + (-60 * rw), (620 * rh), 0, rw, rh)
	
	love.graphics.draw(st.fire_escape, level_pos + (1940 * rw), (220 * rh), 0, rw, rh)
	
	love.graphics.draw(st.chimney, level_pos + (-560 * rw), (100 * rh), 0, rw, rh)
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
		local x = (time - poop[3]) * -120 * rw

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

function loadQuad(image, rows, cols)
	local w, h = image:getWidth(), image:getHeight()
	local fw, fh = math.floor(w / cols), math.floor(h / rows)
	local frames = {}
	
	for i = 0, rows - 1, 1 do
		for j = 0, cols - 1, 1 do
			frames[#frames + 1] = love.graphics.newQuad(j * fw, i * fh, fw, fh, w, h)
		end
	end
	
	return frames, fw, fh
end

function drawQuad(tbl, spd, x, y, r, sx, sy, ox, oy)
	local image, quad, frame
	
	image = tbl[1]
	quad  = tbl[2]
	frame = math.floor(tbl[5]) > #quad and #quad or math.floor(tbl[5])

	love.graphics.draw(image, quad[frame], x, y, r, sx, sy, tbl[3] / 2, tbl[4] / 2) 
	
	tbl[5] = tbl[5] >= #quad + 1 and 1 + spd * gdt or tbl[5] + spd * gdt
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