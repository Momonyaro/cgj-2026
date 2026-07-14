extends Node

var _game_layout: GameLayoutResource
var _initialized: bool

# ---- Godot Events ----

func _enter_tree() -> void:
	var project_setting_exists := ProjectSettings.has_setting("application/resources/game_layout")
	if project_setting_exists:
		var path: String = ProjectSettings.get_setting("application/resources/game_layout")
		if path != "" && FileAccess.file_exists(path):
			_game_layout = ResourceLoader.load(path)
			_initialized = true
			return
			
	var is_in_root := FileAccess.file_exists("res://game_layout.tres")
	if is_in_root:
		_game_layout = ResourceLoader.load("res://game_layout.tres")
		_initialized = true
	else:
		printerr("Could not find game layout resource, please add a game_layout.tres to project root or in project settings.")
		return

# ---- Public Functions ----

func get_main_menu() -> PackedScene:
	return _game_layout.get_main_menu()
	
func get_end_screen() -> PackedScene:
	return _game_layout.get_end_screen()

func get_level_by_name(level_name: StringName) -> PackedScene:
	var levels := _game_layout.get_levels()
	for level in levels:
		if level.get_level_name() == level_name:
			return level.get_scene()
	
	return null

func get_level_by_tag(tag: String) -> PackedScene:
	var levels := _game_layout.get_levels()
	for level in levels:
		if level.has_tag(tag):
			return level.get_scene()
	
	return null

func get_level_by_index(index: int) -> PackedScene:
	var levels := _game_layout.get_levels()
	return levels[index].get_scene()

func get_level_count() -> int:
	return _game_layout.get_levels().size()