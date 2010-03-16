Label = { }

function Label:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Label:init(rect, text)
	self.brect = rect
	self.text = text
end

function Label:render()
	font:draw_text (self.brect.x1, self.brect.y1, 0, self.text)
end
