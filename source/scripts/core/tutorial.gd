class_name Tutorial
extends Node

export(Array) var _quests_resources

var _current_quest_id : int = -1

func start_quest(quest_id : int):
	for res in _quests_resources:
		if res.get_id() == quest_id:
			_current_quest_id = quest_id
			res.start(get_tree().root)
			return

func start_next_quest():
	start_quest(_current_quest_id + 1)
