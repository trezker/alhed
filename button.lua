Button = { }

function Button:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Button:init(rect, text, callback, cbobject)
	self.brect = rect
	self.text = text
	self.callback = callback
	self.cbobject = cbobject
end

function Button:event(event)
	if event.type == allegro5.mouse.EVENT_UP then
		if event.button == 1 then
			self.callback(self.cbobject)
		end
	end
end

function Button:render()
	allegro5.primitives.draw_filled_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgb(0, 255, 255))
	if self.image then
		self.image:draw_scaled(self.brect.x1, self.brect.y1, self.brect.x2 - self.brect.x1, self.brect.y2 - self.brect.y1, 0)
	end
	font:draw_text (self.brect.x1, self.brect.y1, 0, self.text)
end
