class_name QuestBase
extends Resource

signal started
signal finished

enum State {
	PENDING, # not started yet
	IN_PROGRESS, # shown to the player and started
	FINISHED, # finished
}

export(int) var _id = -1
export(String) var _title
export(String, MULTILINE) var _description
export(Array) var _goals # [QuestGoalBase]

export(Array) var _actions_on_start # [ActionBase]
export(Array) var _actions_on_finish # [ActionBase]

var id setget , get_id
var title setget , get_title
var description setget , get_description
var state setget , get_state
var goals setget , get_goals

var _state : int # State
var _goals_completed : int = 0

func _init() -> void:
	_state = State.PENDING

func start(root_node : Node) -> void:
	_state = State.IN_PROGRESS
	for goal in _goals:
		goal.start(root_node)
		goal.connect("completed", self, "_on_goal_completed")
	_fire_actions(root_node, _actions_on_start)
	connect("finished", self, "_fire_actions", [root_node, _actions_on_finish])
	
	emit_signal("started")
	_try_finish_quest()

func force_finish() -> void:
	emit_signal("finished")

func get_id():
	return _id

func get_title():
	return _title

func get_description():
	return _description

func get_state():
	return _state

func get_goals():
	return _goals

func _fire_actions(root_node : Node, actions : Array) -> void:
	for action in actions:
		action.fire(root_node)

func _on_goal_completed() -> void:
	_goals_completed += 1
	_try_finish_quest()

func _try_finish_quest():
	if _goals_completed == _goals.size():
		emit_signal("finished")
