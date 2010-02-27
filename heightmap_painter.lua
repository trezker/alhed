Heightmap_painter = { }

function Heightmap_painter:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Heightmap_painter:init(heightmap)
	self.heightmap = heightmap

	self.red = 1
	self.green = 1
	self.blue = 1
	self.radius = 5
end

function Heightmap_painter:event(event)
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
end

function Heightmap_painter:update(dt)
	if self.lmb then
		alledge_lua.init_perspective_view(fov, width/height, near, far)
		oglpoint = camera:unproject(mouse_x, mouse_y)
		alledge_lua.pop_view()

		self.heightmap:color_filled_circle(oglpoint.x, oglpoint.z, self.radius, allegro5.color.map_rgb_f(self.red, self.green, self.blue))
	end
end
