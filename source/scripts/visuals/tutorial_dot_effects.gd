class_name TutorialDotEffects
extends Node

export(NodePath) var _dots_path

onready var _dots = get_node(_dots_path)
onready var _effects_ui_parent = $CanvasLayer/Control
onready var _add_moves_labels = $CanvasLayer/Control/AdditionalMovesLabels

func _ready():
	_dots.connect("dot_connected", self, "_ripple_dot")
	_dots.connect("dots_removed", self, "_disappear_dots")
	_dots.connect("dots_selected", self, "_ripple_dots_with_color")
	_dots.connect("dots_moved", self, "_move_dots_down")
	_dots.connect("dots_connected_removed", self, "_on_loop_dots_removed")

func _ripple_dots_with_color(dots : Array):
	for dot in dots:
		_ripple_dot(dot)

func _ripple_dot(dot : Dot):
	var ripple_sprite = dot._sprite.duplicate()
	dot.add_child(ripple_sprite)
	
	var final_color = ripple_sprite.self_modulate * Color.transparent
	var scale_addition = 1.5
	var final_scale = ripple_sprite.scale * (1.0 + scale_addition)
	var final_position = ripple_sprite.position - \
			Vector2(dot._sprite.texture.get_width(), \
			dot._sprite.texture.get_height()) * \
			ripple_sprite.scale * scale_addition * 0.5
	var time = 0.5
	
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(ripple_sprite, "self_modulate", final_color, time)
	tween.tween_property(ripple_sprite, "position", final_position, time)
	tween.tween_property(ripple_sprite, "scale", final_scale, time)
	tween.tween_callback(ripple_sprite, "queue_free").set_delay(time)

func _disappear_dots(dots : Array):
	for dot in dots:
		_disappear_dot(dot)

func _disappear_dot(dot : Dot):
	var scale_addition = -1.0
	var final_scale = dot.scale * (1.0 + scale_addition)
	var final_position = dot.position - \
			Vector2(dot._sprite.texture.get_width(), \
			dot._sprite.texture.get_height()) * \
			dot.scale * scale_addition * 0.5
	var time = 0.1
	
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(dot, "position", final_position, time)
	tween.tween_property(dot, "scale", final_scale, time)
	tween.tween_callback(dot, "queue_free").set_delay(time)

func _move_dots_down(existing_dots, new_dots):
	var columns_count = _dots._dots_positions[_dots._current_step_idx].columns
	
	var movement_duration = 0.3
	var movement_delay = 0.0
	
	var tween_disable_input = get_tree().create_tween()
	tween_disable_input.tween_callback(_dots._game_input, \
			"enable_input", [false]).set_delay(movement_delay)
	
	var dots_to_move : Array
	dots_to_move.append_array(existing_dots)
	
	dots_to_move.sort_custom(self, "_sort_dots_by_row")
	for dot in dots_to_move:
		_move_dot_to_row(dot, dot.column, dot.row, \
				movement_duration, movement_delay, false)
	
	var tween_enable_input = get_tree().create_tween()
	tween_enable_input.tween_callback(_dots._game_input, \
			"enable_input", [true]).set_delay(movement_duration + movement_delay)

func _sort_dots_by_row(a : Dot, b : Dot):
	return a.row < b.row

func _move_dot_to_row(dot : Dot, column : int, target_row : int, \
		duration : float, delay : float = 0.0, is_from_current : bool = true):
	var columns_count = _dots._dots_positions[_dots._current_step_idx].columns
	var target_child = _dots._get_idx(columns_count, target_row, column)
	var target_position = \
			_dots._dots_positions[_dots._current_step_idx].get_child(target_child).rect_global_position
	var new_global_position = target_position
	var tween = get_tree().create_tween()
	if is_from_current:
		tween.tween_property(dot, "global_position", new_global_position, duration)\
				.from_current()\
				.set_trans(Tween.TRANS_BOUNCE)\
				.set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(dot, "global_position", new_global_position, duration)\
				.set_trans(Tween.TRANS_BOUNCE)\
				.set_ease(Tween.EASE_OUT)

func _on_loop_dots_removed(dots : Array):
	if !Dots.is_loop_exists(dots):
		return
	
	var dot_count_in_loop = 0
	for dot in dots:
		dot_count_in_loop = \
				max(dot_count_in_loop, \
				Dots.get_dot_count_between_dots(dots, dot, dot))
	
	var labels = _add_moves_labels
	_add_moves_labels.visible = true
	
	labels.set_moves_count(dot_count_in_loop)
	var last_dot = dots.back()
	var labels_rect_position = last_dot.position + Vector2(38.0, -35.0 - 32.0 + 12.0)
	if labels_rect_position.x + labels.rect_size.x > \
			_effects_ui_parent.rect_size.x - 100.0:
		labels_rect_position = last_dot.position + \
				Vector2(-labels.rect_size.x, -35.0 - 32.0 + 12.0)
	labels.rect_position = labels_rect_position
	
	var tween = get_tree().create_tween()
	tween.tween_property(labels, "rect_position", labels.rect_position + Vector2(0.0, -20.0), 1.0)
	tween.tween_callback(labels, "set_visible", [false])

func _get_key_moves_str(moves_count : int):
	return DotEffects._KEYS_MOVES[int(clamp(moves_count, \
			0, DotEffects._KEYS_MOVES.size()))]
