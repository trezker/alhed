event_subscribers = {}

dispatch_event = function(event)
	if event_subscribers[event.type] then
		for i, v in ipairs(event_subscribers[event.type]) do
			v.callback(v.object, event)
		end
	end	
end

subscribe_to_event = function(event_type, icallback, iobject)
	unsubscribe_from_event(event_type, icallback, iobject)	--avoid doubles
	if not event_subscribers[event_type] then
		event_subscribers[event_type] = {}
	end
	table.insert(event_subscribers[event_type], {callback = icallback, object = iobject})
end

unsubscribe_from_event = function(event_type, icallback, iobject)
	if event_subscribers[event_type] then
		for i, v in ipairs(event_subscribers[event_type]) do
			if icallback == v.callback and iobject == v.object then
				table.remove(event_subscribers[event_type], i)
				return
			end
		end
	end
end
