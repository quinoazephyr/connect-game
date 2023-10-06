class_name PlayGameButton
extends Button

export(NodePath) var _scene_root_path
export(String, FILE, "*.tscn") var _main_scene_file_path

func _enter_tree():
	TransitionAutoload.connect("transition_hid_screen", self, "_change_scene")
	connect("pressed", TransitionAutoload, "show_transition")

func _exit_tree():
	TransitionAutoload.disconnect("transition_hid_screen", self, "_change_scene")
	disconnect("pressed", TransitionAutoload, "show_transition")

func _change_scene():
	var scene_root = get_node(_scene_root_path)
	SceneChangerAutoload.change_scene(scene_root.get_path(), \
			_main_scene_file_path)
