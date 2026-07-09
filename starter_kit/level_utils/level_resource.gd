class_name LevelResource extends Resource

@export var _name: StringName
@export var _scene: PackedScene
@export var _tags: Array[String]

# ---- Public Functions ----

func get_level_name() -> StringName:
	return _name

func get_scene() -> PackedScene:
	return _scene

func has_tag(tag: String) -> bool:
	return _tags.has(tag)
