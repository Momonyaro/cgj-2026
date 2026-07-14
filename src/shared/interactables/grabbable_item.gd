class_name GrabbableItem
extends RigidBody3D

signal grabbed
signal released

@export var grab_point: Node3D

var is_grabbed: bool
var in_hat := false
var cursor: Cursor

const MAX_SPEED = 10.0


func _process(delta: float) -> void:
	if is_grabbed:
		var target_position := cursor.get_grab_position()
		if grab_point:
			target_position -= grab_point.position
		# var motion = target_position - global_position
		# motion = motion.limit_length(MAX_SPEED * delta)
		# move_and_collide(motion)
		global_position = target_position


func is_on_floor() -> bool:
	return move_and_collide(Vector3.DOWN * 0.1, true) != null


func grab(p_cursor: Cursor) -> void:
	is_grabbed = true
	freeze = true
	cursor = p_cursor
	grabbed.emit()
	if Stage._singleton:
		Stage.audience.excitement += .1


func ungrab(_cursor: Cursor) -> void:
	is_grabbed = false
	freeze = false
	linear_velocity = linear_velocity.limit_length(MAX_SPEED)
	released.emit()
	if Stage._singleton:
		Stage.audience.excitement -= .1


func enter_hat() -> void:
	if in_hat:
		return
	in_hat = true
	visible = false
	collision_layer &= ~0x02
	# var tween := create_tween()
	# tween.tween_property(self, "scale", Vector3.ONE * 0.5, 0.2)
	# position.y -= 0.1
