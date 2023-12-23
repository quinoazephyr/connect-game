class_name HowlerJS
extends Node

const SINGLETON_NAME = "HowlerJSAutoload"
const FEATURE_NAME = "howler"

onready var _html_window = JavaScript.get_interface("window")

static func is_howler():
	return OS.has_feature(FEATURE_NAME)

func play_sound(sound_idx : int):
	if !is_howler():
		return
	
	var sound_idx_js = JavaScript.create_object("Number")
	sound_idx_js = sound_idx
	_html_window.PlaySound(sound_idx_js)

func mute_sound(sound_idx : int, is_muted : bool):
	if !is_howler():
		return
	
	var sound_idx_js = JavaScript.create_object("Number")
	sound_idx_js = sound_idx
	var is_muted_js = JavaScript.create_object("Boolean")
	is_muted_js = is_muted
	_html_window.MuteSound(sound_idx_js, is_muted_js)

func mute_all_sounds(is_muted : bool):
	if !is_howler():
		return
	
	var is_muted_js = JavaScript.create_object("Boolean")
	is_muted_js = is_muted
	_html_window.MuteAllSounds(is_muted_js)

func load_sounds(sounds_paths : Array):
	if !is_howler():
		return
	
	var sounds_paths_js = \
			JavaScript.create_object("Array", sounds_paths.size())
	for i in sounds_paths.size():
		sounds_paths_js[i] = sounds_paths[i]
	_html_window.LoadSounds(sounds_paths_js)
