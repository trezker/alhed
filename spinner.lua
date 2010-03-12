Spinner = { }

function Spinner:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Spinner:init(callback, cbobject)
	self.value = value
	self.callback = callback
	self.cbobject = cbobject
end

function Spinner:event(event)
	if event.type == allegro5.mouse.EVENT_AXES then
		if event.dz ~= 0 then
			self.value = self.value + event.dz
			if self.callback then
				self.callback(self.cbobject)
			end
		end
	end
end

function Spinner:render()
	allegro5.primitives.draw_filled_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgb(0, 255, 255))
	font:draw_text (self.brect.x1, self.brect.y1, 0, self.value)
end
