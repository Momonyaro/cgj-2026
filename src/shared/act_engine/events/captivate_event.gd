extends ActEvent
class_name CaptivateEvent

@export var captivate := .1

func get_type() -> int:
	return CAPTIVATE

func execute():
	Stage.audience.exitement += captivate
	finished.emit()
