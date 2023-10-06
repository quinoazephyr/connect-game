class_name AudioBase
extends Node

signal muted(is_muted)

#	[KEY] sound_name && sound_name_N
#	[VALUE] sound_path
export(Dictionary) var _sounds_paths

var is_muted setget, get_is_muted

var _is_muted : bool
var _sounds : Dictionary # { name : [sounds] }
var _sounds_ids_for_random_play : Dictionary # { name : [sounds_ids] }

func _ready():
	connect("ready", self, "load_sounds")

func load_sounds():
	_sounds.clear()
	_sounds_ids_for_random_play.clear()
	for s_key in _sounds_paths.keys():
		var sound_name : String = s_key
		var sound_path = _sounds_paths[s_key]
		var sound_group_name = _get_sound_group_name(sound_name)
		if !_sounds.has(sound_group_name):
			_sounds[sound_group_name] = []
		if !_sounds_ids_for_random_play.has(sound_group_name):
			_sounds_ids_for_random_play[sound_group_name] = []
		_add_sound_to_sounds(sound_group_name, sound_path)
		_sounds_ids_for_random_play[sound_group_name]\
				.append(_sounds[sound_group_name].size() - 1)

func play_sound(sound_name : String):
	var sound_group_name = _get_sound_group_name(sound_name)
	if sound_group_name == sound_name:
		_play_sound(sound_group_name, 0)
	else:
		_play_sound(sound_group_name, _get_sound_idx(sound_name))

func play_sound_random(group_name : String):
	var sounds_ids_count = _sounds_ids_for_random_play[group_name].size()
	var random_idx = \
			_sounds_ids_for_random_play[group_name][randi() % sounds_ids_count]
	_play_sound(group_name, random_idx)
	_sounds_ids_for_random_play[group_name].erase(random_idx)
	sounds_ids_count -= 1
	if sounds_ids_count == 0:
		_reset_sounds_ids_for_random_play(group_name)
		if _sounds_ids_for_random_play[group_name].size() > 1:
			_sounds_ids_for_random_play[group_name].erase(random_idx)

func mute(mute : bool) -> void:
	_is_muted = mute
	emit_signal("muted", _is_muted)

func get_is_muted():
	return _is_muted

func _get_sound_group_name(name_str : String):
	var last_underscore_idx = name_str.find_last("_")
	if last_underscore_idx > -1:
		var num_str = name_str.substr(last_underscore_idx + 1)
		if !num_str.is_valid_integer():
			return name_str
	return name_str.substr(0, last_underscore_idx)

func _get_sound_idx(name_str : String):
	var last_underscore_idx = name_str.find_last("_")
	if last_underscore_idx > -1:
		var num_str = name_str.substr(last_underscore_idx + 1)
		if !num_str.is_valid_integer():
			return name_str.to_int()
	return 0

func _reset_sounds_ids_for_random_play(group_name):
	_sounds_ids_for_random_play[group_name].clear()
	for idx in _sounds[group_name].size():
		_sounds_ids_for_random_play[group_name].append(idx)

func _add_sound_to_sounds(sound_group_name : String, sound_path : String):
	pass

func _play_sound(group_name : String, idx : int):
	pass
