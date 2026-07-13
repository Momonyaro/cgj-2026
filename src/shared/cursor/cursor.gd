class_name Cursor
extends Node2D

@export_flags_3d_physics var interactable_mask: int
@export var animated_sprite: AnimatedSprite2D
@export var grab_point: Node3D

const RAY_LENGTH = 1000.0

var hovered_object: CollisionObject3D
var grabbed_object: CollisionObject3D
var local_hand_pos: Vector3

var interact_plane: Plane


func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta: float) -> void:
	position = get_viewport().get_mouse_position()
	var cam := get_viewport().get_camera_3d()
	if not cam:
		push_warning("No camera for cursor picking")
		return

	var pos3d := cam.project_ray_origin(position)
	var normal := cam.project_ray_normal(position)
	var physics := cam.get_world_3d().direct_space_state
	var hit := physics.intersect_ray(get_pick_ray(pos3d, normal))
	hovered_object = hit.collider as CollisionObject3D if hit else null

	if Input.is_action_just_pressed("click"):
		if hovered_object and hovered_object.has_method("grab"):
			grabbed_object = hovered_object
			interact_plane = Plane(Vector3.BACK, grabbed_object.global_position)
			local_hand_pos = grabbed_object.global_transform.affine_inverse() * hit.position
			hovered_object.grab.call_deferred(self) # deferred so that grab_point is initialized when called :/
	if Input.is_action_just_released("click"):
		if grabbed_object:
			if grabbed_object.has_method("ungrab"):
				grabbed_object.ungrab(self)
			grabbed_object = null

	if grabbed_object:
		grab_point.position = interact_plane.intersects_ray(pos3d, normal)
		# animated_sprite.global_position = cam.unproject_position(grabbed_object.transform * local_hand_pos)
	else:
		animated_sprite.position = Vector2.ZERO

	animated_sprite.animation = get_animation()


func get_grab_position() -> Vector3:
	return grab_point.global_position


func constrain_cursor() -> void:
	pass
	# position = get_viewport().get_camera_3d().unproject_position(grabbed_object.transform * local_hand_pos)


func get_animation() -> String:
	if grabbed_object:
		return "grab"
	if hovered_object:
		return "hover"
	return "default"


func get_pick_ray(origin: Vector3, normal: Vector3) -> PhysicsRayQueryParameters3D:
	var ray := PhysicsRayQueryParameters3D.new()
	ray.collision_mask = interactable_mask
	ray.from = origin
	ray.to = origin + normal * RAY_LENGTH
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	return ray
