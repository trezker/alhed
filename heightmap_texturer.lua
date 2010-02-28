Heightmap_texturer = { }

function Heightmap_texturer:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Heightmap_texturer:init(heightmap)
	self.heightmap = heightmap
	self.opacity = 1
	self.current_texture = 1
	self.radius = 10
end

function Heightmap_texturer:set_curve(curve)
	self.curve = curve
end

function Heightmap_texturer:event(event)
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
		if event.dz ~= 0 then
			self.opacity = self.opacity + event.dz/10
			if self.opacity < 0.1 then
				self.opacity = 0
			end
			if self.opacity > 1 then
				self.opacity = 1
			end
			print("Opacity: " .. self.opacity)
		end
	end
end

function Heightmap_texturer:update(dt)
	if self.lmb then
		alledge_lua.init_perspective_view(fov, width/height, near, far)
		oglpoint = camera:unproject(mouse_x, mouse_y)
		alledge_lua.pop_view()

		map_sx = self.heightmap:get_size_x()
		map_sz = self.heightmap:get_size_z()
		map_tilesize = self.heightmap:get_tilesize()
		
		scale_x = splat_texture:get_width() / (map_sx-1) * map_tilesize
		scale_z = splat_texture:get_height() / (map_sz-1) * map_tilesize

		splat_texture:set_target()
		paint_channel = allegro5.color.map_rgba_f(self.opacity, self.opacity, self.opacity, self.opacity)
		allegro5.color.map_rgba_f(1, 1, 1, 1):set_blender(allegro5.color.ONE, allegro5.color.ZERO)

		if self.current_texture == 1 then
			alledge_lua.gl.colormask(true, false, false, false);
		elseif self.current_texture == 2 then
			alledge_lua.gl.colormask(false, true, false, false);
		elseif self.current_texture == 3 then
			alledge_lua.gl.colormask(false, false, true, false);
		elseif self.current_texture == 4 then
			alledge_lua.gl.colormask(false, false, false, true);
		end
		allegro5.primitives.draw_filled_circle(oglpoint.x*scale_x, splat_texture:get_height()-oglpoint.z*scale_z, self.radius, paint_channel)

		alledge_lua.gl.colormask(true, true, true, true);
		display:set_current()
		allegro5.color.map_rgba_f(1, 1, 1, 1):set_blender(allegro5.color.ALPHA, allegro5.color.INVERSE_ALPHA)
	end
end
