class_name MenuVisual
extends Node

onready var _menu = $Menu
onready var _animation_player = $AnimationPlayer

func _ready():
	set_menu_visible(false)
	_menu.call_deferred("connect", "visibility_changed", self, "_on_visibility_changed")

func set_menu_visible(is_visible : bool):
	_menu.visible = is_visible

func is_menu_visible():
	return _menu.visible

func play_show_menu_animation():
	var anim_str = "menu_show"
	_animation_player.play(anim_str)

func play_hide_menu_animation():
	var anim_str = "menu_show"
	_animation_player.play_backwards(anim_str)

func get_hide_animation_duration():
	return _animation_player.get_animation("menu_show").length

func _on_visibility_changed():
	if is_menu_visible():
		play_show_menu_animation()
