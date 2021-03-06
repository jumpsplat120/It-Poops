local Object = require("third_party/classic")
local Vector = require("modules/Vector")
local Static = Object:extend()

function Static:new(img, name)
	assert(img, "An image is required for a Static.")
	
	self._ = {}
	
	self._.imgs = { }
	self._.imgs[name or "default"] = img
	
	self.img  = img
	self.size = Vector(img:getWidth(), img:getHeight())
	self.name = name

	return self
end

function Static:get_w() return self.size.x end
function Static:get_h() return self.size.y end

function Static:clone()	
	return deepCopy(self)
end

function Static:addImage(img, name)
	assert(img and name, "Name and img are required.")
	
	self._.imgs[name] = img
	
	return self
end

function Static:random()
	self:changeImage(love.math.random(#self._.imgs))
	
	return self
end

function Static:changeImage(name)
	local new_img = self._.imgs[name]

	assert(new_img, "No image found with name " .. name)
	self.img = new_img
	
	return self
end

function Static:draw(x, y, r, sx, sy, ox, oy)
	love.graphics.draw(self.img, x, y, r, sx, sy, ox, oy)
end

function Static:__type()
	return "static"
end

function Static.is(s)
	if type(s) == "table" then
		return s.__type and s:__type() == "static" or false
	else
		return false
	end	
end

return Static