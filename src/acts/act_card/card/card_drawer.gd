extends Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var last_uv := Vector2(-1, -1)
var is_drawing := false

func _physics_process(_delta: float) -> void:
	var result := shoot_ray_from_mouse()
	if result["ray"] and result["mesh"]:
		Stage.cursor.hovered_card = true
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_handle_target_mesh(result["ray"], result["mesh"])
		else:
			_reset()
	else:
		Stage.cursor.hovered_card = false
		_reset()

func shoot_ray_from_mouse() -> Dictionary:
	var mouse_pos := get_viewport().get_mouse_position()
	
	var ray_start := camera.project_ray_origin(mouse_pos)
	var ray_end := ray_start + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.hit_back_faces = true  
	
	var result := space_state.intersect_ray(query)
	if result:
		var hit_collider = result.collider
		var target_mesh := hit_collider.get_parent() as DrawableCard
		return {
			"ray": result,
			"mesh": target_mesh,
		}
	else:
		return {
			"ray": result,
			"mesh": null
		}

func _handle_target_mesh(ray, target_mesh: DrawableCard):
	var hit_position = ray.get("position")
	var uv = ray.get("uv")
	
	var local_hit_pos: Vector3 = target_mesh.global_transform.inverse() * hit_position
	if uv == null:
		var mesh_size: Vector2 = Vector2(DrawableCard.SIZE_X, DrawableCard.SIZE_Y)
		if target_mesh.mesh is QuadMesh:
			mesh_size = target_mesh.mesh.size
		uv = Vector2(
			(local_hit_pos.x / mesh_size.x) + 0.5,
			(-local_hit_pos.y / mesh_size.y) + 0.5
		)
	
	uv.x = clamp(uv.x, 0.0, 1.0)
	uv.y = clamp(uv.y, 0.0, 1.0)
	
	if not is_drawing:
		target_mesh.paint_line(uv, uv)
		is_drawing = true
	else:
		target_mesh.paint_line(last_uv, uv)
		
	last_uv = uv

func _reset():
	is_drawing = false
	last_uv = Vector2(-1, -1)
