extends GrabbableItem

@export var sprite: Sprite3D
@export var sitting_texture: Texture2D
@export var held_texture: Texture2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if is_grabbed:
		sprite.texture = held_texture
	elif is_on_floor():
		sprite.texture = sitting_texture
