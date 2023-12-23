class_name FadeOutNode
extends ActionBase

export(String) var _node_path
export(float) var _duration

func fire(root : Node) -> void:
	var node = root.get_node(_node_path)
	var initial_color = node.self_modulate
	var clear_color = Color(initial_color.r, initial_color.g, initial_color.b, \
			0.0)
	var tween = root.get_tree().create_tween()
	tween.tween_property(node, "self_modulate", clear_color, _duration)\
			.from(initial_color)
