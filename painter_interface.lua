create_painter_interface = function()
	heightmap_painter = Heightmap_painter:new ()
	heightmap_painter:init(heightmap)

	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	painter_widget = Widget:new()
	painter_widget:init(wrect, heightmap_painter)
	painter_widget:add_component(camera_controller)
	
	hue_bitmap = alledge_lua.bitmap.new()
	hue_bitmap:load("data/hue.png")

	sat_val_bitmap = alledge_lua.bitmap.new()
	sat_val_bitmap:load("data/sat_val_blend.png")
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
	wrect:init(100+sat_val_bitmap:get_width(), 0, 100+sat_val_bitmap:get_width() + hue_bitmap:get_width(), hue_bitmap:get_height())
	hue = Hue:new()
	hue:init(wrect, hue_bitmap)
	hue_widget = Widget:new()
	hue_widget:init(wrect, hue)
	painter_widget:add_child(hue_widget)

	
	wrect = Rect:new ()
	wrect:init(100, 0, 100 + sat_val_bitmap:get_width(), sat_val_bitmap:get_height())
	sat_val = Sat_val:new()
	sat_val:init(wrect, sat_val_bitmap)
	sat_val_widget = Widget:new()
	sat_val_widget:init(wrect, sat_val)
	painter_widget:add_child(sat_val_widget)

	wrect = Rect:new ()
	wrect:init(300, 0, 350, 50)
	color_field = Color_field:new()
	color_field:init(wrect)
	color_field_widget = Widget:new()
	color_field_widget:init(wrect, color_field)
	painter_widget:add_child(color_field_widget)


	wrect = Rect:new ()
	wrect:init(0, 50, 50, 70)
	radius_spinner = Spinner:new()
	radius_spinner:init(wrect, radius_spinner_callback)
	radius_spinner.value = 5
	radius_spinner_widget = Widget:new()
	radius_spinner_widget:init(wrect, radius_spinner)
	painter_widget:add_child(radius_spinner_widget)

	return painter_widget
end

radius_spinner_callback = function ()
	heightmap_painter.radius = radius_spinner.value
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

update_color = function()
	if hue.value == 1 then
		hue.value = 0
	end
	h = hue.value * 360
	s = sat_val.saturation
	v = sat_val.value

	r, g, b = hsv_to_rgb(h, s, v)

	heightmap_painter.red = r
	heightmap_painter.green = g
	heightmap_painter.blue = b
	
	color_field.color = allegro5.color.map_rgb_f(r, g, b)

--	print("RGB: " .. r .. ", " .. g .. ", " .. b)
end

Hue = { }

function Hue:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Hue:init(rect, image)
	self.brect = rect
	self.value = 0
	self.image = image
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
			update_color()
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

function Sat_val:init(rect, image)
	self.brect = rect
	self.saturation = 1
	self.value = 1
	self.image = image
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
			update_color()
		end
	end
end

function Sat_val:render()
	h = hue.value * 360
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
