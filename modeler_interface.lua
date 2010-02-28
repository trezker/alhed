Modeler_interface = { }

function Modeler_interface:new ()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Modeler_interface:init ()
	self.heightmap_modeler = Heightmap_modeler:new ()
	self.heightmap_modeler:init(heightmap)

	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	self.modeler_widget = Widget:new()
	self.modeler_widget:init(wrect, self.heightmap_modeler)
	self.modeler_widget:add_component(camera_controller)

	wrect = Rect:new ()
	wrect:init(0, height-100, 100, height)
	self.curve_editor = Curve_editor:new()
	self.curve_editor:init(wrect)
	self.curve_editor_widget = Widget:new()
	self.curve_editor_widget:init(wrect, self.curve_editor)
	self.heightmap_modeler:set_curve(self.curve_editor.curve)
	self.modeler_widget:add_child(self.curve_editor_widget)
	return self.modeler_widget
end
