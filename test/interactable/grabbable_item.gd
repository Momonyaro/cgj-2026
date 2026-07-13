extends RigidBody3D

@export var grab_point: Node3D

var is_grabbed: bool
var cursor: Cursor

const MAX_SPEED = 100.0


func _process(delta: float) -> void:
	if is_grabbed:
		var target_position := cursor.get_grab_position()
		if grab_point:
			target_position -= grab_point.position
		global_position = global_position.move_toward(target_position, MAX_SPEED * delta)


func grab(p_cursor: Cursor) -> void:
	is_grabbed = true
	freeze = true
	cursor = p_cursor


func ungrab(_cursor: Cursor) -> void:
	is_grabbed = false
	freeze = false
	linear_velocity = linear_velocity.limit_length(MAX_SPEED)
