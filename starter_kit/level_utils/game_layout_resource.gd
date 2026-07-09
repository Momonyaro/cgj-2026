class_name GameLayoutResource extends Resource

@export var _main_menu: PackedScene
@export var _levels: Array[LevelResource]
@export var _game_over: PackedScene
@export var _end_screen: PackedScene

# ---- Public Functions ----

func get_main_menu() -> PackedScene:
	return _main_menu

func get_levels() -> Array[LevelResource]:
	return _levels

func get_game_over() -> PackedScene:
	return _game_over

func get_end_screen() -> PackedScene:
	return _end_screen