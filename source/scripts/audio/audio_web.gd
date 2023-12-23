class_name AudioWeb
extends AudioBase

onready var _howler = .get_tree().root.get_node(HowlerJS.SINGLETON_NAME)

func load_sounds():
	.load_sounds()
	
	var all_sounds_paths : Array
	for key in _sounds.keys():
		for path in _sounds[key]:
			all_sounds_paths.append(path)
	_howler.load_sounds(all_sounds_paths)

func _add_sound_to_sounds(sound_group_name : String, sound_path : String):
	var sound_path_js = \
			_change_extension(sound_path, "mp3").trim_prefix("res://")
	_sounds[sound_group_name].append(sound_path_js)

func _play_sound(group_name : String, idx : int):
	var howler_idx = _get_howler_sound_idx(group_name, idx)
	_howler.play_sound(howler_idx)

func _change_extension(fname : String, new_ext : String):
	return "%s.%s" % [fname.substr(0, fname.find_last(".")), new_ext]

func _get_howler_sound_idx(group_name : String, idx : int):
	var howler_idx = 0
	for key in _sounds.keys():
		if group_name == key:
			howler_idx += idx
			break
		howler_idx += _sounds[key].size()
	return howler_idx
