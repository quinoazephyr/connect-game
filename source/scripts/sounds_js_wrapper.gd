class_name SoundsJSWrapper
extends Node

const _FEATURE_NAME = "HTML5"

onready var _html_window = JavaScript.get_interface("window")

static func is_html5():
	return OS.has_feature(_FEATURE_NAME)

func play_sound(sound_type : int, sound_idx : int):
	if !is_html5():
		return
	
	var sound_type_js = JavaScript.create_object("Number")
	sound_type_js = sound_type
	var sound_idx_js = JavaScript.create_object("Number")
	sound_idx_js = sound_idx
	_html_window.PlaySound(sound_type_js, sound_idx_js)

func mute_sound(sound_type : int, sound_idx : int, is_muted : bool):
	if !is_html5():
		return
	
	var sound_type_js = JavaScript.create_object("Number")
	sound_type_js = sound_type
	var sound_idx_js = JavaScript.create_object("Number")
	sound_idx_js = sound_idx
	var is_muted_js = JavaScript.create_object("Boolean")
	is_muted_js = is_muted
	_html_window.MuteSound(sound_type_js, sound_idx_js, is_muted_js)

func mute_sounds(sound_type : int, is_muted : bool):
	if !is_html5():
		return
	
	var sound_type_js = JavaScript.create_object("Number")
	sound_type_js = sound_type
	var is_muted_js = JavaScript.create_object("Boolean")
	is_muted_js = is_muted
	_html_window.MuteSounds(sound_type_js, is_muted_js)

func mute_all_sounds(is_muted : bool):
	if !is_html5():
		return
	
	var is_muted_js = JavaScript.create_object("Boolean")
	is_muted_js = is_muted
	_html_window.MuteAllSounds(is_muted_js)

func load_sounds_to_js(typed_sounds_paths : Array):
	if !is_html5():
		return
	
	var typed_sounds_paths_js = \
			JavaScript.create_object("Array", typed_sounds_paths.size())
	for i in typed_sounds_paths.size():
		var sounds_paths_js = \
				JavaScript.create_object("Array", typed_sounds_paths[i].size())
		for j in typed_sounds_paths[i].size():
			sounds_paths_js[j] = typed_sounds_paths[i][j]
		typed_sounds_paths_js[i] = sounds_paths_js
	_html_window.LoadSounds(typed_sounds_paths_js)
