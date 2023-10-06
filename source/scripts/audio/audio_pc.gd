class_name AudioPC
extends AudioBase

onready var _sound_manager = .get_tree().root.get_node("SoundManager")

func _add_sound_to_sounds(sound_group_name : String, sound_path : String):
	_sounds[sound_group_name].append(load(sound_path))

func _play_sound(group_name : String, idx : int):
	_sound_manager.play_sound(_sounds[group_name][idx])
