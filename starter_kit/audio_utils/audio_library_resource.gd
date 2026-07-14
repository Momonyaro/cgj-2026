class_name AudioLibraryResource extends Resource

@export var _items: Dictionary[String, AudioStream] = {}

# ---- Public Functions ----

func get_item(name: String) -> AudioStream:
	return _items[name]
