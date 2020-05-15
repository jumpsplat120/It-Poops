local Object = require("third_party/classic")
local Sprite = Object:extend()

function Sprite:new(img, rows, cols, name)
	local frame_width, frame_height, t, w, h
	
	w   = img:getWidth()
	h   = img:getHeight()
	
	self.img = img
	
	self.w  = math.floor(w / cols)
	self.h = math.floor(h / rows)
	
	self._ = {}
	self._.animations  = {}
	self._.curr_anim   = name
	self._.frames      = {}
	self._.frame_index = 1
	
	rows = rows - 1
	cols = cols - 1
	
	t = {}
	
	for i = 0, rows, 1 do
		for j = 0, cols, 1 do
			self._.frames[#self._.frames + 1] = love.graphics.newQuad(j * self.w, i * self.h, self.w, self.h, w, h)
			t[#t + 1] = love.graphics.newQuad(j * self.w, i * self.h, self.w, self.h, w, h)
		end
	end
	
	self.frame              = self._.frames[self._.frame_index]
	self._.animations[name] = t
	self._.frame_max        = #self._.frames
	
	return self
end

function Sprite:addAnimation(img, rows, cols, name)
	local frame_width, frame_height, w, h, t
	
	w = img:getWidth()
	h = img:getHeight()
	
	frame_width  = math.floor(w / cols)
	frame_height = math.floor(h / rows)
	
	rows = rows - 1
	cols = cols - 1
	
	t = {}
	
	for i = 0, rows, 1 do
		for j = 0, cols, 1 do
			t[#t + 1] = love.graphics.newQuad(j * frame_width, i * frame_height, frame_width, frame_height, w, h)
		end
	end
	
	self._.animations[name] = t
	
	return self
end

function Sprite:setAnimation(name)
	if self._.curr_anim ~= name then
		local new_anim = self._.animations[name]
		
		assert(new_anim, "No animation found by the name of " .. name)
		
		self._.curr_anim   = name
		self._.frames      = new_anim
		self._.frame_index = 1
		self._.frame_max   = #self._.frames
	end
end

function Sprite:draw(speed, x, y, r, sx, sy, ox, oy)
	love.graphics.draw(self.img, self.frame, x, y, r, xs, sy, ox, oy)
	
	self._.frames_index = self._.frames_index + speed >= self._.frame_max and 1 + speed or self._.frames_index + speed
	self._.frame        = self._.frames[math.floor(self._.frames_index) > self._.frame_max and self._.frame_max or math.floor(self._.frames_index)]
end

function Sprite.is(s)
	if s.__type then
		return s:__type() == "sprite"
	else
		return false
	end	
end

function Sprite:__type()
	return "sprite"
end

return Sprite
