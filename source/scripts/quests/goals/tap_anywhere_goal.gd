class_name TapAnywhereGoal
extends QuestGoalBase

export(String) var _game_input_path

var _game_input

func start(root_node : Node) -> void:
	_game_input = root_node.get_node(_game_input_path)
	_game_input.connect("input_just_released", \
			self, "_catch_input_just_released")

func complete() -> void:
	_game_input.disconnect("input_just_released", \
			self, "_catch_input_just_released")
	.complete()

func _catch_input_just_released(mouse_pos):
	complete()
