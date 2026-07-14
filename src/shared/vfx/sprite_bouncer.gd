@tool
class_name SpriteBouncer
extends Node

@export var sprite: Node3D

@export_range(0, 1.0) var time: float
@export var amount: float = 1.0
@export var duration: float
@export_tool_button("Bounce") var do_bounce := bounce


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not sprite:
		return

	var t := sin(time * TAU) * 0.5 + 0.5
	var t2 := 1.0 - t
	var scale1 := lerpf(1.0 / amount, amount, t) if amount else 1.0
	var scale2 := lerpf(1.0 / amount, amount, t2) if amount else 1.0

	sprite.scale.x = scale2
	sprite.scale.y = scale1


func bounce() -> void:
	time = 0
	var tween := create_tween()
	tween.tween_property(self, "time", 1.0, duration)
