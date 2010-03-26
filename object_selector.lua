Object_selector = { }

function Object_selector:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Object_selector:init(rect, objects, callback, cbobject)
	self.brect = rect
	self.objects = objects or {}
	self.callback = callback
	self.cbobject = cbobject
	self.selected_object = 0
end

function Object_selector:event(event)
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
			if self.brect:covers(mouse_x, mouse_y) then
				x = mouse_x - self.brect.x1
				vp_w = w / 5
				obj_n = x/vp_w
				self.selected_object = obj_n
				if self.cbobject then
					self.callback(self.cbobject, self.selected_object)
				else
					self.callback(self.selected_object)
				end
			end
		end
	end
end

function Object_selector:render()
	allegro5.primitives.draw_filled_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgb(0, 255, 255))

	w = self.brect.x2 - self.brect.x1
	h = self.brect.y2 - self.brect.y1

	vp_y = full_viewport.h - self.brect.y2
	vp_w = w / 5
	alledge_lua.init_perspective_view(fov, width/height, near, far)
	n = table.getn(self.objects)
--	print("Objects2: " .. table.getn(self.objects))
	for i = 1, 5 do
		if i>n then
--			print ("breaking on " .. i)
			break
		end
		alledge_lua.gl.set_viewport(self.brect.x1 + (i-1) * vp_w, vp_y, vp_w, h)
		temp_root = alledge_lua.scenenode.new()
		alledge_lua.scenenode.attach_node(temp_root, self.objects[i].interface_transform)
		temp_root:apply()
	end
	alledge_lua.gl.set_viewport(full_viewport.x, full_viewport.y, full_viewport.w, full_viewport.h)
	alledge_lua.pop_view()
--[[
	if self.lmb then
		allegro5.primitives.draw_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgba_f(0, 0, 0, 0.5), 2)
	else
		allegro5.primitives.draw_rectangle(self.brect.x1, self.brect.y1, self.brect.x2, self.brect.y2, allegro5.color.map_rgba_f(1, 1, 1, 0.5), 2)
	end
--]]
end
