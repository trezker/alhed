Objects_editor = { }

function Objects_editor:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Objects_editor:init()
	self.transform_node = alledge_lua.transformnode.new()
	self.transform_node:set_position(alledge_lua.vector3.new(0, 0, 0))
	alledge_lua.scenenode.attach_node(heightmap, self.transform_node);
end

function Objects_editor:set_object(object)
	if self.current_object then
		alledge_lua.scenenode.detach_node(self.transform_node, master_objects[self.current_object].model_node)
	end
	self.current_object = object
	if object then
		alledge_lua.scenenode.attach_node(self.transform_node, master_objects[self.current_object].model_node)
	end
end

function Objects_editor:event(event)
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
	end
end

function Objects_editor:update(dt)
	alledge_lua.init_perspective_view(fov, width/height, near, far)
	oglpoint = camera:unproject(mouse_x, mouse_y)
	alledge_lua.pop_view()
	y = heightmap:get_height(oglpoint.x, oglpoint.z)
	self.transform_node:set_position(alledge_lua.vector3.new(oglpoint.x, y, oglpoint.z))

	if self.lmb then
		map_size_x = heightmap:get_size_x()
		map_size_z = heightmap:get_size_z()
		map_tilesize = heightmap:get_tilesize()
	end
end
