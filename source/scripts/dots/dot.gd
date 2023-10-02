class_name Dot
extends Node2D

var color_id setget , _get_color_id
var color setget , _get_color
var colorblind_sprite setget , _get_colorblind_sprite
var center_position setget , _get_center_position

var row setget , _get_row
var column setget , _get_column

var _row
var _column

onready var _sprite = $Sprite2D
onready var _collision_sprite = $CollisionSprite
onready var _colorblind_sprite = $ColorblindSprite

func initialize(t_row, t_column, t_color_id, t_colorblind_texture):
	_row = t_row
	_column = t_column
	_sprite.self_modulate = Color(t_color_id)
	_colorblind_sprite.texture = t_colorblind_texture

func is_contains_mouse(mouse_pos : Vector2):
	return _collision_sprite.get_rect().has_point(_collision_sprite.to_local(mouse_pos))

func show_colorblind_sprite(show : bool):
	_colorblind_sprite.visible = show

func _get_color_id():
	return self.color.to_html()

func _get_color():
	return _sprite.self_modulate

func _get_colorblind_sprite():
	return _colorblind_sprite.texture

func _get_center_position():
	return position + \
			Vector2(_sprite.texture.get_width(), \
			_sprite.texture.get_height()) * scale / 2.0

func _get_row():
	return _row

func _get_column():
	return _column
