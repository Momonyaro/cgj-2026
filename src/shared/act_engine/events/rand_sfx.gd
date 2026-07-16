extends ActEvent
class_name RandSfxEvent

@export var sfx_keys: Array[String] = []
@export var sfx_space := ""
@export var wait := .0


func get_type() -> int:
	return SOUND_EFFECT

func execute():
	var sfx := sfx_keys.pick_random() as String
	var space := sfx_space if !sfx_space.is_empty() else sfx
	SFX.stop(space)
	SFX.play(sfx, space)
	if wait > 0:
		engine.get_tree().create_timer(wait).timeout.connect(func(): finished.emit())
	else:
		finished.emit()
	
