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

	wrect = Rect:new ()
	wrect:init(400, 284, 464, 300)
	self.create = {}
	self.create.button = Button:new ()
	self.create.button:init(wrect, "Create", self.create_cb, self)
	self.create.widget = Widget:new()
	self.create.widget:init(wrect, self.create.button)
	self.top_widget:add_child(self.create.widget)

	wrect = Rect:new ()
	wrect:init(300, 200, 364, 216)
	self.sizex_spinner = Spinner:new()
	self.sizex_spinner:init(wrect, self.sizex_spinner_callback, self)
	self.sizex_spinner.value = 10
	self.sizex_spinner_widget = Widget:new()
	self.sizex_spinner_widget:init(wrect, self.sizex_spinner)
	self.top_widget:add_child(self.sizex_spinner_widget)

	wrect = Rect:new ()
	wrect:init(300, 216, 364, 232)
	self.sizez_spinner = Spinner:new()
	self.sizez_spinner:init(wrect, self.sizez_spinner_callback, self)
	self.sizez_spinner.value = 10
	self.sizez_spinner_widget = Widget:new()
	self.sizez_spinner_widget:init(wrect, self.sizez_spinner)
	self.top_widget:add_child(self.sizez_spinner_widget)

end

function New_map_interface:open ()
	gui_root:add_child(self.top_widget)
end

function New_map_interface:cancel_cb ()
	gui_root:remove_child(self.top_widget)
end

function New_map_interface:create_cb ()
	new_heightmap ()
	texturer_interface:refresh_textures()
	gui_root:remove_child(self.top_widget)
end

function New_map_interface:sizex_spinner_callback ()
	if self.sizex_spinner.value > 1 then
		new_heightmap_settings.size_x = self.sizex_spinner.value
	else
		new_heightmap_settings.size_x = 2
		self.sizex_spinner.value = 2
	end
end

function New_map_interface:sizez_spinner_callback ()
	if self.sizez_spinner.value > 1 then
		new_heightmap_settings.size_z = self.sizez_spinner.value
	else
		new_heightmap_settings.size_z = 2
		self.sizez_spinner.value = 2
	end
end
