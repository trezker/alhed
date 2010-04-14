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
	self.load_object_button:init(wrect, "Load static", self.load_object, self, load_static_object)

	wrect = Rect:new ()
	wrect:init(0, 0, 64, 16)
	self.load_animated_button = Button:new ()
	self.load_animated_button:init(wrect, "Load animated", self.load_object, self, load_animated_object )

	wrect = Rect:new ()
	wrect:init(0, 0, 64, 16)
	self.save_set_button = Button:new ()
	self.save_set_button:init(wrect, "Save set", self.save_set, self)

	wrect = Rect:new ()
	wrect:init(64, 32, 6*64, 92)
	self.object_selector = Object_selector:new ()
	self.object_selector:init(wrect, self.objects, self.select_object, self)
	self.top_widget:add_child(self.object_selector)

	--Layout
	wrect = Rect:new ()
	wrect:init(0, 32, 64, 96)
	self.loaders_box = Widget_vbox:new()
	self.loaders_box:init(wrect)

	self.top_widget:add_child(self.loaders_box)

	self.loaders_box:add_child(self.load_object_button)
	self.loaders_box:add_child(self.load_animated_button)
	self.loaders_box:add_child(self.save_set_button)

	return self.top_widget
end

function Objects_interface:load_object (load_func)
	native_dialog = allegro5.native_dialog.create ("", "Select object", "*.tmf", allegro5.native_dialog.FILECHOOSER_FILE_MUST_EXIST)
	native_dialog:show()
	n = native_dialog:get_count()
	if n>0 then
		path = native_dialog:get_path(0)
		
		obj_id = load_func (path)
		table.insert(self.objects, obj_id)
	end
end

function Objects_interface:select_object (object_n)
	self.current_object = object_n
	self.objects_editor:set_object(self.objects[object_n])
end

function Objects_interface:save_set ()
	print("Saving object set")

	native_dialog = allegro5.native_dialog.create ("", "save", "*.*", allegro5.native_dialog.FILECHOOSER_FOLDER)
	native_dialog:show()
	n = native_dialog:get_count()
	if n>0 then
		save_object_set (native_dialog:get_path(0))
	end
end
