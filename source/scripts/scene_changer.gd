class_name SceneChanger
extends Node

signal scene_changing(current_scene_root, next_scene_root)

# change scene with no callback
func change_scene(current_scene_root_path : String, \
		next_scene_file_path : String):
	var next_scene = _load_next_scene(next_scene_file_path)
	if next_scene:
		var current_scene_root = get_node(current_scene_root_path)
		emit_signal("scene_changing", next_scene, current_scene_root)
		call_deferred("_remove_scene", current_scene_root_path)

# add next scene to root (use it with remove_scene(current_scene_root_path))
# var next_scene = load_next_scene(next_scene_file_path)
# some_cleanup_and_data_transfer(current_scene_root, next_scene)
# remove_scene(current_scene_root_path)
func _load_next_scene(next_scene_file_path : String):
	if ResourceLoader.exists(next_scene_file_path):
		var next_scene = ResourceLoader.load(next_scene_file_path).instance()
		var root = get_tree().root
		root.add_child(next_scene)
		return next_scene
	return null

# remove scene from root (use it with load_next_scene(next_scene_file_path))
func _remove_scene(scene_root_path : String):
	var scene_root = get_node(scene_root_path)
	var root = get_tree().root
	root.remove_child(scene_root)
	scene_root.queue_free()
