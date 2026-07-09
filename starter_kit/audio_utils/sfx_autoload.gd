extends Node

@onready var _polyphonic_player: AudioStreamPlayer = $AudioStreamPlayer

var _sfx_library: AudioLibraryResource
var _initialized: bool

# ---- Godot Events ---

func _enter_tree() -> void:
	var project_setting_exists := ProjectSettings.has_setting("application/resources/sfx_library")
	if project_setting_exists:
		var path: String = ProjectSettings.get_setting("application/resources/sfx_library")
		if path != "" && FileAccess.file_exists(path):
			_sfx_library = ResourceLoader.load(path)
			_initialized = true
			return
			
	var is_in_root := FileAccess.file_exists("res://sfx_library.tres")
	if is_in_root:
		_sfx_library = ResourceLoader.load("res://sfx_library.tres")
		_initialized = true
	else:
		printerr("Could not find sound library resource, please add a sfx_library.tres to project root or in project settings.")
		return

# ---- Public Functions ----
	
func play(key: String) -> void:
	var stream := _get_active_stream()
	stream.play_stream(_sfx_library.get_item(key), 0, 0, randf_range(0.99, 1.01))
	pass

# NOTE: Figure out where in the scenetree to place the resulting nodes.
func play_positional_2d(key: String, position: Vector2) -> void:
	var sound_item: AudioStreamPlayer2D = load("2d_sound_item.gd").new()
	sound_item.stream = _sfx_library.get_item(key)
	
	if get_tree().current_scene == null:
		printerr("Could not play sound, current scene is null.")
		return
	
	get_tree().current_scene.add_child(sound_item)
	sound_item.global_position = position

func play_positional_3d(_key: String, _position: Vector3) -> void:
	push_error("Not implemented.")
	pass

# ---- Private Functions ----

func _get_active_stream() -> AudioStreamPlaybackPolyphonic:
	return _polyphonic_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
