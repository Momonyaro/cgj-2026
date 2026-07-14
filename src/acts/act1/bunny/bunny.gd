extends GrabbableItem

signal landed

@export var sprite: Sprite3D
@export var sitting_texture: Texture2D
@export var held_texture: Texture2D

var on_floor := true
var in_hat := false


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
	elif on_floor and not in_hat:
		sprite.texture = sitting_texture


func enter_hat() -> void:
	if in_hat:
		return
	in_hat = true
	visible = false
	collision_layer &= ~0x02
	# var tween := create_tween()
	# tween.tween_property(self, "scale", Vector3.ONE * 0.5, 0.2)
	# position.y -= 0.1
