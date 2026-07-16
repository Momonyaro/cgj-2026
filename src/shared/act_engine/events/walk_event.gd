extends ActEvent
class_name WalkEvent


@export var duration := 1.
@export var pos_x := 0.

@export var x_trans := Tween.TRANS_BACK
@export var height := 0.25
@export var frequency := 4.

var _start_pos: Vector3

# -- Binds --
var tween_spawner: Node
var magician: Magician

func get_type() -> int:
	return WALK

func execute():
	_start_pos = magician.position
	
	var tween := tween_spawner.create_tween() as Tween
	tween.finished.connect(func(): finished.emit(), CONNECT_ONE_SHOT)
	tween.set_parallel()
	tween.tween_property(
		magician,
		"position:x",
		pos_x,
		duration
	).set_trans(x_trans)
	tween.tween_method(
		func(t: float):
			magician.position.y = _start_pos.y + sin(t * frequency * PI) * height,
		0.,
		1.,
		duration
	)
	
