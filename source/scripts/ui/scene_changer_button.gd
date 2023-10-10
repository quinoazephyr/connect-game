class_name SceneChangerButton
extends Button

export(NodePath) var _current_scene_root_path
export(String, FILE, "*.tscn") var _next_scene_file_path

func _enter_tree():
	connect("pressed", self, "_change_scene")
#
func _exit_tree():
	disconnect("pressed", self, "_change_scene")

func _change_scene():
	var scene_root = get_node(_current_scene_root_path)
	SceneChangerAutoload.change_scene(scene_root.get_path(), \
			_next_scene_file_path)
