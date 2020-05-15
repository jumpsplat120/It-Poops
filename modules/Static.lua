local Object = require("third_party/classic")
local Vector = require("modules/Vector")
local Static = Object:extend()

function Static:new(img, name)
	assert(img, "An image is required for a Static.")
	
	self._ = {}
	
	self._.raw_size = Vector(img:getWidth(), img:getHeight())
	
	self._.imgs = { }
	self._.imgs[name or "default"] = img
	
	self.img  = img
	self.size = self._.raw_size * size.scale
	self.name = name

	return self
end

function Static:get_w() return self.size.x end
function Static:get_h() return self.size.y end

function Static:addImage(img, name)
	assert(img and name, "Name and img are required.")
	
	self._.imgs[name] = img
	
	return self
end

function Static:changeImage(name)
	local new_img = self._.imgs[name]
	
	assert(new_image, "No image found with name " .. name)
	
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
	if s.__type then
		return s:__type() == "static"
	else
		return false
	end
end

return Static