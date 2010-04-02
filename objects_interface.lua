dofile('object_selector.lua')
dofile('objects_editor.lua')

Objects_interface = { }

function Objects_interface:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Objects_interface:init ()
	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	self.top_widget = Widget:new()
	self.top_widget:init(wrect)
	
	self.objects = {}

	self.objects_editor = Objects_editor:new ()
	self.objects_editor:init()

	wrect = Rect:new ()
	wrect:init(0, 128, width, height)
	self.editor_widget = Widget:new()
	self.editor_widget:init(wrect, self.objects_editor)
	self.editor_widget:add_component(camera_controller)
	self.top_widget:add_child(self.editor_widget)

	self.current_object = 1

	wrect = Rect:new ()
	wrect:init(0, 0, 64, 16)
	self.load_object_button = Button:new ()
	self.load_object_button:init(wrect, "Load static", self.load_object, self)

	wrect = Rect:new ()
	wrect:init(0, 0, 64, 16)
	self.load_animated_button = Button:new ()
	self.load_animated_button:init(wrect, "Load animated", self.load_animated_object, self)

	wrect = Rect:new ()
	wrect:init(64, 32, 6*64, 92)
	self.object_selector = Object_selector:new ()
	self.object_selector:init(wrect, self.objects, self.select_object, self)
	self.top_widget:add_child(self.object_selector)

	--Layout
	wrect = Rect:new ()
	wrect:init(0, 32, 64, 64)
	self.loaders_box = Widget_vbox:new()
	self.loaders_box:init(wrect)

	self.top_widget:add_child(self.loaders_box)

	self.loaders_box:add_child(self.load_object_button)
	self.loaders_box:add_child(self.load_animated_button)

	return self.top_widget
end

function Objects_interface:load_object ()
	print("visible dialog")
	native_dialog = allegro5.native_dialog.create ("", "Select object", "*.tmf", allegro5.native_dialog.FILECHOOSER_FILE_MUST_EXIST)
	native_dialog:show()
	n = native_dialog:get_count()
	if n>0 then
		path = native_dialog:get_path(0)
		print("Path: " .. path)
		
		model = alledge_lua.static_model.new()
		model:load_model(path)

		--Todo: models should not require texture to be rendered
--		texture = alledge_lua.bitmap.new()
--		b = texture:load("data/handgun.png")
--		model:set_texture(texture)

		om = {}
		om.model = model
		om.model_node = alledge_lua.static_model_node.new()
		om.model_node:set_model(om.model)
		om.interface_transform = alledge_lua.transformnode.new()
		om.interface_transform:set_position(alledge_lua.vector3.new(-0.75, 0, -3))
		om.interface_transform:set_rotation(alledge_lua.vector3.new(0, -90, 0))
		alledge_lua.scenenode.attach_node(om.interface_transform, om.model_node);

		master_objects[master_objects_next_id] = om
		table.insert(self.objects, master_objects_next_id)
		master_objects_next_id = master_objects_next_id + 1

		print("Objects: " .. table.getn(self.objects))
	end
end

function Objects_interface:load_animated_object ()
	print("visible dialog")
	native_dialog = allegro5.native_dialog.create ("", "Select object", "*.md5mesh", allegro5.native_dialog.FILECHOOSER_FILE_MUST_EXIST)
	native_dialog:show()
	n = native_dialog:get_count()
	if n>0 then
		path = native_dialog:get_path(0)
		print("Path: " .. path)
		
		model = alledge_lua.animated_model.new()
		model:load_model(path)

		om = {}
		om.model = model
		om.model_instance = alledge_lua.animated_model_instance.new()
		om.model_instance:set_model(om.model)
--		om.model_instance:update(1)
		om.model_node = alledge_lua.animated_model_node.new()
		om.model_node:set_model(om.model_instance)

		om.interface_transform = alledge_lua.transformnode.new()
		om.interface_transform:set_position(alledge_lua.vector3.new(0, -6, -20))
		om.interface_transform:set_rotation(alledge_lua.vector3.new(0, 0, 0))
		alledge_lua.scenenode.attach_node(om.interface_transform, om.model_node);

		master_objects[master_objects_next_id] = om
		table.insert(self.objects, master_objects_next_id)
		master_objects_next_id = master_objects_next_id + 1

		print("Objects: " .. table.getn(self.objects))
	end
end

function Objects_interface:select_object (object_n)
	self.current_object = object_n
	self.objects_editor:set_object(self.objects[object_n])
end
