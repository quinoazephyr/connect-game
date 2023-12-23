class_name LogPlayerPrefsButton
extends Button

func _ready():
	connect("pressed", self, "log_player_prefs")

func log_player_prefs():
	print(PlayerPrefsAutoload._settings)
