class_name DrawableCard
extends MeshInstance3D

const CARD_X_ASPECT := .63
const CARD_Y_ASPECT := .88

const SIZE_X := CARD_X_ASPECT * 4
const SIZE_Y := CARD_Y_ASPECT * 4

var drawable_texture: DrawableTexture2D
var texture_size: Vector2i = Vector2i(int(CARD_X_ASPECT * 1000), int(CARD_Y_ASPECT * 1000))

@export var brush_texture: Texture2D 

func _ready() -> void:
	drawable_texture = DrawableTexture2D.new()
	drawable_texture.setup(
		texture_size.x, 
		texture_size.y,
		DrawableTexture2D.DRAWABLE_FORMAT_RGBA8,
		Color.WHITE
	)
	
	var mat	:= _get_mat()
	assert(mat, "No ShaderMaterial found on this mesh node!")
	mat.set_shader_parameter("front_texture", drawable_texture)

func paint_line(from_uv: Vector2, to_uv: Vector2) -> void:
	if not drawable_texture or not brush_texture:
		return

	var start_pos := Vector2(from_uv.x * texture_size.x, from_uv.y * texture_size.y)
	var end_pos := Vector2(to_uv.x * texture_size.x, to_uv.y * texture_size.y)
	
	var distance := start_pos.distance_to(end_pos)
	var brush_size := Vector2i(brush_texture.get_size())
	
	var step_distance := maxf(1.0, min(brush_size.x, brush_size.y) * 0.25)
	var steps := maxf(1, int(distance / step_distance))
	
	var brush_offset := Vector2i(brush_size * 0.5)
	
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var current_pixel_pos := Vector2i(start_pos.lerp(end_pos, t))
		
		var rect := Rect2i(current_pixel_pos - brush_offset, brush_size)
		drawable_texture.blit_rect(rect, brush_texture, Color.RED)

func _get_mat() -> ShaderMaterial:
	if material_override is ShaderMaterial:
		return material_override as ShaderMaterial
	if get_surface_override_material(0) is ShaderMaterial:
		return get_surface_override_material(0) as ShaderMaterial
	if mesh and mesh.surface_get_material(0) is ShaderMaterial:
		return mesh.surface_get_material(0) as ShaderMaterial
	return null
