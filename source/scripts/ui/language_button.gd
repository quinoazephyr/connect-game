class_name LanguageButton
extends Button

export(NodePath) var _language_changer_path

onready var _language_changer = get_node(_language_changer_path)

func _ready():
	connect("pressed", _language_changer, "set_next_language")
