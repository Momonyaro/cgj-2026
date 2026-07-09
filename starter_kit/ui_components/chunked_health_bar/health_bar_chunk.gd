extends Panel

@export var hold_time: float = 0.4
@export var fade_out_duration: float = 0.2

func activate() -> void:
	await get_tree().create_timer(hold_time).timeout
	await create_tween().tween_method(_tween_out, 0.0, 1.0, fade_out_duration).finished
	hide()
	set_process(false)
	_tween_out(0.0) # Reset tween

func _tween_out(x: float) -> void:
	offset_transform_position_ratio = Vector2(0, -x)
	modulate.a = 1.0 - x
	pass