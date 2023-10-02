class_name ConnectMovesAction
extends ActionBase

export(String) var _dots_path
export(String) var _moves_path
export(String) var _game_input_path

func fire(root : Node) -> void:
	var moves = root.get_node(_moves_path)
	var dots = root.get_node(_dots_path)
	var game_input = root.get_node(_game_input_path)
	
	dots.connect("dot_connected", moves, "_on_dot_connected")
	dots.connect("dot_disconnected", moves, "_on_dot_connected")
	dots.connect("dots_looped", moves, "_on_dots_looped")
	dots.connect("dots_connected_removed", moves, "_on_dots_removed")
	
	game_input.connect("input_just_released", moves, "_on_input_release")
