extends CanvasLayer

@onready var fade_rect: Control = $Container/FadeRect

var _target_scene: PackedScene
var _fade_in: Curve
var _fade_out: Curve

var _transitioning: bool

# ---- Godot Events ----

func _ready():
	process_mode = PROCESS_MODE_ALWAYS # Needed for fade_in/out
	fade_rect.visible = false

func _process(_delta: float):
	if _transitioning && get_tree().paused == false && _target_scene != null:
		_internal_transition_to()

# ---- Public Functions ----

func get_basic_fade_in() -> Curve:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))
	return curve

func get_basic_fade_out() -> Curve:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	return curve

func transition_to(scene: PackedScene, fade_in: Curve, fade_out: Curve) -> void:
	if _transitioning:
		return
		
	_transitioning = true
	_target_scene = scene
	_fade_in = fade_in
	_fade_out = fade_out
	
# ---- Private Functions ----
	
func _internal_transition_to() -> void:
	get_tree().paused = true
	
	fade_rect.visible = true
	await create_tween().tween_method(_tween_fade_in, 0.0, 1.0, _fade_in.get_domain_range()).finished
	
	get_tree().change_scene_to_packed(_target_scene)
	
	await create_tween().tween_method(_tween_fade_out, 0.0, 1.0, _fade_out.get_domain_range()).finished
	fade_rect.visible = false
	
	get_tree().paused = false
	_transitioning = false
	_target_scene = null
	_fade_in = null
	_fade_out = null

func _tween_fade_in(x: float) -> void:
	fade_rect.modulate.a = _fade_in.sample(x)

func _tween_fade_out(x: float) -> void:
	fade_rect.modulate.a = _fade_out.sample(x)