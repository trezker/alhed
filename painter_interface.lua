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
	
	wrect = Rect:new ()
	wrect:init(100, 0, 100 + hue_bitmap:get_width(), hue_bitmap:get_height())
	hue = Hue:new()
	hue:init(wrect, hue_bitmap)
	hue_widget = Widget:new()
	hue_widget:init(wrect, hue)
	painter_widget:add_child(hue_widget)

	return painter_widget
end

update_color = function()
	print("Hue: " .. hue.value)
	if hue.value == 1 then
		hue.value = 0
	end
	h = hue.value * 360
	s = 1
	v = 1

	if s == 0 then
		-- achromatic (grey)
		heightmap_painter.red = v
		heightmap_painter.green = v
		heightmap_painter.blue = v
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

	heightmap_painter.red = r
	heightmap_painter.green = g
	heightmap_painter.blue = b

	print("RGB: " .. r .. ", " .. g .. ", " .. b)
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
