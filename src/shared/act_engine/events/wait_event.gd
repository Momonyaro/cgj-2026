extends ActEvent
class_name WaitEvent


@export var duration := 1.

# -- Binds --
var timer_spawner: Node

func get_type() -> int:
	return WAIT

func execute():
	var timer := Timer.new()
	timer_spawner.add_child(timer)
	timer.timeout.connect(
	func():
		timer.call_deferred("queue_free")
		finished.emit()
	, CONNECT_ONE_SHOT
	)
	timer.start(duration)
