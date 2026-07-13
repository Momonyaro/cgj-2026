extends ActEvent
class_name WalkEvent

const Magician := preload("res://src/shared/magician/magician.gd")

@export var duration := 1.
@export var pos_x := 0.

# -- Binds --
var tween_spawner: Node
var magician: Magician

func get_type() -> int:
	return WALK

func execute():
	var tween := tween_spawner.create_tween() as Tween
	#TODO: Make the magician move up and down when walking
	tween.finished.connect(func(): finished.emit(), CONNECT_ONE_SHOT)
	tween.tween_property(
		magician,
		"position",
		Vector3(pos_x, magician.position.y, magician.position.z),
		duration
	)
