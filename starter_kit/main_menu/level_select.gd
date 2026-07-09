extends Control

@onready var level_button_parent: HFlowContainer = $HFlowContainer

@export var unlocked_levels_save_key: StringName = &"unlocked_levels"
@export var level_button_prefab: PackedScene

func _ready() -> void:
	_on_save_loaded()
	Save.save_loaded.connect(_on_save_loaded)

func _on_save_loaded() -> void:
	var unlocked_levels: Array = Save.read(unlocked_levels_save_key, [])
	if unlocked_levels.size() == 0:
		visible = false
		return
	
	visible = true
	_remove_existing_buttons()
	
	unlocked_levels.sort()
	for level_index in unlocked_levels:
		var instance := level_button_prefab.instantiate()
		instance.pressed.connect(func(): _on_level_button_pressed(level_index))
		
		instance.text = str(int(level_index + 1))
		level_button_parent.add_child(instance)

func _on_level_button_pressed(level_index: int) -> void:
	var scene: PackedScene = Levels.get_level_by_index(level_index)
	Transition.transition_to(scene, Transition.get_basic_fade_in(), Transition.get_basic_fade_out())

func _remove_existing_buttons() -> void:
	for child in level_button_parent.get_children():
		child.queue_free()
