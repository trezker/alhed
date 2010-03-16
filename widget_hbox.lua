Widget_hbox = { }

function Widget_hbox:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Widget_hbox:init(rect, object)
	self.brect = rect
	self.components = {}
	self.num_components = 0
	if object then
		self.components[object] = true
		self.num_components = 1
		object.brect = self.brect
	end
	self.children = {}
	self.current_x = self.brect.x1
end

function Widget_hbox:add_component(object)
	if object then
		self.components[object] = true
		self.num_components = self.num_components + 1
		object.brect = self.brect
	end
end

function Widget_hbox:remove_component(object)
	if object then
		self.components[object] = nil
		self.num_components = self.num_components - 1
	end
end

function Widget_hbox:add_child(widget)
	table.insert(self.children, widget)
	--query widget width, place in order, resize height...
	w = widget.brect.x2 - widget.brect.x1
	if widget.move then
		rect = Rect:new ()
		rect.x1 = self.current_x
		self.current_x = self.current_x + w
		rect.x2 = self.current_x
		rect.y1 = self.brect.y1
		rect.y2 = self.brect.y2
		widget:move(rect)
	else
		widget.brect.x1 = self.current_x
		self.current_x = self.current_x + w
		widget.brect.x2 = self.current_x
		widget.brect.y1 = self.brect.y1
		widget.brect.y2 = self.brect.y2
	end
end

function Widget_hbox:remove_child(widget)
	--move up all children below the removed child
	ri = nil
	for i, v in ipairs(self.children) do
		if v == widget then
			ri = i
			rw = v.brect.x2 - v.brect.x1
		end
		if ri then
			v.brect.x1 = v.brect.x1 - rw
			v.brect.x2 = v.brect.x2 - rw
		end
	end
	table.remove(self.children, ri)
end

function Widget_hbox:event(event)
	for i,v in ipairs(self.children) do
		if not (mouse_x < v.brect.x1 or mouse_x > v.brect.x2 or mouse_y < v.brect.y1 or mouse_y > v.brect.y2) then
			if v:event(event) then
				return true
			end
		end
	end

	if self.num_components == 0 then
		return false
	end
	for k, v in pairs(self.components) do
		k:event(event)
	end
	return true
end

function Widget_hbox:render()
	for k, v in pairs(self.components) do
		if k.render then
			k:render()
		end
	end
	for i,v in ipairs(self.children) do
		v:render()
	end	
end
