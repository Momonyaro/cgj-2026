extends RigidBody3D

@export var grab_point: Node3D

var is_grabbed: bool

var cursor: Cursor

const MAX_THROW_SPEED = 5.0


func _process(delta: float) -> void:
	if is_grabbed:
		global_position = cursor.get_grab_position()
		linear_velocity = linear_velocity.limit_length(MAX_THROW_SPEED)
		if grab_point:
			global_position -= grab_point.position


func grab(p_cursor: Cursor) -> void:
	is_grabbed = true
	freeze = true
	cursor = p_cursor


func ungrab(_cursor: Cursor) -> void:
	is_grabbed = false
	freeze = false
	linear_velocity = linear_velocity.limit_length(MAX_THROW_SPEED)
