Heightmap_modeler = { }

function Heightmap_modeler:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Heightmap_modeler:init(heightmap)
	self.heightmap = heightmap
	self.curve = {-1, -.7, 0, .3, 0}
end

function Heightmap_modeler:set_curve(curve)
	self.curve = curve
end

function Heightmap_modeler:event(event)
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

function Heightmap_modeler:update(dt)
	if self.lmb then
		alledge_lua.init_perspective_view(fov, width/height, near, far)
		oglpoint = camera:unproject(mouse_x, mouse_y)
		alledge_lua.pop_view()

		heightmap:apply_brush(oglpoint.x, oglpoint.z, 10, 1*dt, 5, self.curve);
	end
end
