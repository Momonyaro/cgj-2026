extends ActEvent
class_name CaptivateEvent

@export var captivate := .1
@export var fire_sfx := true

func get_type() -> int:
	return CAPTIVATE

func execute():
	if captivate < 0:
		Stage.audience.bore(abs(captivate), fire_sfx)
	else:
		Stage.audience.excite(captivate, fire_sfx)
	finished.emit()
