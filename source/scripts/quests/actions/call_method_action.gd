class_name CallMethodAction
extends ActionBase

export(String) var _target_node_path
export(String) var _method
export(Array) var _arguments
export(float) var _delay

func fire(root : Node) -> void:
	root.get_tree().create_timer(_delay)\
			.connect("timeout", \
			root.get_node(_target_node_path), \
			"callv", [_method, _arguments])
