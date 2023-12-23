class_name ClearPlayerPrefsButton
extends Button

func _ready():
	connect("pressed", PlayerPrefsAutoload, "clear_all")
