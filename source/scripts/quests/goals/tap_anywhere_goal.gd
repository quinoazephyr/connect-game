class_name TapAnywhereGoal
extends QuestGoalBase

export(String) var _input_observer_path # Control

var _root
var _input_observer

func start(root_node : Node) -> void:
	_root = root_node
	_input_observer = _root.get_node(_input_observer_path)
	_input_observer.connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event : InputEvent):
	if Input.is_action_just_pressed("tap"):
		complete()

func complete() -> void:
	_input_observer.disconnect("gui_input", self, "_on_gui_input")
	.complete()
