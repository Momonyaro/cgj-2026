extends Node

# THIS FILE SHOULD BE ADDED TO THE PROJECT AS AN AUTOLOAD IN ORDER TO BE PROPERLY USED
# THANK YOU FOR YOUR TIME!   - THE MANAGEMENT

signal save_loaded(slot: int)

const SAVE_PATH: String = "user://"
const SAVE_FILE: String = "save"
const SAVE_FILE_EXT: String = ".dat"

const FINGERPRINT: String = "davey_jones"

## If true, slot0.dat will attempt to load as the autoload is started
const AUTOLOAD_ON_INIT: bool = true
## How long (in seconds) before snapshot is written to disk after it is taken
const SNAPSHOT_INTERVAL: float = 2.5

var _save_data: Dictionary = {}
var _snapshot_to_save: Dictionary = {}


# ---- Godot Events ----

func _enter_tree() -> void:
	if AUTOLOAD_ON_INIT:
		var err := load_slot()
		if err != OK:
			printerr("Failed to load save slot 0, received error code: %s" % error_string(err))

func _process(_delta: float) -> void:
	if _snapshot_to_save.size() > 0:
		var current_time: float = Time.get_unix_time_from_system()
		var timestamp: float = _snapshot_to_save.get("timestamp", current_time)
		
		if current_time - timestamp > SNAPSHOT_INTERVAL:
			print("[SAVE] writing snapshot to disk")
			_write_to_disk(_snapshot_to_save.get("path", ""), _snapshot_to_save.get("data", {}))
			_snapshot_to_save = {}

# ---- Public Functions ----

func contains_data() -> bool:
	return _save_data.keys().size() > 0

func write(key: String, value: Variant) -> void:
	# TODO: Change key parsing to treat it as path to place value correctly in the dictionary
	_save_data[key] = value

func read(key: String, default: Variant) -> Variant:
	return _save_data.get(key, default)

func save_slot(slot: int = 0, now: bool = false) -> int:
	var path: String = _get_save_slot_path(slot)
	if contains_data() == false:
		return ERR_FILE_EOF

	if now:
		_write_to_disk(path, _save_data)
		_snapshot_to_save = {}
		return OK

	_snapshot_to_save = { "path": path, "data": _save_data, "timestamp": Time.get_unix_time_from_system() }
	return OK

func load_slot(slot: int = 0) -> int:
	var path: String = _get_save_slot_path(slot)
	if FileAccess.file_exists(path) == false:
		return ERR_FILE_NOT_FOUND

	var file := FileAccess.open(path, FileAccess.READ)
	var json_str: String = file.get_as_text()
	if json_str == "":
		return ERR_FILE_EOF
	
	var json_data: Dictionary = JSON.parse_string(json_str)
	file.close()
	
	if json_data.get("f_print", "") != FINGERPRINT:
		return ERR_INVALID_DATA
	json_data.erase("f_print")

	if contains_data():
		print("Overriding loaded save data with incoming from slot %d" % slot)
	
	_save_data = json_data
	save_loaded.emit(slot)
	return OK

# ---- Private Functions ----

func _write_to_disk(path: String, data: Dictionary) -> void:
	if path == "" or data.size() == 0:
		return;
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	
	data["f_print"] = FINGERPRINT
	var json_str := JSON.stringify(data, "\t")
	
	file.store_string(json_str)
	file.close()

## This will return a path to the save file for the given slot
## example: _get_save_slot_path(0) -> "user://save0.dat"
func _get_save_slot_path(slot: int) -> String:
	return str("%s%s%d%s" % [SAVE_PATH, SAVE_FILE, slot, SAVE_FILE_EXT])
