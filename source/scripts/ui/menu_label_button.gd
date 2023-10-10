class_name MenuLabelButton
extends AnimatedLabelButton

const _ANIMATION_SHOW_LABEL_TITLE = "show_label"

export(NodePath) var _menu_node_path

var _tween_rotate_gear

onready var _menu = get_node(_menu_node_path)

func _ready():
	_menu.connect("menu_closed", _label_button, "set_visible", [false])
	connect("pressed", self, "toggle_menu")
	_label_button.visible = _menu.is_menu_visible()

func toggle_menu():
	if _menu.is_menu_visible():
		_close_menu()
	else:
		_open_menu()

func set_menu_visible_no_effects(is_visible):
	_menu.set_menu_visible(is_visible)
	_label_button.visible = is_visible

func _open_menu():
	_label_button.visible = true
	_animation_player.play(_ANIMATION_SHOW_LABEL_TITLE)
	
	if _tween_rotate_gear:
		_tween_rotate_gear.kill()
	_tween_rotate_gear = create_tween()
	_tween_rotate_gear.tween_property(_button, "rect_rotation", 180.0, \
			_animation_player.get_animation(_ANIMATION_SHOW_LABEL_TITLE).length)\
			.from(0.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	_menu.open()

func _close_menu():
	_animation_player.play_backwards(_ANIMATION_SHOW_LABEL_TITLE)
	
	if _tween_rotate_gear:
		_tween_rotate_gear.kill()
	_tween_rotate_gear = create_tween()
	_tween_rotate_gear.tween_property(_button, "rect_rotation", -180.0, \
			_animation_player.get_animation(_ANIMATION_SHOW_LABEL_TITLE).length)\
			.from(0.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	_menu.close()
