New_map_interface = { }

function New_map_interface:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function New_map_interface:init ()
	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	self.top_widget = Widget:new()
	self.top_widget:init(wrect)

	wrect = Rect:new ()
	wrect:init(400, 300, 464, 316)
	self.cancel = {}
	self.cancel.button = Button:new ()
	self.cancel.button:init(wrect, "Cancel", self.cancel_cb, self)
	self.cancel.widget = Widget:new()
	self.cancel.widget:init(wrect, self.cancel.button)
	self.top_widget:add_child(self.cancel.widget)
end

function New_map_interface:open ()
	gui_root:add_child(self.top_widget)
end

function New_map_interface:cancel_cb ()
	gui_root:remove_child(self.top_widget)
end
