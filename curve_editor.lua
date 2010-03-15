Curve_editor = { }

function Curve_editor:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Curve_editor:init(rect)
	self.brect = rect
	self.curve = {-1, -.7, 0, .3, 0}
	self.selected = 1
end

function Curve_editor:event(event)
	if event.type == allegro5.mouse.EVENT_UP then
		if event.button == 1 then
			width = self.brect.x2 - self.brect.x1
			num_points = table.maxn (self.curve)
			spacing = width / (num_points-1)

			selected = 1+math.floor((event.x - self.brect.x1 + spacing/2) / spacing)
			if selected ~= self.selected then
				self.selected = selected
			else
				height = self.brect.y2 - self.brect.y1
				mid = self.brect.y1 + height/2
				self.curve[self.selected] = (mid - event.y) / (height/2)
			end
		end
	end
end

function Curve_editor:render()
	allegro5.primitives.draw_filled_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgb(0, 255, 255))
	height = self.brect.y2 - self.brect.y1
	width = self.brect.x2 - self.brect.x1
	num_points = table.maxn (self.curve)
	spacing = width / (num_points-1)
	color = allegro5.color.map_rgb(0, 0, 255)
	zero_color = allegro5.color.map_rgb(255, 0, 0)
	for i = 1, num_points-1 do
		x1 = self.brect.x1 + (i-1) * spacing
		x2 = self.brect.x1 + (i) * spacing
		y1 = self.brect.y1 + height/2 - height/2 * self.curve[i]
		y2 = self.brect.y1 + height/2 - height/2 * self.curve[i+1]
		allegro5.primitives.draw_line(x1, y1, x2, y2, color, 1)
	end
	allegro5.primitives.draw_line(self.brect.x1, self.brect.y1+height/2, self.brect.x2, self.brect.y1+height/2, zero_color, 1)
	if self.selected then
		x1 = self.brect.x1 + (self.selected-1) * spacing
		y1 = self.brect.y1 + height/2 - height/2 * self.curve[self.selected]
		allegro5.primitives.draw_circle(x1, y1, 3, zero_color, 1)
	end
end
