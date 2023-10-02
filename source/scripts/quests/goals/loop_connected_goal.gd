class_name LoopConnectedGoal
extends QuestGoalBase

export(String) var _dots_path
export(String) var _dots_effects_path
export(String) var _moves_path

var _dots
var _dots_effects
var _moves

func start(root_node : Node) -> void:
	_dots = root_node.get_node(_dots_path)
	_dots_effects = root_node.get_node(_dots_effects_path)
	_moves = root_node.get_node(_moves_path)
	_dots.connect("dots_connected_removed", self, "_on_loop_dots_removed")
	_dots.disconnect("dots_moved", _dots_effects, "_move_dots_down")

func complete() -> void:
	_dots.disconnect("dots_connected_removed", self, "_on_loop_dots_removed")
	.complete()

func _on_loop_dots_removed(dots : Array):
	if !Dots.is_loop_exists(dots) || \
			Dots.get_dot_count_between_dots(dots, dots.back(), dots.back()) \
			< Dots._DOTS_SPECIAL_LOOP_MIN_COUNT:
		for dot in dots:
			_dots_effects._disappear_dot(dot)
		for dot in _dots._dots:
			if dot:
				_dots_effects._disappear_dot(dot)
		call_deferred("_spawn_dots")
		_moves.call_deferred("set_moves", 1)
		return
	
	_dots.connect("dots_moved", _dots_effects, "_move_dots_down")
	complete()

func _spawn_dots():
	_dots.spawn_dots_step(3)
	for dot in _dots._dots:
		var final_scale = dot.scale
		var initial_position = dot.position - \
				Vector2(dot._sprite.texture.get_width(), \
				dot._sprite.texture.get_height()) * \
				dot.scale * -0.5
		var final_position = dot.position
		var time = 0.2
		
		var tween = _dots.get_tree().create_tween().set_parallel()
		tween.tween_property(dot, "scale", final_scale, time).from(Vector2.ZERO)
		tween.tween_property(dot, "position", final_position, time).from(initial_position)
