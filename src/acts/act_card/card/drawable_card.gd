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

func paint_at_uv(uv: Vector2) -> void:
	if not drawable_texture or not brush_texture:
		return

	var pixel_pos := Vector2i(
		int(uv.x * texture_size.x),
		int(uv.y * texture_size.y)
	)
	var brush_size := Vector2i(brush_texture.get_size())
	var rect_position := pixel_pos - Vector2i(brush_size * .5)	
	var rect := Rect2i(rect_position, brush_size)
	
	drawable_texture.blit_rect(rect, brush_texture, Color.RED)

func _get_mat() -> ShaderMaterial:
	if material_override is ShaderMaterial:
		return material_override as ShaderMaterial
	if get_surface_override_material(0) is ShaderMaterial:
		return get_surface_override_material(0) as ShaderMaterial
	if mesh and mesh.surface_get_material(0) is ShaderMaterial:
		return mesh.surface_get_material(0) as ShaderMaterial
	return null
