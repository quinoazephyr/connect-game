class_name DisconnectMovesAction
extends ActionBase

export(String) var _tutorial_scene_path
export(String) var _gameplay_path
export(String) var _moves_path

func fire(root : Node) -> void:
	var tutorial_scene = root.get_node(_tutorial_scene_path)
	var gameplay = root.get_node(_gameplay_path)
	var moves = root.get_node(_moves_path)
	
	gameplay.disconnect("dot_connected_no_args", moves, \
			"set_additional_moves")
	gameplay.disconnect("dot_connected_no_args", moves, \
			"show_add_moves_label")
	gameplay.disconnect("dot_disconnected_no_args", moves, \
			"set_additional_moves")
	gameplay.disconnect("dots_connected_loop", tutorial_scene, \
			"_set_additional_moves_minus_one")
	gameplay.disconnect("dots_removed_no_args", moves, "add_moves")
	gameplay.disconnect("dots_removed_loop", moves, "add_moves")
	gameplay.disconnect("game_restarted", moves, "set_moves")
