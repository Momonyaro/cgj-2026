class_name Cursor
extends Node2D

@export_flags_3d_physics var interactable_mask: int
@export var animated_sprite: AnimatedSprite2D
@export var grab_point: Node3D

const RAY_LENGTH = 1000.0
const MAX_OVERDRAG_BEFORE_DROPPING := 2.0

var hovered_object: CollisionObject3D
var grabbed_object: CollisionObject3D
var interact_plane: Plane


func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(delta: float) -> void:
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
	if (
		hovered_object and
		Stage.level_loader.curtain_controller.closed and
		not hovered_object.is_in_group("unblockable_interactable")
	):
		hovered_object = null

	if Input.is_action_just_pressed("click"):
		SFX.play("grab")
		if hovered_object and hovered_object.has_method("grab"):
			grabbed_object = hovered_object.grab(self)
			interact_plane = Plane(Vector3.BACK, grabbed_object.global_position)
			grab_point.position = interact_plane.intersects_ray(pos3d, normal)

	if Input.is_action_just_released("click"):
		SFX.play("drop")
		ungrab_object()

	if grabbed_object:
		grab_point.position = interact_plane.intersects_ray(pos3d, normal)

		if grabbed_object.has_method("process_grab"):
			grabbed_object.process_grab(delta)

		if grabbed_object.has_method("get_grabbed_position"):
			var expected_grab_pos: Vector3 = grabbed_object.get_grabbed_position()
			var overdrag_dist := expected_grab_pos.distance_to(grab_point.global_position)
			if overdrag_dist > MAX_OVERDRAG_BEFORE_DROPPING:
				ungrab_object()

	else:
		animated_sprite.position = Vector2.ZERO

	animated_sprite.animation = get_animation()


func get_grab_position() -> Vector3:
	return grab_point.global_position


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


func ungrab_object() -> void:
	if grabbed_object:
		if grabbed_object.has_method("ungrab"):
			grabbed_object.ungrab(self)
		grabbed_object = null
