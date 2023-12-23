class_name ConnectMovesAction
extends ActionBase

export(String) var _tutorial_scene_path
export(String) var _gameplay_path
export(String) var _moves_path

func fire(root : Node) -> void:
	var tutorial_scene = root.get_node(_tutorial_scene_path)
	var gameplay = root.get_node(_gameplay_path)
	var moves = root.get_node(_moves_path)
	
	gameplay.connect("dot_connected_no_args", moves, \
			"set_additional_moves", [-1])
	gameplay.connect("dot_connected_no_args", moves, \
			"show_add_moves_label", [true])
	gameplay.connect("dot_disconnected_no_args", moves, \
			"set_additional_moves", [-1])
	gameplay.connect("dots_connected_loop", tutorial_scene, \
			"_set_additional_moves_minus_one")
	gameplay.connect("dots_removed_no_args", moves, "add_moves", [-1])
	gameplay.connect("dots_removed_loop", moves, "add_moves")
	gameplay.connect("game_restarted", moves, "set_moves", [2])

