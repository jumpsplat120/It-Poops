local Object = require("third_party/classic")
local Vector = require("modules/Vector")
local Sprite = require("modules/Sprite")
local Static = require("modules/Static")

local Entity = Object:extend()

local GRAVITY = Vector(0, .5)

Entity:implement(Sprite)
Entity:implement(Static)

function Entity:new(img, x, y, w, h, vel, t)
	assert(img, "An image is required for an Entity.")
	assert(img.__type, "Image must be of type Static or Sprite.")
	
	local type_static, type_sprite = img:__type() == "static", img:__type() == "sprite"
	
	self._ = {}
	
	self.pos    = Vector(x or 0, y or 0)
	self.size   = Vector(w or img.w, h or img.h)
	self.hitbox = {pos = self.pos:clone(), size = self.size:clone() }
	self.vel    = vel or Vector(0, 0)
	self.acc    = Vector(0, 0)

	self.img  = img:clone()
	self.type = t or "env" --env or dyn
	
	self.was_inb = inb ~= nil and inb or false
end

function Entity:get_x() return self.pos.x end
function Entity:get_y() return self.pos.y end
function Entity:get_w() return self.size.x end
function Entity:get_h() return self.size.y end
function Entity:get_speed() return self.vel.mag end

function Entity:set_x(val) self.pos.x = val end
function Entity:set_y(val) self.pos.y = val end
function Entity:set_w(val) self.size.x = val end
function Entity:set_h(val) self.size.y = val end
function Entity:set_speed(val) self.vel:setMag(val) end

function Entity:setHitbox(x, y, w, h)
	self.hitbox.pos:set(x, y)
	self.hitbox.size:set(w, h)
	
	return self
end

function Entity:drawHitbox(r, g, b)
	love.graphics.push("all")
		love.graphics.setColor(r, g, b, 1)
		love.graphics.rectangle("line", self.hitbox.pos.x, self.hitbox.pos.y, self.hitbox.size.x, self.hitbox.size.y)
	love.graphics.pop()
end

function Entity:draw(speed)
	if Sprite.is(self.img) then
		self.img:draw(speed, self.pos.x, self.pos.y)
	elseif Static.is(self.img) then
		self.img:draw(self.pos.x, self.pos.y)
	end
	
	return self
end

function Entity:update(dt)
	if self.type == "dyn" then
		self.acc:add(GRAVITY)
	end
	
	self.vel:add(self.acc)
	self.pos:add(self.vel)
	self.hitbox.pos:add(self.vel)
	self.acc:set(0, 0)
	
	return self
end

function Entity:accelerate(x, y)
	y = -y

	if type(x) == "number" then
		self.acc:add(Vector(x, y))
	else
		assert(x:__type() == "vector", "Must only add vectors.")
		self.acc:add(x)
	end
	
	return self
end

function Entity:impulse(x, y)
	y = -y
		
	if type(x) == "number" then
		self.vel:add(Vector(x, y))
	else
		assert(x:__type() == "vector", "Must only add vectors.")
		self.vel:add(x)
	end
	
	return self
end

function Entity:collide(o)
	local x1, y1, w1, h1
	local x2, y2, w2, h2
	
	w1 = self.hitbox.size.x
	h1 = self.hitbox.size.y
	x1 = self.hitbox.pos.x
	y1 = self.hitbox.pos.y
	
	w2 = o.hitbox.size.x
	h2 = o.hitbox.size.y
	x2 = o.hitbox.pos.x
	y2 = o.hitbox.pos.y
	
	return ((x1 < x2 + w2) and (x1 + w1 > x2) and (y1 < y2 + h2) and (y1 + h1 > y2))
end

function Entity:oob()
	return self:collide(bounds.bottom) or self:collide(bounds.left) or self:collide(bounds.right)
end

function Entity.is(e)
	if type(e) == "table" then
		return e.__type and e:__type() == "entity" or false
	else
		return false
	end
end

function Entity:__type()
	return "entity"
end

return Entity