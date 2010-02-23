create_painter_interface = function()
	heightmap_painter = Heightmap_painter:new ()
	heightmap_painter:init(heightmap)

	wrect = Rect:new ()
	wrect:init(0, 0, width, height)
	painter_widget = Widget:new()
	painter_widget:init(wrect, heightmap_painter)
	painter_widget:add_component(camera_controller)

	return painter_widget
end
