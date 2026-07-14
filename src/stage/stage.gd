extends Node
class_name Stage

static var _singleton: Stage

static var level_loader: LevelLoader:
	get(): return _singleton._level_loader

var _level_loader: LevelLoader = null


func _enter_tree():
	if _singleton != null:
		_singleton.queue_free()
		_singleton = null
	_singleton = self

func _ready():
	_level_loader = $LevelLoader
