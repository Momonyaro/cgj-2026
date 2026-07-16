extends ActEvent
class_name AngleSpotLightEvent

enum SpotLight { LEFT, RIGHT, BOTH }

@export var spotlight := SpotLight.BOTH
@export var look_at: NodePath = ""
@export var duration := 1.
@export var trans := Tween.TRANS_BACK
@export var is_async := false

func get_type() -> int:
	return ANGLE_SPOTLIGHT


func execute():
	var angle_tween := engine.create_tween()
	var target := engine.get_node(look_at) as Node3D
	angle_tween.set_parallel()
	
	if spotlight == SpotLight.LEFT or spotlight == SpotLight.BOTH:
		var l_light := Stage.left_spot_light
		var prev_angle := l_light.prev_angle
		
		var angle_diff := angle_difference(prev_angle, get_angle_to_target(l_light, target))
		var final_clamped_angle := prev_angle + angle_diff

		angle_tween.tween_method(
		l_light.angle,
		prev_angle,
		final_clamped_angle,
		duration
		).set_trans(trans)

	if spotlight == SpotLight.RIGHT or spotlight == SpotLight.BOTH:
		var r_light := Stage.right_spot_light
		angle_tween.tween_method(
		r_light.angle,
		r_light.rotation.z,
		get_angle_to_target(r_light, target),
		duration
		).set_trans(trans)
		
	if is_async:
		finished.emit()
	else:
		angle_tween.finished.connect(func(): finished.emit())


func get_angle_to_target(spot_light: Node3D, target: Node3D) -> float:
	var look_direction := (target.global_position - spot_light.global_position)
	look_direction.z = 0
	look_direction = look_direction.normalized()
	var target_angle := atan2(look_direction.y, look_direction.x)
	target_angle += PI / 2.0
	return target_angle
