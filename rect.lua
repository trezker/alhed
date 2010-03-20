Rect = { }

function Rect:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Rect:init(x1, y1, x2, y2)
	if x1>x2 then x1, x2 = x2, x1 end
	if y1>y2 then y1, y2 = y2, y1 end
	self.x1 = x1
	self.y1 = y1
	self.x2 = x2
	self.y2 = y2
end

function Rect:covers(x, y)
	if not (x < self.x1 or x > self.x2 or y < self.y1 or y > self.y2) then
		return true
	end
	return false
end
