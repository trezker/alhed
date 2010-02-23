create_modeler_interface = function()
	heightmap_modeler = Heightmap_modeler:new ()
	heightmap_modeler:init(heightmap)

	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	modeler_widget = Widget:new()
	modeler_widget:init(wrect, heightmap_modeler)
	modeler_widget:add_component(camera_controller)

	wrect = Rect:new ()
	wrect:init(0, height-100, 100, height)
	curve_editor = Curve_editor:new()
	curve_editor:init(wrect)
	curve_editor_widget = Widget:new()
	curve_editor_widget:init(wrect, curve_editor)
	heightmap_modeler:set_curve(curve_editor.curve)
	modeler_widget:add_child(curve_editor_widget)
	return modeler_widget
end
