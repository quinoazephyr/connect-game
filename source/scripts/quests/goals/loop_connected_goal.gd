class_name LoopConnectedGoal
extends QuestGoalBase

export(String) var _gameplay_path

var _gameplay

func start(root_node : Node) -> void:
	_gameplay = root_node.get_node(_gameplay_path)
	_gameplay.connect("dots_removed_special_loop_no_args", \
			self, "complete")
	
	_gameplay.connect("dots_removed_no_args", self, "_regenerate_gameplay")

func complete() -> void:
	_gameplay.disconnect("dots_removed_no_args", self, "_regenerate_gameplay")
	_gameplay.disconnect("dots_removed_special_loop_no_args", \
			self, "complete")
	.complete()

func _regenerate_gameplay():
	_gameplay.restart_game()
