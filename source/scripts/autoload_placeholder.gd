class_name AutoloadPlaceholder
extends Node

export(String) var _autoload_name
export(NodePath) var _node_to_copy_path

onready var _node_to_copy = get_node(_node_to_copy_path)

func _ready():
	var autoload_node = get_node("/root/" + _autoload_name)
	var autoload_prop_list = autoload_node.get_property_list()
	var script_variables = _get_script_variables(autoload_prop_list)
	
	_copy_properties_to_autoload(_node_to_copy, autoload_node, script_variables)
	
	if _node_to_copy.get_parent() != self:
		_node_to_copy.get_parent().remove_child(_node_to_copy)
		add_child(_node_to_copy)
	
	call_deferred("_remove_node", self)

func _get_script_variables(properties : Array):
	var script_variables = []
	for idx in range(properties.size(), 0, -1):
		var i = idx - 1
		var prop_name = properties[i]["name"]
		if (prop_name == "Script Variables"):
			break
		script_variables.append(properties[i])
	return script_variables

func _copy_properties_to_autoload(origin_node : Node, autoload_node : Node, \
		script_variables : Array):
	for prop in script_variables:
		var prop_name = prop["name"]
		var value = origin_node.get(prop_name)
		autoload_node.set(prop_name, value)

func _remove_node(node : Node):
	node.get_parent().remove_child(node)
	node.queue_free()
