class_name WindableItem
extends Area3D

signal wind(delta_radians: float, progress: float)

@export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var min_rotation := 0.0
@export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var max_rotation := TAU
@export var crank_sound: String
# @export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var rotation_offset := 0.0

var is_grabbed: bool
var cursor: Cursor

var prev_angle: float


func process_grab(_delta: float) -> void:
	angle(get_angle_to_hand())


func angle(new_angle):
	var angle_diff := angle_difference(prev_angle, new_angle)
	angle_diff = clampf(angle_diff, -TAU * .25, TAU * .25)
	rotation.z += angle_diff
	rotation.z = clampf(rotation.z, min_rotation, max_rotation)
	var progress := clampf(rotation.z / max_rotation, 0, 1)
	wind.emit(angle_diff, progress)

	if angle_diff and crank_sound:
		if not SFX.is_playing(crank_sound):
			SFX.play(crank_sound)

	prev_angle = new_angle


func get_angle_to_hand() -> float:
	var look_direction := (cursor.get_grab_position() - global_position)
	look_direction.z = 0
	look_direction = look_direction.normalized()
	return atan2(look_direction.y, look_direction.x)


func grab(p_cursor: Cursor) -> CollisionObject3D:
	is_grabbed = true
	cursor = p_cursor
	prev_angle = get_angle_to_hand()
	return self


func ungrab(_cursor: Cursor) -> void:
	is_grabbed = false
