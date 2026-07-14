extends GrabbableItem

signal landed

@export var sprite: Sprite3D
@export var sitting_texture: Texture2D
@export var held_texture: Texture2D

var on_floor := true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if is_on_floor():
		if not on_floor:
			landed.emit()
		on_floor = true
	else:
		on_floor = false

	if is_grabbed:
		sprite.texture = held_texture
	elif on_floor:
		sprite.texture = sitting_texture
