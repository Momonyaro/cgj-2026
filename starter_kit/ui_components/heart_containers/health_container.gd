extends TextureProgressBar

@export var _tween_scale_curve: Curve
var _tween: Tween

func _ready() -> void:
	$Whiteout.modulate.a = 0.0

func set_health(new_value: float) -> void:
	if absf(value - new_value) <= 0.001:
		return
	
	value = new_value
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_method(_tween_changed, 0.0, 1.0, _tween_scale_curve.get_domain_range())

func _tween_changed(x: float) -> void:
	var sampled_x := _tween_scale_curve.sample(x)
	offset_transform_scale = Vector2.ONE + Vector2(sampled_x, sampled_x)
	$Whiteout.modulate.a = 1.0 - x
