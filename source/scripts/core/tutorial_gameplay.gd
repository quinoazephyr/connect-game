class_name TutorialGameplay
extends Gameplay

signal all_dots_removed
signal game_restarted

func _ready():
	_dots.connect("all_dots_removed", self, "emit_signal", ["all_dots_removed"])

func start_new_game(colors_count):
	_dots.generate_new_tutorial()

func restart_game():
	_dots.connect("dots_regenerated", _dot_effects, \
			"_call_deferred_dots_regenerated", [], CONNECT_ONESHOT)
	start_new_game(0)
	emit_signal("game_restarted")
