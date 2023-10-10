class_name MenuVisual
extends Node

signal menu_opened
signal menu_closed

const _ANIMATION_TITLE = "menu_show"

onready var _menu = $Menu
onready var _animation_player = $AnimationPlayer

func _ready():
	connect("menu_closed", _menu, "set_visible", [false])

func open():
	if is_menu_visible():
		return
	_menu.visible = true
	play_show_menu_animation()
	get_tree().create_timer(get_show_animation_duration())\
			.connect("timeout", self, "call", ["emit_signal", "menu_opened"])

func close():
	if !is_menu_visible():
		return
	play_hide_menu_animation()
	get_tree().create_timer(get_show_animation_duration())\
			.connect("timeout", self, "call", ["emit_signal", "menu_closed"])

func set_menu_visible(is_visible):
	_menu.visible = is_visible

func is_menu_visible():
	return _menu.visible

func play_show_menu_animation():
	_animation_player.play(_ANIMATION_TITLE)

func play_hide_menu_animation():
	_animation_player.play_backwards(_ANIMATION_TITLE)

func get_show_animation_duration():
	return _animation_player.get_animation(_ANIMATION_TITLE).length
