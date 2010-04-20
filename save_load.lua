save_object_set = function (path)
	master_objects.filename = path
	print("Path: " .. master_objects.filename)

	objects_file = io.open(master_objects.filename, "w")
	obj_set_n = table.getn(master_objects)
	objects_file:write(obj_set_n .. "\n\n")
	for k, v in pairs(master_objects) do
		if v.model_file then
			objects_file:write(v.model_file .. "\n")
			objects_file:write(v.model_type .. "\n\n")
		end
	end
	objects_file:close()
end

load_animated_object = function(path)
	print("Path: " .. path)
	
	model = alledge_lua.animated_model.new()
	model:load_model(path)

	om = {}
	om.model_file = path
	om.model_type = "md5mesh"
	
	om.model = model
	om.model_instance = alledge_lua.animated_model_instance.new()
	om.model_instance:set_model(om.model)
--	om.model_instance:set_color(0, 1, 0, 0.5)
	om.model_node = alledge_lua.animated_model_node.new()
	om.model_node:set_model(om.model_instance)

	om.model_instance:update(0)

	--Make a bounding box
	low = om.model_instance:get_low_corner()
	high = om.model_instance:get_high_corner()
	low = low - alledge_lua.vector3.new(.01, .01, .01)
	high = high + alledge_lua.vector3.new(.01, .01, .01)

	om.bbox = alledge_lua.static_model.new()
	om.bbox_node = alledge_lua.static_model_node.new()
	om.bbox_node:set_model(om.bbox)

	coords = {}
	table.insert(coords, alledge_lua.vector3.new(low.x, low.y, low.z)) -- 0 0
	table.insert(coords, alledge_lua.vector3.new(high.x, low.y, low.z)) -- 1 0
	table.insert(coords, alledge_lua.vector3.new(high.x, high.y, low.z)) -- 2 3
	table.insert(coords, alledge_lua.vector3.new(low.x, high.y, low.z)) -- 3 3

	table.insert(coords, alledge_lua.vector3.new(low.x, low.y, high.z)) -- 4 1
	table.insert(coords, alledge_lua.vector3.new(high.x, low.y, high.z)) -- 5 1
	table.insert(coords, alledge_lua.vector3.new(high.x, high.y, high.z)) -- 6 2
	table.insert(coords, alledge_lua.vector3.new(low.x, high.y, high.z)) -- 7 2

	indexes = {}
	table.insert(indexes, {0, 1, 2})
	table.insert(indexes, {0, 2, 3})

	table.insert(indexes, {4, 5, 6})
	table.insert(indexes, {4, 6, 7})

	table.insert(indexes, {0, 4, 7})
	table.insert(indexes, {0, 7, 3})

	table.insert(indexes, {1, 5, 6})
	table.insert(indexes, {1, 6, 2})

	om.bbox:set_model_data(coords, indexes)
	om.bbox:set_color(1, 0, 0, 0.5)
	--End of bounding box code

	size = high - low
	rotx = 0
	roty = 0
	if size.x < size.z and size.x < size.y then
		roty = 90
	elseif size.y < size.z and size.y < size.x then
		rotx = 90
	end
	biggest = size.x
	if size.y > biggest then
		biggest = size.y
	elseif size.z > biggest then
		biggest = size.z
	end
	scale = 1/biggest
	print(biggest)
	
	center = (low+high)/2*scale
	print("Center: " .. center.x .. ", " .. center.y .. ", " .. center.z)

	om.interface_transform = alledge_lua.transformnode.new()
	om.interface_transform:set_scale(alledge_lua.vector3.new(scale, scale, scale))
	if roty == 90 then
		om.interface_transform:set_position(alledge_lua.vector3.new(-center.z, -center.y, -2))
	elseif rotx == 90 then
		om.interface_transform:set_position(alledge_lua.vector3.new(-center.x, -center.z, -2))
	else
		om.interface_transform:set_position(alledge_lua.vector3.new(-center.x, -center.y, -2))
	end
	om.interface_transform:set_rotation(alledge_lua.vector3.new(rotx, roty, 0))
	alledge_lua.scenenode.attach_node(om.interface_transform, om.model_node);
--	alledge_lua.scenenode.attach_node(om.model_node, om.bbox_node)
--[[
	om.interface_transform = alledge_lua.transformnode.new()
	om.interface_transform:set_scale(alledge_lua.vector3.new(1/2, 1/2, 1/2))
	om.interface_transform:set_position(alledge_lua.vector3.new(0, -7.5, -2))
	om.interface_transform:set_rotation(alledge_lua.vector3.new(0, 0, 0))
	alledge_lua.scenenode.attach_node(om.interface_transform, om.model_node);
--	alledge_lua.scenenode.attach_node(om.model_node, om.bbox_node)
--]]
	master_objects[master_objects_next_id] = om
	master_objects_next_id = master_objects_next_id + 1
	return master_objects_next_id - 1
end

load_static_object = function (path)
	model = alledge_lua.static_model.new()
	model:load_model(path)

	om = {}
	om.model_file = path
	om.model_type = "tmf"
	
	om.model = model
	om.model_node = alledge_lua.static_model_node.new()
	om.model_node:set_model(om.model)

	--Make a bounding box
	low = model:get_low_corner()
	high = model:get_high_corner()
	low = low - alledge_lua.vector3.new(.01, .01, .01)
	high = high + alledge_lua.vector3.new(.01, .01, .01)

	om.bbox = alledge_lua.static_model.new()
	om.bbox_node = alledge_lua.static_model_node.new()
	om.bbox_node:set_model(om.bbox)

	coords = {}
	table.insert(coords, alledge_lua.vector3.new(low.x, low.y, low.z)) -- 0 0
	table.insert(coords, alledge_lua.vector3.new(high.x, low.y, low.z)) -- 1 0
	table.insert(coords, alledge_lua.vector3.new(high.x, high.y, low.z)) -- 2 3
	table.insert(coords, alledge_lua.vector3.new(low.x, high.y, low.z)) -- 3 3

	table.insert(coords, alledge_lua.vector3.new(low.x, low.y, high.z)) -- 4 1
	table.insert(coords, alledge_lua.vector3.new(high.x, low.y, high.z)) -- 5 1
	table.insert(coords, alledge_lua.vector3.new(high.x, high.y, high.z)) -- 6 2
	table.insert(coords, alledge_lua.vector3.new(low.x, high.y, high.z)) -- 7 2

	indexes = {}
	table.insert(indexes, {0, 1, 2})
	table.insert(indexes, {0, 2, 3})

	table.insert(indexes, {4, 5, 6})
	table.insert(indexes, {4, 6, 7})

	table.insert(indexes, {0, 4, 7})
	table.insert(indexes, {0, 7, 3})

	table.insert(indexes, {1, 5, 6})
	table.insert(indexes, {1, 6, 2})

	om.bbox:set_model_data(coords, indexes)
	om.bbox:set_color(1, 0, 0, 0.5)
	--End of bounding box code

	size = high - low
	rotx = 0
	roty = 0
	if size.x < size.z and size.x < size.y then
		roty = 90
	elseif size.y < size.z and size.y < size.x then
		rotx = 90
	end
	biggest = size.x
	if size.y > biggest then
		biggest = size.y
	elseif size.z > biggest then
		biggest = size.z
	end
	scale = 1/biggest
	print(biggest)
	
	center = (low+high)/2*scale
	print("Center: " .. center.x .. ", " .. center.y .. ", " .. center.z)

	om.interface_transform = alledge_lua.transformnode.new()
	om.interface_transform:set_scale(alledge_lua.vector3.new(scale, scale, scale))
	if roty == 90 then
		om.interface_transform:set_position(alledge_lua.vector3.new(-center.z, -center.y, -2))
	elseif rotx == 90 then
		om.interface_transform:set_position(alledge_lua.vector3.new(-center.x, -center.z, -2))
	else
		om.interface_transform:set_position(alledge_lua.vector3.new(-center.x, -center.y, -2))
	end
	om.interface_transform:set_rotation(alledge_lua.vector3.new(rotx, roty, 0))
	alledge_lua.scenenode.attach_node(om.interface_transform, om.model_node);
--	alledge_lua.scenenode.attach_node(om.model_node, om.bbox_node)

	master_objects[master_objects_next_id] = om
	master_objects_next_id = master_objects_next_id + 1

	return master_objects_next_id - 1
end
