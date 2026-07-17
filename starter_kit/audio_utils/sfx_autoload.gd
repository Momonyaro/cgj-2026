extends Node

@onready var _polyphonic_player: AudioStreamPlayer = $AudioStreamPlayer

var _sfx_library: AudioLibraryResource
var _initialized: bool
var _stream_lookup: Dictionary
var _fadeout_streams: Dictionary

# ---- Godot Events ---


func _enter_tree() -> void:
	var project_setting_exists := ProjectSettings.has_setting("application/resources/sfx_library")
	if project_setting_exists:
		var path: String = ProjectSettings.get_setting("application/resources/sfx_library")
		if path != "" && ResourceLoader.exists(path):
			_sfx_library = ResourceLoader.load(path)
			_initialized = true
			return

	var is_in_root := ResourceLoader.exists("res://sfx_library.tres")
	if is_in_root:
		_sfx_library = ResourceLoader.load("res://sfx_library.tres")
		_initialized = true
	else:
		printerr("Could not find sound library resource, please add a sfx_library.tres to project root or in project settings.")
		return


func _process(delta: float):
	var stream = _get_active_stream()
	if stream == null:
		return

	for key in _fadeout_streams.keys():
		if stream.is_stream_playing(key):
			_fadeout_streams[key] = maxf(_fadeout_streams[key] - delta * 0.75, 0)
			var volume_db = lerpf(-12, 0, _fadeout_streams[key])
			stream.set_stream_volume(key, volume_db)
			if _fadeout_streams[key] == 0:
				_fadeout_streams.erase(key)
				stream.stop_stream(key)
		else:
			_fadeout_streams.erase(key)

# ---- Public Functions ----


## Specify space to have "override" behaviour without needing to track what audio key was played
func play(key: String, space := "") -> void:
	space = space if !space.is_empty() else key

	var stream := _get_active_stream()
	var play_index = stream.play_stream(_sfx_library.get_item(key), 0, 0, randf_range(0.99, 1.01))

	for existing in _stream_lookup.keys():
		if _stream_lookup[existing] == play_index:
			_stream_lookup.erase(existing) # Duplicate entry, this stream will be dead
	_stream_lookup[space] = play_index


func is_playing(key: String) -> bool:
	if !_stream_lookup.has(key):
		return false
	var stream := _get_active_stream()
	return stream.is_stream_playing(_stream_lookup[key])


func stop(key: String) -> void:
	var stream := _get_active_stream()
	if _stream_lookup.has(key):
		stream.stop_stream(_stream_lookup[key])
		_stream_lookup.erase(key)


func stop_all() -> void:
	var stream := _get_active_stream()
	for key in _stream_lookup:
		stream.stop_stream(_stream_lookup[key])


func stop_from_collection_and_play(key: String, collection: Array[StringName] = []):
	for k in collection:
		if is_playing(k):
			stop(k)
	if !is_playing(key):
		play(key)


func fade_out(key: String) -> void:
	if _stream_lookup.has(key):
		_fadeout_streams[_stream_lookup[key]] = 1.0
		_stream_lookup.erase(key)


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
