extends ActEvent
class_name SfxEvent

enum State { PLAY, STOP }

@export var sfx_key := ""
@export var sfx_space := ""
@export var handle := State.PLAY
@export var wait := .0


func get_type() -> int:
	return SOUND_EFFECT

func execute():
	var space := sfx_space if !sfx_space.is_empty() else sfx_key
	match handle:
		State.STOP:
			SFX.stop(space)
		State.PLAY:
			SFX.stop(space)
			SFX.play(sfx_key, space)
	if wait > 0:
		engine.get_tree().create_timer(wait).timeout.connect(func(): finished.emit())
	else:
		finished.emit()
	
