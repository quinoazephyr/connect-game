class_name GameInput
extends Node

signal input_motion_drag(mouse_pos)
signal input_motion(mouse_pos)
signal input_just_pressed(mouse_pos)
signal input_just_released(mouse_pos)

const _TAP_ACTION = "tap"

var _is_input_enabled : bool
var _is_pressed : bool

onready var _canvas_item = $CanvasLayer/Control # for accurate mouse_pos

func _ready():
	enable_input(true)

func _input(event):
	if !_is_input_enabled:
		return
	
	var mouse_pos = _canvas_item.get_global_mouse_position()
	if event is InputEventMouseMotion:
		if Input.is_action_pressed(_TAP_ACTION):
			emit_signal("input_motion_drag", mouse_pos)
		else:
			emit_signal("input_motion", mouse_pos)
	elif Input.is_action_just_pressed(_TAP_ACTION):
		emit_signal("input_just_pressed", mouse_pos)
	elif Input.is_action_just_released(_TAP_ACTION):
		emit_signal("input_just_released", mouse_pos)

func enable_input(enable : bool):
	_is_input_enabled = enable
