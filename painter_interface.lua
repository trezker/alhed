Painter_interface = { }

function Painter_interface:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Painter_interface:init ()
	self.heightmap_painter = Heightmap_painter:new ()
	self.heightmap_painter:init(heightmap)

	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	self.painter_widget = Widget:new()
	self.painter_widget:init(wrect, self.heightmap_painter)
	self.painter_widget:add_component(camera_controller)
	
	self.hue_bitmap = alledge_lua.bitmap.new()
	self.hue_bitmap:load("data/hue.png")

	self.sat_val_bitmap = alledge_lua.bitmap.new()
	self.sat_val_bitmap:load("data/sat_val_blend.png")
--[[
	sat_val_bitmap:set_target()
	for x = 0, sat_val_bitmap:get_width()-1 do
		for y = 0, sat_val_bitmap:get_height()-1 do
			r = x / (sat_val_bitmap:get_width()-1)
			g = r
			b = r
			ax = 1-x / (sat_val_bitmap:get_width()-1)
			ay = y / (sat_val_bitmap:get_height()-1)
			if ax > ay then
				a = ax
			else
				a = ay
			end
			allegro5.color.map_rgba_f(r, g, b, a):put_pixel(x, y)
		end
	end
	display:set_current()
	sat_val_bitmap:save("data/sat_val_blend.png")	
--]]
	wrect = Rect:new ()
	wrect:init(64+self.sat_val_bitmap:get_width(), 32, 64+self.sat_val_bitmap:get_width() + self.hue_bitmap:get_width(), 32+self.hue_bitmap:get_height())
	self.hue = Hue:new()
	self.hue:init(wrect, self.hue_bitmap, self.update_color, self)
	self.hue_widget = Widget:new()
	self.hue_widget:init(wrect, self.hue)
	self.painter_widget:add_child(self.hue_widget)

	
	wrect = Rect:new ()
	wrect:init(64, 32, 64 + self.sat_val_bitmap:get_width(), 32+self.sat_val_bitmap:get_height())
	self.sat_val = Sat_val:new()
	self.sat_val:init(wrect, self.sat_val_bitmap, self.update_color, self)
	self.sat_val_widget = Widget:new()
	self.sat_val_widget:init(wrect, self.sat_val)
	self.painter_widget:add_child(self.sat_val_widget)

	wrect = Rect:new ()
	wrect:init(300, 32, 350, 64)
	self.color_field = Color_field:new()
	self.color_field:init(wrect)
	self.color_field_widget = Widget:new()
	self.color_field_widget:init(wrect, self.color_field)
	self.painter_widget:add_child(self.color_field_widget)


	wrect = Rect:new ()
	wrect:init(0, 32, 64, 64)
	self.radius_spinner = Spinner:new()
	self.radius_spinner:init(wrect, self.radius_spinner_callback, self)
	self.radius_spinner.value = 5
	self.radius_spinner_widget = Widget:new()
	self.radius_spinner_widget:init(wrect, self.radius_spinner)
	self.painter_widget:add_child(self.radius_spinner_widget)

	return self.painter_widget
end

function Painter_interface:radius_spinner_callback ()
	self.heightmap_painter.radius = self.radius_spinner.value
end

hsv_to_rgb = function (h, s, v)
	if s == 0 then
		-- achromatic (grey)
		r = v
		g = v
		b = v
	end

	h = h/60;			-- sector 0 to 5
	i = math.floor( h );
	f = h - i;			-- factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );

	if i == 0 then
		r = v;
		g = t;
		b = p;
	elseif i == 1 then
		r = q;
		g = v;
		b = p;
	elseif i == 2 then
		r = p;
		g = v;
		b = t;
	elseif i == 3 then
		r = p;
		g = q;
		b = v;
	elseif i == 4 then
		r = t;
		g = p;
		b = v;
	else
		r = v;
		g = p;
		b = q;
	end
	return r, g, b
end

function Painter_interface:update_color ()
	if self.hue.value == 1 then
		self.hue.value = 0
	end
	self.sat_val.hue = self.hue.value

	h = self.hue.value * 360
	s = self.sat_val.saturation
	v = self.sat_val.value

	r, g, b = hsv_to_rgb(h, s, v)

	self.heightmap_painter.red = r
	self.heightmap_painter.green = g
	self.heightmap_painter.blue = b
	
	self.color_field.color = allegro5.color.map_rgb_f(r, g, b)

--	print("RGB: " .. r .. ", " .. g .. ", " .. b)
end

Hue = { }

function Hue:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Hue:init(rect, image, callback, cbobject)
	self.brect = rect
	self.value = 0
	self.image = image
	self.callback = callback
	self.cbobject = cbobject
end

function Hue:event(event)
	if event.type == allegro5.mouse.EVENT_DOWN then
		if event.button == 1 then
			self.lmb = true
			subscribe_to_event (allegro5.mouse.EVENT_UP, self.event, self)
		end
	end

	if event.type == allegro5.mouse.EVENT_UP then
		if event.button == 1 then
			self.lmb = false
			unsubscribe_from_event (allegro5.mouse.EVENT_UP, self.event, self)
		end
	end
	
	if event.type == allegro5.mouse.EVENT_AXES then
		if self.lmb then
			self.value = 1-(event.y - self.brect.y1) / (self.brect.y2-self.brect.y1)
			if self.value>1 then
				self.value = 1
			end
			if self.value<0 then
				self.value = 0
			end
			if self.callback then
				self.callback(self.cbobject)
			end
		end
	end
end

function Hue:render()
	self.image:draw_scaled(self.brect.x1, self.brect.y1, self.brect.x2 - self.brect.x1, self.brect.y2 - self.brect.y1, 0)
end


Sat_val = { }

function Sat_val:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Sat_val:init(rect, image, callback, cbobject)
	self.brect = rect
	self.hue = 0
	self.saturation = 1
	self.value = 1
	self.image = image
	self.callback = callback
	self.cbobject = cbobject
end

function Sat_val:event(event)
	if event.type == allegro5.mouse.EVENT_DOWN then
		if event.button == 1 then
			self.lmb = true
			subscribe_to_event (allegro5.mouse.EVENT_UP, self.event, self)
		end
	end

	if event.type == allegro5.mouse.EVENT_UP then
		if event.button == 1 then
			self.lmb = false
			unsubscribe_from_event (allegro5.mouse.EVENT_UP, self.event, self)
		end
	end
	
	if event.type == allegro5.mouse.EVENT_AXES then
		if self.lmb then
			self.saturation = 1-(event.y - self.brect.y1) / (self.brect.y2-self.brect.y1)
			if self.saturation>1 then
				self.saturation = 1
			end
			if self.saturation<0 then
				self.saturation = 0
			end
			self.value = (event.x - self.brect.x1) / (self.brect.x2-self.brect.x1)
			if self.value>1 then
				self.value = 1
			end
			if self.value<0 then
				self.value = 0
			end
			if self.callback then
				self.callback(self.cbobject)
			end
		end
	end
end

function Sat_val:render()
	h = self.hue * 360
	s = 1
	v = 1

	r, g, b = hsv_to_rgb(h, s, v)

	allegro5.primitives.draw_filled_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgb_f(r, g, b))
	self.image:draw_scaled(self.brect.x1, self.brect.y1, self.brect.x2 - self.brect.x1, self.brect.y2 - self.brect.y1, 0)
end

Color_field = { }

function Color_field:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Color_field:init(rect)
	self.brect = rect
	self.color = allegro5.color.map_rgb(255, 255, 255)
end

function Color_field:render()
	allegro5.primitives.draw_filled_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, self.color)
end
