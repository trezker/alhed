dofile('widget_vbox.lua')
dofile('widget_hbox.lua')

mouse_x = 0
mouse_y = 0

Widget = { }

function Widget:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Widget:init(rect, object)
	self.brect = rect
	self.components = {}
	self.num_components = 0
	if object then
		self.components[object] = true
		self.num_components = 1
		object.brect = self.brect
	end
	self.children_lit = {}  --Last in top, for event passing in overlapping objects
	self.children_lib = {}	--Last in bottom, for rendering bottom to top
end

function Widget:add_component(object)
	if object then
		self.components[object] = true
		self.num_components = self.num_components + 1
		object.brect = self.brect
	end
end

function Widget:remove_component(object)
	if object then
		self.components[object] = nil
		self.num_components = self.num_components - 1
	end
end

function Widget:add_child(widget)
	table.insert(self.children_lit, 1, widget)
	table.insert(self.children_lib, widget)
end

function Widget:remove_child(widget)
	for i, v in ipairs(self.children_lit) do
		if v == widget then
			table.remove(self.children_lit, i)
			break
		end
	end
	for i, v in ipairs(self.children_lib) do
		if v == widget then
			table.remove(self.children_lib, i)
			break
		end
	end
end

function Widget:event(event)
	for i,v in ipairs(self.children_lit) do
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

function Widget:render()
	for k, v in pairs(self.components) do
		if k.render then
			k:render()
		end
	end
	for i,v in ipairs(self.children_lib) do
		v:render()
	end	
end
