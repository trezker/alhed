Widget_vbox = { }

function Widget_vbox:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Widget_vbox:init(rect, object)
	self.brect = rect
	self.components = {}
	self.num_components = 0
	if object then
		self.components[object] = true
		self.num_components = 1
		object.brect = self.brect
	end
	self.children = {}
	self.current_y = self.brect.y1
end

function Widget_vbox:move(rect)
	self.brect.x1 = rect.x1
	self.brect.x2 = rect.x2
	self.brect.y1 = rect.y1
	self.brect.y2 = rect.y2

	self.current_y = self.brect.y1
	for i, widget in ipairs(self.children) do
		h = widget.brect.y2 - widget.brect.y1
		if widget.move then
			rect = Rect:new ()
			rect.y1 = self.current_y
			self.current_y = self.current_y + h
			rect.y2 = self.current_y
			rect.x1 = self.brect.x1
			rect.x2 = self.brect.x2
			widget:move(rect)
		else
			widget.brect.y1 = self.current_y
			self.current_y = self.current_y + h
			widget.brect.y2 = self.current_y
			widget.brect.x1 = self.brect.x1
			widget.brect.x2 = self.brect.x2
		end
	end
end

function Widget_vbox:add_component(object)
	if object then
		self.components[object] = true
		self.num_components = self.num_components + 1
		object.brect = self.brect
	end
end

function Widget_vbox:remove_component(object)
	if object then
		self.components[object] = nil
		self.num_components = self.num_components - 1
	end
end

function Widget_vbox:add_child(widget)
	table.insert(self.children, widget)
	--query widget height, place in order, resize width...
	h = widget.brect.y2 - widget.brect.y1
	if widget.move then
		rect = Rect:new ()
		rect.y1 = self.current_y
		self.current_y = self.current_y + h
		rect.y2 = self.current_y
		rect.x1 = self.brect.x1
		rect.x2 = self.brect.x2
		widget:move(rect)
	else
		widget.brect.y1 = self.current_y
		self.current_y = self.current_y + h
		widget.brect.y2 = self.current_y
		widget.brect.x1 = self.brect.x1
		widget.brect.x2 = self.brect.x2
	end
end

function Widget_vbox:remove_child(widget)
	--move up all children below the removed child
	ri = nil
	for i, v in ipairs(self.children) do
		if v == widget then
			ri = i
			rh = v.brect.y2 - v.brect.y1
		end
		if ri then
			v.brect.y1 = v.brect.y1 - rh
			v.brect.y2 = v.brect.y2 - rh
		end
	end
	table.remove(self.children, ri)
end

function Widget_vbox:event(event)
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

function Widget_vbox:render()
	for k, v in pairs(self.components) do
		if k.render then
			k:render()
		end
	end
	for i,v in ipairs(self.children) do
		v:render()
	end	
end
