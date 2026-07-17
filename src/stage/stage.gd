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

static var left_spot_light: WindableItem:
	get():
		return _singleton._left_spot_light

static var right_spot_light: WindableItem:
	get():
		return _singleton._right_spot_light

static var camera_shake: CameraShake3D:
	get():
		return _singleton._camera_shake
		
static var cursor: Cursor:
	get():
		return _singleton._cursor

var _level_loader: LevelLoader = null
var _audience: Audience = null
var _notes_board: NotesBoard = null
var _left_spot_light: WindableItem = null
var _right_spot_light: WindableItem = null
var _camera_shake: CameraShake3D = null
var _cursor: Cursor

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
	_camera_shake = $Camera3D/CameraShake3D
	_cursor = $Cursor


static func reset_spotlights() -> void:
	left_spot_light.reset()
	right_spot_light.reset()
