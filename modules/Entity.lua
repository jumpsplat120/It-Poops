local Object = require("third_party/classic")
local Vector = require("modules/Vector")
local Sprite = require("modules/Sprite")
local Static = require("modules/Static")

local Entity = Object:extend()

local GRAVITY = Vector(0, 120)

Entity:implement(Sprite)
Entity:implement(Static)

function Entity:new(img, x, y, w, h, vel, t)
	assert(img, "An image is required for an Entity.")
	assert(img.__type, "Image must be of type Static or Sprite.")
	
	local type_static, type_sprite = img:__type() == "static", img:__type() == "sprite"
	
	self._ = {}
	
	self._.raw_pos  = Vector(x or 0, y or 0)	
	self._.raw_size = Vector(w or img.w, h or img.h)
	self._.raw_vel  = Vector(vel or 0)
	self._.raw_acc  = Vector(0, 0)
	
	self.img  = img
	self.pos  = self._.raw_pos  * size.scale
	self.size = self._.raw_size * size.scale
	self.vel  = self._.raw_vel  * size.scale
	self.acc  = self._.raw_acc  * size.scale
	self.type = t or "env" --env or dyn
	
	return self
end

function Entity:get_x() return self.pos.x end
function Entity:get_y() return self.pos.y end
function Entity:get_w() return self.size.x end
function Entity:get_h() return self.size.y end
function Entity:get_speed() return self.vel.mag end

function Entity:draw(speed)
	local oh, ow --my bones
	
	ow = self._.raw_size.x / 2
	oh = self._.raw_size.y / 2
	
	if Sprite.is(self.img) then
		self.img:draw(speed, self.pos.x, self.pos.y, 0, size.scale.x, size.scale.y, ow, oh)
	elseif Static.is(self.img) then
		self.img:draw(self.pos.x, self.pos.y, 0, size.scale.x, size.scale.y, ow, oh)
	end
	
	return self
end

function Entity:update(dt)
	
	if self.type == "dyn" then
		self._.raw_acc:add(Vector(GRAVITY.x, GRAVITY.y * dt))
		self.acc:set(self._.raw_acc * size.scale)
		self._.raw_acc:set(0, 0)
	end
	
	self._.raw_vel:add(self.acc)
	self.vel:set(self._.raw_vel * size.scale)
	
	self._.raw_pos:add(self.vel)
	self.pos:set(self._.raw_pos * size.scale)
	
	return self
end

function Entity:accelerate(x, y)
	y = -y
	
	if type(x) == "number" then
		self._.raw_acc:add(Vector(x, y))
	else
		assert(x:__type() == "vector", "Must only add vectors.")
		self._.raw_acc:add(x)
	end

	self.acc:set(self._.raw_acc * size.scale)
	
	return self
end

function Entity:addVelocity(x, y)
	y = -y
		
	if type(x) == "number" then
		self._.raw_vel:add(Vector(x, y))
	else
		assert(x:__type() == "vector", "Must only add vectors.")
		self._.raw_vel:add(x)
	end

	self.vel:set(self._.raw_vel * size.scale)
	
	return self
end

function Entity:collide(o)
	local x, y, w, h
	
	x = self.pos.x
	y = self.pos.y
	w = self.size.x
	h = self.size.y

	return ((x < o.x + o.w) and (x + w > o.x) and (y < o.y + o.h) and (y + h > o.y))
end

function Entity:destroy()
	self = nil
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