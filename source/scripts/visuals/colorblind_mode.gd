class_name ColorblindMode
extends Node

signal colorblind_changed(is_enabled)

export(Array) var _icons

var is_active setget, _is_mode_active

var _is_active : bool = false

func activate_mode(is_enabled : bool):
	_is_active = is_enabled
	emit_signal("colorblind_changed", is_enabled)

func get_texture(idx : int):
	return _icons[idx]

func _is_mode_active():
	return _is_active
