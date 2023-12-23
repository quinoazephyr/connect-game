class_name PlayGameButton
extends SceneChangerButton

var label setget , get_label

onready var _label = $Label

func get_label():
	return _label
