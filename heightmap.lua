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
dofile('heightmap_texturer.lua')
dofile('heightmap_painter.lua')

fov = 45
near = 1
far = 1000
width = 640
height = 480

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

line_start = alledge_lua.vector3.new(-1, -1, 1);
line_end = alledge_lua.vector3.new(1, -1, 1);

line_node = alledge_lua.linenode.new()
line_node:set_line(line_start, line_end)
line_node:set_color(1, 1, 1, 1)
alledge_lua.scenenode.attach_node(transform, line_node);

--Heightmap setup
textures = {}
textures[1] = alledge_lua.bitmap.new()
textures[1]:load("data/darwinian.png");
textures[2] = alledge_lua.bitmap.new()
textures[2]:load("data/Colormap.png");
textures[3] = alledge_lua.bitmap.new()
textures[3]:load("data/grass.png");
splat_texture = alledge_lua.bitmap.new()
splat_texture:load("data/splat_texture.png");

if not splat_texture then
	print("Splat texture missing")
end

heightmap = alledge_lua.heightmap.new()
heightmap:set_texture_scale(.2)
heightmap:set_tilesize(1)
heightmap:resize(50, 30)
heightmap:set_splat_texture(splat_texture)
for i = 1, 4 do
	if textures[i] then
		heightmap:set_texture(textures[i], i-1)
	end
end
alledge_lua.scenenode.attach_node(transform, heightmap)

camera_controller = Camera_controller:new ()
camera_controller:init(camera)




--Modeler interface
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
modeler_widget:add_child(curve_editor_widget)
heightmap_modeler:set_curve(curve_editor.curve)

--Texturer interface
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


--Painter interface
heightmap_painter = Heightmap_painter:new ()
heightmap_painter:init(heightmap)

wrect = Rect:new ()
wrect:init(0, 0, width, height)
painter_widget = Widget:new()
painter_widget:init(wrect, heightmap_painter)
painter_widget:add_component(camera_controller)

edit_modes = {
	{name = "Model", widget = modeler_widget},
	{name = "Texture", widget = texturer_widget},
	{name = "Color", widget = painter_widget}
}
edit_mode = 1

wrect = Rect:new ()
wrect:init(0, 0, width, height)
widget = Widget:new()
widget:init(wrect, nil)
widget:add_child(edit_modes[edit_mode].widget)



last_time = allegro5.current_time()

b = false

while not quit do
	current_time = allegro5.current_time()
	dt = current_time - last_time
	last_time = current_time

	event = event_queue:get_next_event()
	if event.type == allegro5.display.EVENT_CLOSE or event.type == allegro5.keyboard.EVENT_DOWN and event.keycode == allegro5.keyboard.KEY_ESCAPE then
		quit = true
	end
	
	widget:event(event)
	dispatch_event (event)

	if event.type == allegro5.keyboard.EVENT_DOWN then
		if event.keycode == allegro5.keyboard.KEY_LSHIFT then
			shift = true
		end
		if event.keycode == allegro5.keyboard.KEY_LCTRL then
			ctrl = true
		end
	end

	if event.type == allegro5.keyboard.EVENT_UP then
		if event.keycode == allegro5.keyboard.KEY_TAB then
			widget:remove_child(edit_modes[edit_mode].widget)
			edit_mode = edit_mode + 1
			if edit_mode > table.getn(edit_modes) then
				edit_mode = 1
			end
			widget:add_child(edit_modes[edit_mode].widget)
		end
		if event.keycode == allegro5.keyboard.KEY_LSHIFT then
			shift = false
		end
		if event.keycode == allegro5.keyboard.KEY_LCTRL then
			ctrl = false
		end
	end

	if event.type == allegro5.mouse.EVENT_AXES then
		mouse_x = event.x
		mouse_y = event.y
	end

	heightmap_modeler:update(dt)
	heightmap_texturer:update(dt)
	heightmap_painter:update(dt)

	alledge_lua.init_perspective_view(fov, width/height, near, far)
	alledge_lua.gl.enable(alledge_lua.gl.DEPTH_TEST)
	alledge_lua.gl.enable(alledge_lua.gl.LIGHTING);
	alledge_lua.gl.clear(alledge_lua.gl.DEPTH_BUFFER_BIT)

	root:apply()

	alledge_lua.gl.disable(alledge_lua.gl.LIGHTING);
	alledge_lua.gl.disable(alledge_lua.gl.DEPTH_TEST)
	alledge_lua.pop_view()

	widget:render()

	allegro5.primitives.draw_filled_rectangle(0, 0, 64, 32, allegro5.color.map_rgb(255, 0, 0))
	font:draw_text (0, 0, 0, "Edit")
	font:draw_text (0, 16, 0, edit_modes[edit_mode].name)

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
