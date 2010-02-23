create_texturer_interface = function()
	heightmap_texturer = Heightmap_texturer:new ()
	heightmap_texturer:init(heightmap)

	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	texturer_widget = Widget:new()
	texturer_widget:init(wrect, heightmap_texturer)
	texturer_widget:add_component(camera_controller)

	current_texture = 1
	load_texture = function()
		native_dialog = allegro5.native_dialog.create ("", "test", "*.*", allegro5.native_dialog.FILECHOOSER_FILE_MUST_EXIST)
		native_dialog:show()
		n = native_dialog:get_count()
		if n>0 then
			path = native_dialog:get_path(0)
			print("Path: " .. path)
			textures[current_texture] = alledge_lua.bitmap.new()
			textures[current_texture]:load(path);
			heightmap:set_texture(textures[current_texture], current_texture-1);
			texture_selectors[current_texture].button.image = textures[current_texture]
		end
	end

	select_texture = function(texture_n)
		texture_selectors[current_texture].button.text = ""
		current_texture = texture_n
		texture_selectors[texture_n].button.image = textures[texture_n]
		texture_selectors[texture_n].button.text = "Active"
	end

	wrect = Rect:new ()
	wrect:init(0, 32, 64, 64)
	load_texture_button = Button:new ()
	load_texture_button:init(wrect, "Load", load_texture, nil)
	load_texture_widget = Widget:new()
	load_texture_widget:init(wrect, load_texture_button)
	texturer_widget:add_child(load_texture_widget)

	texture_selectors = {}
	for i = 1, 4 do
		wrect = Rect:new ()
		wrect:init(i*64, 0, i*64+64, 64)
		texture_selectors[i] = {}
		texture_selectors[i].button = Button:new ()
		texture_selectors[i].button:init(wrect, "", select_texture, i)
		texture_selectors[i].button.image = textures[i]
		texture_selectors[i].widget = Widget:new()
		texture_selectors[i].widget:init(wrect, texture_selectors[i].button)
		texturer_widget:add_child(texture_selectors[i].widget)
	end
	texture_selectors[1].button.text = "Active"

	return texturer_widget
end
