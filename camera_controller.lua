Camera_controller = { }

function Camera_controller:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Camera_controller:init(camera)
	self.camera = camera
end

function Camera_controller:event(event)
	if event.type == allegro5.mouse.EVENT_DOWN then
		if event.button == 3 then
			self.mmb = true
			subscribe_to_event (allegro5.mouse.EVENT_UP, self.event, self)
			subscribe_to_event (allegro5.mouse.EVENT_AXES, self.event, self)
		end
	end

	if event.type == allegro5.mouse.EVENT_UP then
		if event.button == 3 then
			self.mmb = false
			unsubscribe_from_event (allegro5.mouse.EVENT_UP, self.event, self)
			unsubscribe_from_event (allegro5.mouse.EVENT_AXES, self.event, self)
		end
	end

	if event.type == allegro5.mouse.EVENT_AXES then
		if self.mmb then
			if shift then
				pos = camera:get_position() + camera:get_up()*event.dy/10 - camera:get_right()*event.dx/10
				camera:set_position(pos)
			elseif ctrl then
				pos = camera:get_position() + camera:get_front()*event.dy/10
				camera:set_position(pos)
			else
				rot = camera:get_rotation() + alledge_lua.vector3.new(-event.dy, -event.dx, 0)
				camera:set_rotation(rot)
			end
		end
	end
end
