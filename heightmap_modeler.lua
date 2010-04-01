Heightmap_modeler = { }

function Heightmap_modeler:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Heightmap_modeler:init()
	self.curve = {-1, -.7, 0, .3, 0}
	self.radius = 10
	self.update_objects_timer = 0
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
			
			for k, v in pairs(objects) do
				pos = v.node:get_position()
				y = heightmap:get_height(pos.x, pos.z)
				v.node:set_position(alledge_lua.vector3.new(pos.x, y, pos.z))
			end
		end
	end
end

function Heightmap_modeler:update(dt)
	if self.lmb then
		alledge_lua.init_perspective_view(fov, width/height, near, far)
		oglpoint = camera:unproject(mouse_x, mouse_y)
		alledge_lua.pop_view()

		heightmap:apply_brush(oglpoint.x, oglpoint.z, self.radius, 1*dt, 5, self.curve);
		
		self.update_objects_timer = self.update_objects_timer + dt
		if self.update_objects_timer > 1 then
			self.update_objects_timer = 0
			for k, v in pairs(objects) do
				pos = v.node:get_position()
				y = heightmap:get_height(pos.x, pos.z)
				v.node:set_position(alledge_lua.vector3.new(pos.x, y, pos.z))
			end
		end
	end
end
