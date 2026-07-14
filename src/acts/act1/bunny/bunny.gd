extends GrabbableItem

signal landed

@export var sprite: Sprite3D
@export var sitting_texture: Texture2D
@export var held_texture: Texture2D

var on_floor := true


func _ready() -> void:
	grabbed.connect(SFX.play.bind("squeak"))


func _process(_delta: float) -> void:
	if is_on_floor():
		if not on_floor:
			landed.emit()
		on_floor = true
	else:
		on_floor = false

	if is_grabbed:
		sprite.texture = held_texture
	elif on_floor and not in_hat:
		sprite.texture = sitting_texture
