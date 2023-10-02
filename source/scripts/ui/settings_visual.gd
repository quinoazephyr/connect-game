class_name SettingsVisual
extends Node

export(NodePath) var _settings_path
export(NodePath) var _settings_button_visual_path
export(NodePath) var _menu_visual_path

onready var _settings = get_node(_settings_path)
onready var _settings_button_visual = get_node(_settings_button_visual_path)
onready var _menu_visual = get_node(_menu_visual_path)

func _ready():
	_settings_button_visual.connect("button_pressed", self, "_toggle_menu")

func _toggle_menu():
	var old_menu_visible = _menu_visual.is_menu_visible()
	var new_menu_visible = !old_menu_visible
	
	_settings._game_input.enable_input(false)
	_settings_button_visual.play_animation(new_menu_visible)
	if old_menu_visible:
		_menu_visual.play_hide_menu_animation()
		var tween = get_tree().create_tween()
		tween.tween_callback(_menu_visual, "set_menu_visible", [new_menu_visible])\
				.set_delay(_menu_visual.get_hide_animation_duration())
		tween.tween_callback(_settings._game_input, "enable_input", [true])
	else:
		_menu_visual.set_menu_visible(new_menu_visible)
