Button = { }

function Button:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Button:init(rect, text, callback, cbobject, cbdata)
	self.brect = rect
	self.text = text
	self.callback = callback
	self.cbobject = cbobject
	self.cbdata = cbdata
end

function Button:event(event)
	if event.type == allegro5.mouse.EVENT_DOWN then
		if event.button == 1 then
			self.lmb = true
			subscribe_to_event (allegro5.mouse.EVENT_UP, self.event, self)
		end
	end
	if event.type == allegro5.mouse.EVENT_UP then
		if event.button == 1 and self.lmb == true then
			self.lmb = false
			unsubscribe_from_event (allegro5.mouse.EVENT_UP, self.event, self)
			if not (mouse_x < self.brect.x1 or mouse_x > self.brect.x2 or mouse_y < self.brect.y1 or mouse_y > self.brect.y2) then
				if self.cbobject then
					self.callback(self.cbobject, self.cbdata)
				else
					self.callback(self.cbdata)
				end
			end
		end
	end
end

function Button:render()
	allegro5.primitives.draw_filled_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgb(0, 255, 255))
	if self.image then
		self.image:draw_scaled(self.brect.x1, self.brect.y1, self.brect.x2 - self.brect.x1, self.brect.y2 - self.brect.y1, 0)
	end
	font:draw_text (self.brect.x1, self.brect.y1, 0, self.text)
	if self.lmb then
		allegro5.primitives.draw_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgba_f(0, 0, 0, 0.5), 2)
	else
		allegro5.primitives.draw_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgba_f(1, 1, 1, 0.5), 2)
	end
end
