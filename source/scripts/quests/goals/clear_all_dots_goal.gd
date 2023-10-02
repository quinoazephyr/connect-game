class_name ClearAllDotsGoal
extends QuestGoalBase

export(String) var _tutorial_dots_path

var _tutorial_dots

func start(root_node : Node) -> void:
	_tutorial_dots = root_node.get_node(_tutorial_dots_path)
	_tutorial_dots.connect("all_dots_removed", self, "complete")

func complete() -> void:
	_tutorial_dots.disconnect("all_dots_removed", self, "complete")
	.complete()
