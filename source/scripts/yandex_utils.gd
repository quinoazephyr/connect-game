class_name YandexUtils

static func get_save_data(data):
	var data_processed = null
	if data && data.has("saves"):
		var saves = data["saves"]
		if typeof(saves) == TYPE_ARRAY && \
				saves.size() > 0:
			var json = JSON.parse(saves[0])
			if json.get_error() == OK:
				data_processed = json.result
	else:
		data_processed = data
	return data_processed
