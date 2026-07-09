extends Button

@export var target_scene_tag: StringName = &"entry"

func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	var target_scene = Levels.get_level_by_tag(target_scene_tag)
	if target_scene != null:
		var fade_in: Curve = Transition.get_basic_fade_in()
		var fade_out: Curve = Transition.get_basic_fade_out()
		Transition.transition_to(target_scene, fade_in, fade_out)
