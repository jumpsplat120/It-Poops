local Object = require("third_party/classic")
local Vector = Object:extend()

local function recalculate(v)
	v.mag = math.sqrt(v.x ^ 2 + v.y ^ 2)
end

function Vector:new(x, y)
	local v
	
	if not (x and y) then v = Vector.Random() end

	self.x = x or v.x
	self.y = y or v.y

	self.mag = math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vector.fromAngle(deg)
	return Vector(math.cos(deg), -math.sin(deg))
end

function Vector.Random()
  return Vector.fromAngle(love.math.random() * math.pi * 2)
end

function Vector.is(v)
	if type(v) == "table" then
		return v.__type and v:__type() == "vector" or false
	else
		return false
	end	
end

function Vector:inRect(x, y, w, h)
	return self.x >= x and self.x <= x + w and self.y >= y and self.y <= y + h
end

function Vector:add(b)
	if type(b) == "number" then
		self.x = self.x + b
		self.y = self.y + b
	elseif Vector.is(b) then
		self.x = self.x + b.x
		self.y = self.y + b.y
	else
		error("Can't add.")
	end
	
	recalculate(self)
	
	return self
end

function Vector:sub(b)
	if type(b) == "number" then
		self.x = self.x - b
		self.y = self.y - b
	elseif Vector.is(b) then
		self.x = self.x - b.x
		self.y = self.y - b.y
	else
		error("Can't add.")
	end
	
	recalculate(self)
	
	return self
end

function Vector:mult(b)
	if type(b) == "number" then
		self.x = self.x * b
		self.y = self.y * b
	elseif Vector.is(b) then
		self.x = self.x * b.x
		self.y = self.y * b.y
	else
		error("Can't add.")
	end
	
	recalculate(self)
	
	return self
end

function Vector:div(b)
	if type(b) == "number" then
		self.x = self.x / b
		self.y = self.y / b
	elseif Vector.is(b) then
		self.x = self.x / b.x
		self.y = self.y / b.y
	else
		error("Can't add.")
	end
	
	recalculate(self)
	
	return self
end

function Vector:set(x, y)
	if Vector.is(x) then 
		self.x = x.x
		self.y = x.y
	else
		self.x = x or self.x
		self.y = y or self.y
	end
	
	recalculate(self)
	
	return self
end

function Vector:replace(v)
	assert(Vector.is(v), "Not a vector.")
	
	self.x, self.y = v.x, v.y
	
	recalculate(self)
	
	return self
end

function Vector:clone()
  return Vector(self.x, self.y)
end

function Vector:getMag()
	return self.mag
end

function Vector:magSq()
	return self.mag ^ 2
end

function Vector:setMag(mag)
  self:normalize()
  
  self:mult(mag)
  
  recalculate(self)
  
  return self
end

function Vector:__unm()
	self.x = -self.x
	self.y = -self.y
	
	return self
end

function Vector:__add(b)
	local v = Vector(0, 0)
	
	if type(b) == "number" then b = {x = b, y = b} end
	
	v.x = self.x + b.x
	v.y = self.y + b.y
	
	return v
end

function Vector:__sub(b)
	local v = Vector(0, 0)
	
	if type(b) == "number" then b = {x = b, y = b} end
	if type(b) == "number" then b = {x = b, y = b} end
	v.x = self.x - b.x
	v.y = self.y - b.y
	
	return v
end

function Vector:__mul(b)
	local v = Vector(0, 0)
	
	if type(b) == "number" then b = {x = b, y = b} end
	
	v.x = self.x * b.x
	v.y = self.y * b.y
	
	return v
end

function Vector:__div(b)
	local v = Vector(0, 0)
	
	if type(b) == "number" then b = {x = b, y = b} end
	
	v.x = self.x / b.x
	v.y = self.y / b.y
	
	return v
end

function Vector:__eq(b)
	assert(Vector.is(b), "Unable to check equality.")
  
	return self.x == b.x and self.y == b.y
end

function Vector:__tostring()
	return "<"..self.x..", "..self.y..">"
end

function Vector:distance(b)
	return math.sqrt((self.x - b.x) ^ 2 + (self.y - b.y) ^ 2)
end

function Vector:dot(b)
	assert(Vector.is(b), "Unable to dot product.")
	
	return self.x * b.x + self.y * b.y
end

function Vector:normalize()
	local mag = self.mag
	
	if mag ~= 0 then self:replace(self:div(mag)) end
	
	recalculate(self)
	
	return self
end

function Vector:maxMag(max)
	local mag = self.mag
  
	if mag > max then self:setMag(max) end
	
	recalculate(self)
	
	return self
end

function Vector:minMag(min)
	local mag = self.mag
  
	if mag < min then self:setMag(min) end
	
	recalculate(self)
	
	return self
end

function Vector:clampMag(min, max)
	self:maxMag(max):minMag(min)
	
	return self
end

function Vector:clampAxis(min, max)

	self.x = math.min( math.max( self.x, min.x ), max.x )
	self.y = math.min( math.max( self.y, min.y ), max.y )
	
	recalculate(self)
	
	return self
end

function Vector:getAngle()
  return -math.atan2(self.y, self.x)
end

function Vector:rotate(deg)
	local mag = self.mag
  
	self:replace(Vector.fromAngle(self:getAngle() + deg))
	
	self:setmag(mag)
	
	recalculate(self)
	
	return self
end

function Vector:getArray()
	return {self.x, self.y}
end

function Vector:unpack()
	return self.x, self.y
end

function Vector:__type()
	return "vector"
end

return Vector