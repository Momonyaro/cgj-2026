extends Area3D

signal wind(delta_radians: float, progress: float)

@export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var min_rotation := 0.0
@export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var max_rotation := TAU
# @export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var rotation_offset := 0.0

var is_grabbed: bool
var cursor: Cursor

var prev_angle: float
var first_grab_frame := false


func _process(_delta: float) -> void:
	if is_grabbed:
		# print(rad_to_deg(rotation.z), rad_to_deg(min_rotation))
		# rotation.z = clampf(get_angle_to_hand(), min_rotation, max_rotation)
		# rotation.z = maxf(rotation.z, min_rotation)
		#
		var new_angle := get_angle_to_hand()
		if not first_grab_frame:
			var angle_diff := angle_difference(prev_angle, new_angle)
			angle_diff = clampf(angle_diff, -TAU * .25, TAU * .25)
			rotation.z += angle_diff
			rotation.z = clampf(rotation.z, min_rotation, max_rotation)
			var progress := clampf(rotation.z / max_rotation, 0, 1)
			wind.emit(angle_diff, progress)
		else:
			first_grab_frame = false

		prev_angle = new_angle


func get_angle_to_hand() -> float:
	var look_direction := (cursor.get_grab_position() - global_position)
	look_direction.z = 0
	look_direction = look_direction.normalized()
	return atan2(look_direction.y, look_direction.x)


func grab(p_cursor: Cursor) -> void:
	is_grabbed = true
	cursor = p_cursor
	first_grab_frame = true


func ungrab(_cursor: Cursor) -> void:
	is_grabbed = false
	first_grab_frame = false
