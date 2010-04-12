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
