New_map_interface = { }

function New_map_interface:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function New_map_interface:init ()
	wrect = Rect:new ()
	wrect:init(0, 0, 64, 16)
	self.cancel = {}
	self.cancel.button = Button:new ()
	self.cancel.button:init(wrect, "Cancel", self.cancel_cb, self)

	wrect = Rect:new ()
	wrect:init(400, 284, 464, 300)
	self.create = {}
	self.create.button = Button:new ()
	self.create.button:init(wrect, "Create", self.create_cb, self)

	wrect = Rect:new ()
	wrect:init(300, 200, 364, 216)
	self.sizex_spinner = Spinner:new()
	self.sizex_spinner:init(wrect, self.sizex_spinner_callback, self)
	self.sizex_spinner.value = 10

	wrect = Rect:new ()
	wrect:init(300, 216, 364, 232)
	self.sizez_spinner = Spinner:new()
	self.sizez_spinner:init(wrect, self.sizez_spinner_callback, self)
	self.sizez_spinner.value = 10

	wrect = Rect:new ()
	wrect:init(300, 232, 364, 248)
	self.tilesize_spinner = Spinner:new()
	self.tilesize_spinner:init(wrect, self.tilesize_spinner_callback, self)
	self.tilesize_spinner.value = 10

	self.sizex = {}
	wrect = Rect:new ()
	wrect:init(0, 0, 64, 16)
	self.sizex.label = Label:new ()
	self.sizex.label:init(wrect, "Size x")


	--Layout
	wrect = Rect:new ()
	wrect:init(width/2-100, height/2-50, width/2+100, height/2+50)
	self.top_widget = Widget_hbox:new()
	self.top_widget:init(wrect)

	wrect = Rect:new ()
	wrect:init(0, 0, 100, 100)
	self.labels_box = Widget_vbox:new()
	self.labels_box:init(wrect)

	wrect = Rect:new ()
	wrect:init(0, 0, 100, 100)
	self.controls_box = Widget_vbox:new()
	self.controls_box:init(wrect)

	self.top_widget:add_child(self.labels_box)
	self.top_widget:add_child(self.controls_box)

	self.controls_box:add_child(self.sizex_spinner)
	self.controls_box:add_child(self.sizez_spinner)
	self.controls_box:add_child(self.tilesize_spinner)
	self.labels_box:add_child(self.create.button)
	self.labels_box:add_child(self.cancel.button)
	
	print(self.labels_box.brect.y1)
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

function New_map_interface:tilesize_spinner_callback ()
	if self.tilesize_spinner.value > 0 then
		new_heightmap_settings.tilesize = self.tilesize_spinner.value
	else
		new_heightmap_settings.tilesize = 1
		self.tilesize_spinner.value = 1
	end
end
