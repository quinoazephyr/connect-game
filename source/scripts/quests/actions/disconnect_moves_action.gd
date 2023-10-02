class_name DisconnectMovesAction
extends ActionBase

export(String) var _dots_path
export(String) var _moves_path
export(String) var _game_input_path

func fire(root : Node) -> void:
	var moves = root.get_node(_moves_path)
	var dots = root.get_node(_dots_path)
	var game_input = root.get_node(_game_input_path)
	
	dots.disconnect("dot_connected", moves, "_on_dot_connected")
	dots.disconnect("dot_disconnected", moves, "_on_dot_connected")
	dots.disconnect("dots_looped", moves, "_on_dots_looped")
	dots.disconnect("dots_connected_removed", moves, "_on_dots_removed")
	
	game_input.disconnect("input_just_released", moves, "_on_input_release")
