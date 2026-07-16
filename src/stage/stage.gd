extends Node

class_name Stage

const Audience = preload("res://src/shared/audience/audience.gd")

static var _singleton: Stage

static var level_loader: LevelLoader:
	get():
		return _singleton._level_loader
static var audience: Audience:
	get():
		return _singleton._audience
static var notes_board: NotesBoard:
	get():
		return _singleton._notes_board

var _level_loader: LevelLoader = null
var _audience: Audience = null
var _notes_board: NotesBoard = null
var _left_spot_light: WindableItem = null
var _right_spot_light: WindableItem = null


func _enter_tree():
	if _singleton != null:
		_singleton.queue_free()
		_singleton = null
	_singleton = self


func _ready():
	_level_loader = $LevelLoader
	_audience = $"Audience"
	_notes_board = $NotesBoard
	_left_spot_light = $SpotLightLeft
	_right_spot_light = $SpotLightRight
