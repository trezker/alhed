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
	om.model_node = alledge_lua.animated_model_node.new()
	om.model_node:set_model(om.model_instance)

	return om
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
	return om
end
