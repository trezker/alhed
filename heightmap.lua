-- Title: bitmap example
-- Demonstrates usage of bitmap functions

require('liballua')
require('liballedge_lua')

dofile('rect.lua')
dofile('gui.lua')
dofile('widget.lua')
dofile('heightmap_modeler.lua')
dofile('camera_controller.lua')
dofile('curve_editor.lua')
dofile('button.lua')
dofile('label.lua')
dofile('spinner.lua')
dofile('heightmap_texturer.lua')
dofile('heightmap_painter.lua')
dofile('modeler_interface.lua')
dofile('texturer_interface.lua')
dofile('painter_interface.lua')
dofile('new_map_interface.lua')
dofile('objects_interface.lua')

fov = 45
near = 1
far = 1000
width = 640
height = 480

mouse_x = 0
mouse_y = 0


allegro5.init()
allegro5.keyboard.install()
allegro5.mouse.install()
allegro5.bitmap.init_image_addon ()

allegro5.display.set_new_flags(allegro5.display.WINDOWED)
display = allegro5.display.create(640, 480)
event_queue = allegro5.event_queue.create()

event_queue:register_event_source(display:get_event_source())
keyboard = allegro5.keyboard.get_event_source()
event_queue:register_event_source(keyboard)
mouse = allegro5.mouse.get_event_source()
event_queue:register_event_source(mouse)

font = allegro5.font.load_ttf("data/DejaVuSans.ttf", 10, 0)

root = alledge_lua.scenenode.new()

camera = alledge_lua.cameranode.new()
camera:set_position(alledge_lua.vector3.new(20, 5, 20));
camera:set_rotation(alledge_lua.vector3.new(0, 0, 0));
root:attach_node(camera);

light = alledge_lua.lightnode.new()
light:set_ambient(.2, .2, .2, 1)
light:set_diffuse(.8, .8, .8, 1)
light:set_position(alledge_lua.vector3.new(1, 1, 1), true)
alledge_lua.scenenode.attach_node(camera, light)

transform = alledge_lua.transformnode.new()
alledge_lua.scenenode.attach_node(light, transform)
--[[
line_start = alledge_lua.vector3.new(-1, -1, 1);
line_end = alledge_lua.vector3.new(1, -1, 1);

line_node = alledge_lua.linenode.new()
line_node:set_line(line_start, line_end)
line_node:set_color(1, 1, 1, 1)
alledge_lua.scenenode.attach_node(transform, line_node);
--]]

object_models = {}

handgun_model = alledge_lua.static_model.new()
handgun_model:load_model("data/handgun.tmf")
handgun_texture = alledge_lua.bitmap.new()
b = handgun_texture:load("data/handgun.png")
handgun_model:set_texture(handgun_texture)

om = {}
om.model = handgun_model
om.model_node = alledge_lua.static_model_node.new()
om.model_node:set_model(om.model)
om.interface_transform = alledge_lua.transformnode.new()
om.interface_transform:set_position(alledge_lua.vector3.new(-0.75, 0, -3))
om.interface_transform:set_rotation(alledge_lua.vector3.new(0, -90, 0))
alledge_lua.scenenode.attach_node(om.interface_transform, om.model_node);
table.insert(object_models, om)



function save_heightmap ()
	native_dialog = allegro5.native_dialog.create ("", "save", "*.*", 0)
	native_dialog:show()
	n = native_dialog:get_count()
	if n>0 then
		path = native_dialog:get_path(0)
		print("Path: " .. path)
		heightmap:save(path)
	end
end

function load_heightmap ()
	native_dialog = allegro5.native_dialog.create ("", "load", "*.*", allegro5.native_dialog.FILECHOOSER_FILE_MUST_EXIST)
	native_dialog:show()
	n = native_dialog:get_count()
	if n>0 then
		path = native_dialog:get_path(0)
		print("Path: " .. path)
		heightmap:load(path)
		texturer_interface:refresh_textures()
	end
end


--Heightmap setup
ground_texture = alledge_lua.bitmap.new()
ground_texture:load("data/ground.png");

textures = {}
--[[
splat_texture = alledge_lua.bitmap.new()
splat_texture:load("data/splat_texture.png");

if not splat_texture then
	print("Splat texture missing")
end
--]]
new_heightmap_settings = {
	texture_scale = .2, --texture tiling per model tile
	tilesize = 1,
	size_x = 50,
	size_z = 30,
	ground_filename = "data/ground.png"
}

new_heightmap = function ()
	if heightmap then
		alledge_lua.scenenode.detach_node(transform, heightmap)
	end
	heightmap = alledge_lua.heightmap.new()
	heightmap:set_texture_scale(new_heightmap_settings.texture_scale)
	heightmap:set_tilesize(new_heightmap_settings.tilesize)
	heightmap:resize(new_heightmap_settings.size_x, new_heightmap_settings.size_z)
	heightmap:set_ground_texture(ground_texture)
	heightmap:set_ground_texture_filename(new_heightmap_settings.ground_filename)
--	heightmap:set_splat_texture(splat_texture)
	splat_texture = heightmap:get_splat_texture()
	alledge_lua.scenenode.attach_node(transform, heightmap)
end

new_heightmap()

camera_controller = Camera_controller:new ()
camera_controller:init(camera)

modeler_interface = Modeler_interface:new ()
modeler_widget = modeler_interface:init ()

texturer_interface = Texturer_interface:new ()
texturer_widget = texturer_interface:init ()

painter_interface = Painter_interface:new ()
painter_widget = painter_interface:init ()

objects_interface = Objects_interface:new ()
objects_widget = objects_interface:init (object_models)

edit_modes = {
	{name = "Model", widget = modeler_widget},
	{name = "Texture", widget = texturer_widget},
	{name = "Color", widget = painter_widget},
	{name = "Objects", widget = objects_widget}
}
edit_mode = 1


wrect = Rect:new ()
wrect:init(0, 0, width, height)
gui_root = Widget:new()
gui_root:init(wrect, nil)

wrect = Rect:new ()
wrect:init(0, 32, width, height)
edit_mode_widget = Widget:new()
edit_mode_widget:init(wrect, nil)
edit_mode_widget:add_child(edit_modes[edit_mode].widget)
gui_root:add_child(edit_mode_widget)

wrect = Rect:new ()
wrect:init(64, 0, 128, 32)
save_heightmap_button = Button:new ()
save_heightmap_button:init(wrect, "Save", save_heightmap)
gui_root:add_child(save_heightmap_button)

wrect = Rect:new ()
wrect:init(128, 0, 192, 32)
load_heightmap_button = Button:new ()
load_heightmap_button:init(wrect, "Load", load_heightmap)
gui_root:add_child(load_heightmap_button)

new_map_interface = New_map_interface:new ()
new_map_interface:init()
wrect = Rect:new ()
wrect:init(192, 0, 256, 32)
new_heightmap_button = Button:new ()
new_heightmap_button:init(wrect, "New", new_map_interface.open, new_map_interface)
gui_root:add_child(new_heightmap_button)


last_time = allegro5.current_time()

b = false

full_viewport = {}
full_viewport.x, full_viewport.y, full_viewport.w, full_viewport.h = alledge_lua.gl.get(alledge_lua.gl.VIEWPORT)


while not quit do
	current_time = allegro5.current_time()
	dt = current_time - last_time
	last_time = current_time

	event = event_queue:get_next_event()
	if event.type == allegro5.display.EVENT_CLOSE or event.type == allegro5.keyboard.EVENT_DOWN and event.keycode == allegro5.keyboard.KEY_ESCAPE then
		quit = true
	end

	if event.type == allegro5.mouse.EVENT_AXES or event.type == allegro5.mouse.EVENT_UP or event.type == allegro5.mouse.EVENT_DOWN then
		mouse_x = event.x
		mouse_y = event.y
	end

	gui_root:event(event)
	dispatch_event (event)

	if event.type == allegro5.keyboard.EVENT_DOWN then
		if event.keycode == allegro5.keyboard.KEY_LSHIFT then
			shift = true
		end
		if event.keycode == allegro5.keyboard.KEY_LCTRL then
			ctrl = true
		end
		if event.keycode == allegro5.keyboard.KEY_F5 then
			alledge_lua.gl.set_viewport(100, 200, 300, 150)
		end
		if event.keycode == allegro5.keyboard.KEY_F6 then
			alledge_lua.gl.set_viewport(full_viewport.x, full_viewport.y, full_viewport.w, full_viewport.h)
		end
	end

	if event.type == allegro5.keyboard.EVENT_UP then
		if event.keycode == allegro5.keyboard.KEY_TAB then
			edit_mode_widget:remove_child(edit_modes[edit_mode].widget)
			edit_mode = edit_mode + 1
			if edit_mode > table.getn(edit_modes) then
				edit_mode = 1
			end
			edit_mode_widget:add_child(edit_modes[edit_mode].widget)
		end
		if event.keycode == allegro5.keyboard.KEY_LSHIFT then
			shift = false
		end
		if event.keycode == allegro5.keyboard.KEY_LCTRL then
			ctrl = false
		end
	end

	modeler_interface.heightmap_modeler:update(dt)
	texturer_interface.heightmap_texturer:update(dt)
	painter_interface.heightmap_painter:update(dt)

	alledge_lua.init_perspective_view(fov, width/height, near, far)
	alledge_lua.gl.enable(alledge_lua.gl.DEPTH_TEST)
	alledge_lua.gl.enable(alledge_lua.gl.LIGHTING);
	alledge_lua.gl.clear(alledge_lua.gl.DEPTH_BUFFER_BIT)

	root:apply()

	alledge_lua.gl.disable(alledge_lua.gl.LIGHTING);
	alledge_lua.gl.disable(alledge_lua.gl.DEPTH_TEST)
	alledge_lua.pop_view()

-- [[
	alledge_lua.init_perspective_view(fov, width/height, near, far)
	alledge_lua.gl.set_viewport(10, 300, 100, 100)
	temp_root = alledge_lua.scenenode.new()
	alledge_lua.scenenode.attach_node(temp_root, om.interface_transform)
	temp_root:apply()
	alledge_lua.gl.set_viewport(full_viewport.x, full_viewport.y, full_viewport.w, full_viewport.h)
	alledge_lua.pop_view()
--]]
	gui_root:render()

	allegro5.primitives.draw_filled_rectangle(0, 0, 64, 32, allegro5.color.map_rgb(255, 0, 0))
	font:draw_text (0, 0, 0, "Edit")
	font:draw_text (0, 16, 0, edit_modes[edit_mode].name)

	--Todo: Make a little viewport for it?
--	alledge_lua.scenenode.apply(om.interface_transform)
--	alledge_lua.scenenode.apply(om.interface_transform)
--[[
	for i = 1, 4 do
		if textures[i] then
			textures[i]:draw_scaled(i*64, 0, 64, 64, 0)
--			heightmap:set_texture(textures[i], i-1);
		end
	end
--]]
	allegro5.display.flip()
	allegro5.bitmap.clear_to_color (allegro5.color.map_rgba(0, 0, 0, 0))
	allegro5.rest(0.001)
end
