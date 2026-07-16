class_name GrabbableItem
extends RigidBody3D

signal grabbed
signal released

@export var grab_point: Node3D

var is_grabbed: bool
var in_hat := false
var cursor: Cursor

const MAX_THROW_SPEED = 30.0


func process_grab(_delta: float) -> void:
	var target_position := cursor.get_grab_position()
	if grab_point:
		target_position -= grab_point.position
	var motion = target_position - global_position
	move_and_collide(motion)


func is_on_floor() -> bool:
	return move_and_collide(Vector3.DOWN * 0.1, true) != null


func get_grabbed_position() -> Vector3:
	return grab_point.global_position if grab_point else global_position


func grab(p_cursor: Cursor) -> CollisionObject3D:
	is_grabbed = true
	freeze = true
	cursor = p_cursor
	grabbed.emit()
	if Stage._singleton:
		Stage.audience.excite(.1, false)
	return self


func ungrab(_cursor: Cursor) -> void:
	is_grabbed = false
	freeze = false
	linear_velocity = linear_velocity.limit_length(MAX_THROW_SPEED)
	released.emit()
	if linear_velocity.length() >= MAX_THROW_SPEED * .5:
		SFX.play("bomb_throw")
	if Stage._singleton:
		Stage.audience.bore(.1, false)


func enter_hat() -> void:
	if in_hat:
		return
	in_hat = true
	get_parent().remove_child(self)
	# var tween := create_tween()
	# tween.tween_property(self, "scale", Vector3.ONE * 0.5, 0.2)
	# position.y -= 0.1
