class_name LoadDataAllYandexButton
extends Button

func _ready():
	connect("pressed", YandexSDKAutoload, "load_data_all")
	YandexSDKAutoload.connect("data_loaded_from_cloud", self, "parse_loaded_json")

func parse_loaded_json(data):
	print("==== parse_loaded_json ====")
	print(data)
#	if !data:
#		print("data loaded null")
#		return
#	var json_parsed
#	if data.has("saves"):
#		var saves = data["saves"]
#		if typeof(saves) == TYPE_ARRAY && \
#				saves.size() > 0:
#			json_parsed = JSON.parse(saves[0]) # unity
#			if json_parsed.get_error() != OK:
#				print("loaded data not unity")
#				return
#		else:
#			print(typeof(saves))
#			return
#	else:
#		json_parsed = JSON.parse(data) # godot
#		if json_parsed.get_error() != OK:
#			print("loaded data not godot")
#			return
#	print(json_parsed.result)
	print("==== ================= ====")
