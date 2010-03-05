Texturer_interface = { }

function Texturer_interface:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Texturer_interface:init ()
	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	self.top_widget = Widget:new()
	self.top_widget:init(wrect)


	self.heightmap_texturer = Heightmap_texturer:new ()
	self.heightmap_texturer:init(heightmap)

	wrect = Rect:new ()
	wrect:init(0, 128, width, height)
	self.texturer_widget = Widget:new()
	self.texturer_widget:init(wrect, self.heightmap_texturer)
	self.texturer_widget:add_component(camera_controller)
	self.top_widget:add_child(self.texturer_widget)

	self.current_texture = 1

	wrect = Rect:new ()
	wrect:init(0, 32, 64, 64)
	self.load_texture_button = Button:new ()
	self.load_texture_button:init(wrect, "Load", self.load_texture, self)
	self.load_texture_widget = Widget:new()
	self.load_texture_widget:init(wrect, self.load_texture_button)
	self.top_widget:add_child(self.load_texture_widget)

	self.texture_selectors = {}
	for i = 1, 4 do
		wrect = Rect:new ()
		wrect:init(i*64, 0, i*64+64, 64)
		self.texture_selectors[i] = {}
		self.texture_selectors[i].button = Button:new ()
		self.texture_selectors[i].button:init(wrect, "", self.select_texture, self, i)
		self.texture_selectors[i].button.image = textures[i]
		self.texture_selectors[i].widget = Widget:new()
		self.texture_selectors[i].widget:init(wrect, self.texture_selectors[i].button)
		self.top_widget:add_child(self.texture_selectors[i].widget)
	end
	self.texture_selectors[1].button.text = "Active"

	wrect = Rect:new ()
	wrect:init(0, 70, 50, 90)
	self.radius_spinner = Spinner:new()
	self.radius_spinner:init(wrect, self.radius_spinner_callback, self)
	self.radius_spinner.value = 10
	self.radius_spinner_widget = Widget:new()
	self.radius_spinner_widget:init(wrect, self.radius_spinner)
	self.top_widget:add_child(self.radius_spinner_widget)

	return self.top_widget
end

function Texturer_interface:radius_spinner_callback ()
	self.heightmap_texturer.radius = self.radius_spinner.value
end

function Texturer_interface:refresh_textures()
	print("Refreshing textures")
	for t = 1, 4 do
		textures[t] = heightmap:get_texture(t-1);
		print(textures[t])
		self.texture_selectors[t].button.image = textures[t]
	end
end

function Texturer_interface:load_texture ()
	print("visible dialog")
	native_dialog = allegro5.native_dialog.create ("", "test", "*.*", allegro5.native_dialog.FILECHOOSER_FILE_MUST_EXIST)
	native_dialog:show()
	n = native_dialog:get_count()
	if n>0 then
		path = native_dialog:get_path(0)
		print("Path: " .. path)
		textures[self.current_texture] = alledge_lua.bitmap.new()
		textures[self.current_texture]:load(path);
		heightmap:set_texture(textures[self.current_texture], self.current_texture-1);
		heightmap:set_texture_filename(path, self.current_texture-1);
		self.texture_selectors[self.current_texture].button.image = textures[self.current_texture]
	end
end

function Texturer_interface:select_texture (texture_n)
	self.texture_selectors[self.current_texture].button.text = ""
	self.current_texture = texture_n
	self.heightmap_texturer.current_texture = texture_n
	self.texture_selectors[texture_n].button.image = textures[texture_n]
	self.texture_selectors[texture_n].button.text = "Active"
end
