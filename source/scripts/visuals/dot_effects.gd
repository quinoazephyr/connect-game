class_name DotEffects
extends Node

onready var _effects_ui_parent = $CanvasLayer/Control
onready var _new_dots_positions_parent = $CanvasLayer/NewDotsPositions
onready var _fullscreen_color_rect = $CanvasLayer/Control/ColorRect
onready var _add_moves_labels = $CanvasLayer2/Control/AdditionalMovesLabels

func _ready():
	_fullscreen_color_rect.visible = false

func wiggle_dot(dot : Dot):
	var old_scale = dot.scale
	var old_position = dot.position
	var scale_addition = 0.2
	var new_scale = old_scale * (1.0 + scale_addition)
	var new_position = old_position - \
			Vector2(dot._sprite.texture.get_width(), \
			dot._sprite.texture.get_height()) * \
			old_scale * scale_addition * 0.5
	var half_time = 0.2
	
	var tween_in = get_tree().create_tween().set_parallel()
	tween_in.tween_property(dot, "scale", new_scale, half_time)
	tween_in.tween_property(dot, "position", new_position, half_time)
	
	var tween_out = get_tree().create_tween().set_parallel()
	tween_out.tween_property(dot, "scale", old_scale, half_time) \
			.set_delay(half_time).from(new_scale)
	tween_out.tween_property(dot, "position", old_position, half_time) \
			.set_delay(half_time).from(new_position)

func ripple_dots_with_color(dots : Array):
	for dot in dots:
		ripple_dot(dot)
	var dot_color = dots.front().color
	var color_rect_color = Color(dot_color.r, dot_color.g, dot_color.b, 0.1)
	_fullscreen_color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(_fullscreen_color_rect, "color", \
			color_rect_color, 0.2).from(Color(1.0, 1.0, 1.0, 0.0))

func ripple_dot(dot : Dot):
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

func disappear_dots(dots : Array):
	for dot in dots:
		disappear_dot(dot)
	_fullscreen_color_rect.visible = false

func disappear_dot(dot : Dot):
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

func move_dots_down(columns_count, existing_dots, existing_dots_target_positions,\
		new_dots, new_dots_target_positions):
	var movement_duration = 0.4
	var movement_delay = 0.0
	
#	var tween_disable_input = get_tree().create_tween()
#	tween_disable_input.tween_callback(_dots._game_input, \
#			"enable_input", [false]).set_delay(movement_delay)
	
	var columns_empty_ids_counter : Array
	for idx in columns_count:
		columns_empty_ids_counter.append(0)
	for dot in new_dots:
		columns_empty_ids_counter[dot.column] += 1
	
	var dots_to_move : Array
	var target_positions_and_rows : Array
	dots_to_move.append_array(existing_dots)
	
	for idx in existing_dots.size():
		target_positions_and_rows.append([
			existing_dots[idx].row, 
			existing_dots_target_positions[idx]
			])
	
	for idx in new_dots.size():
		var dot = new_dots[idx]
		var target_position = new_dots_target_positions[idx]
		var r = dot.row
		var c = dot.column
		var cur_empty_id = columns_empty_ids_counter[c]
		var delay = movement_duration * (cur_empty_id - 1) * 0.2
		
		_tween_dot_at_spawn_point(dot, delay)
		dots_to_move.append(dot)
		target_positions_and_rows.append([
			dot.row,
			target_position
			])
		
		columns_empty_ids_counter[c] -= 1
	
	dots_to_move.sort_custom(self, "_sort_dots_by_row")
	target_positions_and_rows.sort_custom(self, "_sort_target_positions_by_row")
	for idx in dots_to_move.size():
		var dot = dots_to_move[idx]
		var target_position = target_positions_and_rows[idx][1]
		move_dot_to_row(dot, target_position, movement_duration, 0.0)
	
#	var tween_enable_input = get_tree().create_tween()
#	tween_enable_input.tween_callback(_dots._game_input, \
#			"enable_input", [true]).set_delay(movement_duration + movement_delay)

func _sort_dots_by_row(a : Dot, b : Dot):
	return a.row < b.row

func _sort_target_positions_by_row(pos_a, pos_b):
	return pos_a[0] < pos_b[0]

func move_dot_to_row(dot : Dot, target_position : Vector2, \
		duration : float, delay : float = 0.0):
	var tween = get_tree().create_tween()
	tween.tween_property(dot, "global_position", target_position, duration)\
			.set_trans(Tween.TRANS_BOUNCE)\
			.set_ease(Tween.EASE_OUT)

func _tween_dot_at_spawn_point(dot : Dot, visibility_delay : float):
	var target_position = \
			_new_dots_positions_parent.get_child(dot.column).rect_global_position
	var tween = get_tree().create_tween()
	tween.tween_property(dot, "visible", false, 0.0)
	tween.tween_property(dot, "global_position", target_position, 0.0)
	tween.tween_property(dot, "visible", true, 0.0).set_delay(visibility_delay)

func on_loop_dots_removed(dots : Array):
	if !Dots.is_loop_special_exists(dots):
		return
	
	var dot_count_in_loop = 0
	for dot in dots:
		dot_count_in_loop = \
				max(dot_count_in_loop, \
				Dots.get_dot_count_between_dots(dots, dot, dot))

	var labels = _add_moves_labels
	labels.visible = true
	labels.set_moves_count(dot_count_in_loop - 1)
	var last_dot = dots.back()
	var labels_rect_position = last_dot.position + Vector2(38.0, -35.0 - 32.0 + 12.0)
	if labels_rect_position.x + labels.rect_size.x > \
			_effects_ui_parent.rect_size.x - 100.0:
		labels_rect_position = last_dot.position + \
				Vector2(-labels.rect_size.x, -35.0 - 32.0 + 12.0)
	labels.rect_position = labels_rect_position

	var tween = get_tree().create_tween()
	tween.tween_property(labels, "rect_position", \
			labels.rect_position + Vector2(0.0, -20.0), 1.0)
	tween.tween_callback(labels, "set_visible", [false])

func on_dot_disconnected(dot : Dot):
	_fullscreen_color_rect.visible = false
