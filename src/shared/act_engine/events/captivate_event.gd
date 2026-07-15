extends ActEvent
class_name CaptivateEvent

@export var captivate := .1

func get_type() -> int:
	return CAPTIVATE

func execute():
	if captivate < 0:
		Stage.audience.bore(abs(captivate))
	else:
		Stage.audience.excite(captivate)
	finished.emit()
