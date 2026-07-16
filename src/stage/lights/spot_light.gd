extends WindableItem

const PERFECT_ANGLE_THRESHOLD = cos(deg_to_rad(5))

@onready var original_rotation := basis


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	ScoreManager.set_ticker(name, magician_is_lit())


func reset() -> void:
	basis = original_rotation


func magician_is_lit() -> bool:
	var light_direction := -global_basis.y
	light_direction.z = 0
	light_direction = light_direction.normalized()

	var light_to_magician: Vector3
	if Magician.current_magician:
		light_to_magician = Magician.current_magician.global_position - global_position
		light_to_magician.z = 0
		light_to_magician = light_to_magician.normalized()

		var dot := light_to_magician.dot(light_direction)
		if dot >= PERFECT_ANGLE_THRESHOLD:
			return true

	return false
