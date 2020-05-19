local Object = require("third_party/classic")
local Entity = require("modules/Entity")

local Background = Entity:extend()

function Background:new(img, x, y, w, h, vel, name, inb)

	Background.super.new(self, img, x, y, w, h, vel)

	self.name = name
end

function Background:get_x() return self.pos.x end
function Background:get_y() return self.pos.y end
function Background:get_w() return self.size.x end
function Background:get_h() return self.size.y end
function Background:get_speed() return self.vel.mag end

function Background:set_x(val) self.pos.x = val end
function Background:set_y(val) self.pos.y = val end
function Background:set_w(val) self.size.x = val end
function Background:set_h(val) self.size.y = val end
function Background:set_speed(val) self.vel:setMag(val) end

function Background:inb()
	return self:collide(bounds.inner)
end

return Background