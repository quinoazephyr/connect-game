class_name SoundEffects
extends Node

signal sound_muted(is_muted)

enum SoundsIndices {
	CONNECT,
	DISCONNECT,
	REMOVED,
	LOOP_SELECTED,
	INTERFACE,
	ALL
}

export(Array) var _connect_sounds_rsc
export(Array) var _disconnect_sounds_rsc
export(Array) var _removed_sounds_rsc
export(Array) var _loop_selected_sounds_rsc
export(Array) var _interface_sounds_rsc

var _sounds : Array # Array[Array]
var _sounds_paths : Array # Array[Array]
var _cur_sounds_ids : Array # Array[Array]
var _is_muted : bool = true

onready var _sound_manager = $SoundManager
onready var _sounds_js_wrapper = $SoundsJSWrapper

func load_sounds():
	for idx in SoundsIndices.ALL:
		_sounds.append([])
		_cur_sounds_ids.append([])
		_sounds_paths.append([])
	
	for rsc in _connect_sounds_rsc:
		_sounds[SoundsIndices.CONNECT].append(load(rsc.resource_path))
		_sounds_paths[SoundsIndices.CONNECT]\
				.append(_change_extension(rsc.resource_path, "mp3")\
				.trim_prefix("res://"))
	for rsc in _disconnect_sounds_rsc:
		_sounds[SoundsIndices.DISCONNECT].append(load(rsc.resource_path))
		_sounds_paths[SoundsIndices.DISCONNECT]\
				.append(_change_extension(rsc.resource_path, "mp3")\
				.trim_prefix("res://"))
	for rsc in _removed_sounds_rsc:
		_sounds[SoundsIndices.REMOVED].append(load(rsc.resource_path))
		_sounds_paths[SoundsIndices.REMOVED]\
				.append(_change_extension(rsc.resource_path, "mp3")\
				.trim_prefix("res://"))
	for rsc in _loop_selected_sounds_rsc:
		_sounds[SoundsIndices.LOOP_SELECTED].append(load(rsc.resource_path))
		_sounds_paths[SoundsIndices.LOOP_SELECTED]\
				.append(_change_extension(rsc.resource_path, "mp3")\
				.trim_prefix("res://"))
	for rsc in _interface_sounds_rsc:
		_sounds[SoundsIndices.INTERFACE].append(load(rsc.resource_path))
		_sounds_paths[SoundsIndices.INTERFACE]\
				.append(_change_extension(rsc.resource_path, "mp3")\
				.trim_prefix("res://"))

func load_sounds_to_js():
	_sounds_js_wrapper.load_sounds_to_js(_sounds_paths)

func mute(is_muted : bool):
	_mute(is_muted)

func is_muted():
	return _is_muted

func _mute(is_muted : bool):
	if is_muted == _is_muted:
		return
	_is_muted = is_muted
	emit_signal("sound_muted", _is_muted)

func _play_connection_effect(dot : Dot):
	var sound_idx = _get_random_sound_idx(_sounds[SoundsIndices.CONNECT], \
			_cur_sounds_ids[SoundsIndices.CONNECT])
	if SoundsJSWrapper.is_html5():
		_sounds_js_wrapper.play_sound(SoundsIndices.CONNECT, sound_idx)
	else:
		_sound_manager.play_sound(_sounds[SoundsIndices.CONNECT][sound_idx])

func _play_disconnection_effect(dot : Dot):
	var sound_idx = _get_random_sound_idx(_sounds[SoundsIndices.DISCONNECT], \
			_cur_sounds_ids[SoundsIndices.DISCONNECT])
	if SoundsJSWrapper.is_html5():
		_sounds_js_wrapper.play_sound(SoundsIndices.DISCONNECT, sound_idx)
	else:
		_sound_manager.play_sound(_sounds[SoundsIndices.DISCONNECT][sound_idx])

func _play_removed_effect(dots : Array):
	var sound_idx = _get_random_sound_idx(_sounds[SoundsIndices.REMOVED], \
			_cur_sounds_ids[SoundsIndices.REMOVED])
	if SoundsJSWrapper.is_html5():
		_sounds_js_wrapper.play_sound(SoundsIndices.REMOVED, sound_idx)
	else:
		_sound_manager.play_sound(_sounds[SoundsIndices.REMOVED][sound_idx])

func _play_loop_selected_effect(dots : Array):
	var sound_idx = _get_random_sound_idx(_sounds[SoundsIndices.LOOP_SELECTED], \
			_cur_sounds_ids[SoundsIndices.LOOP_SELECTED])
	if SoundsJSWrapper.is_html5():
		_sounds_js_wrapper.play_sound(SoundsIndices.LOOP_SELECTED, sound_idx)
	else:
		_sound_manager.play_sound(_sounds[SoundsIndices.LOOP_SELECTED][sound_idx])

func _play_interface_click_sound():
	var sound_idx = 0
	if SoundsJSWrapper.is_html5():
		_sounds_js_wrapper.play_sound(SoundsIndices.INTERFACE, sound_idx)
	else:
		_sound_manager.play_sound(_sounds[SoundsIndices.INTERFACE][sound_idx])

func _play_interface_confirm_sound():
	var sound_idx = 1
	if SoundsJSWrapper.is_html5():
		_sounds_js_wrapper.play_sound(SoundsIndices.INTERFACE, sound_idx)
	else:
		_sound_manager.play_sound(_sounds[SoundsIndices.INTERFACE][sound_idx])

func _get_random_sound_idx(sounds : Array, cur_sounds_ids : Array):
	if cur_sounds_ids.size() == 0:
		for i in sounds.size():
			cur_sounds_ids.append(i)
	
	var sound_idx = cur_sounds_ids[randi() % cur_sounds_ids.size()]
	cur_sounds_ids.erase(sound_idx)
	return sound_idx

func _get_resource_filename(path : String):
	var fname = path.substr(path.find_last("/") + 1)
	return fname

func _change_extension(fname : String, new_ext : String):
	return "%s.%s" % [fname.substr(0, fname.find_last(".")), new_ext]
