class_name QuestGoalBase
extends Resource

signal completed

export(String) var _title
export(String, MULTILINE) var _description

var title setget , get_title
var description setget , get_description

func start(root_node : Node) -> void:
	pass

func complete() -> void:
	emit_signal("completed")

func get_title():
	return _title

func get_description():
	return _description
