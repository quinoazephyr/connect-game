class_name ClearAllDotsGoal
extends QuestGoalBase

export(String) var _gameplay_path

var _gameplay

func start(root_node : Node) -> void:
	_gameplay = root_node.get_node(_gameplay_path)
	_gameplay.connect("all_dots_removed", self, "complete")

func complete() -> void:
	_gameplay.disconnect("all_dots_removed", self, "complete")
	.complete()
