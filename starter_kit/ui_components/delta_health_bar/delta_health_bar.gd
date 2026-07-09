extends Control

@onready var health_bar_base: Control = $VBoxContainer/HealthBarBase
@onready var current_health: Control = $VBoxContainer/HealthBarBase/CurrentHealth
@onready var delta_positive: Control = $VBoxContainer/HealthBarBase/DeltaPositive
@onready var delta_negative: Control = $VBoxContainer/HealthBarBase/DeltaNegative

@export var delta_tween_curve: Curve

var _max_health: float
var _health: float
var _ratio: float
var _last_ratio: float
var _tween: Tween

# ---- Godot Events ---

func _ready() -> void:
	set_health_no_anim(50, 100)
	set_health(100, 100)

# ---- Public Functions ----

## Use this function to initialize the bar with a health value without triggering the chunks
func set_health_no_anim(health: float, max_health: float) -> void:
	health = clamp(health, 0, max_health)
	max_health = max(max_health, 0)
	
	_health = health
	_max_health = max_health
	
	current_health.size.x = _get_bar_width() * _get_ratio()
	current_health.size.y = health_bar_base.size.y
	
	delta_positive.position.x = 0
	delta_positive.size.x = 0
	delta_negative.position.x = 0
	delta_negative.size.x = 0

func set_health(health: float, max_health: float) -> void:
	health = clamp(health, 0, max_health)
	max_health = max(max_health, 0)

	_last_ratio = _get_ratio()
	set_health_no_anim(health, max_health)
	_ratio = _get_ratio()
	
	# We've lost health, trigger a the delta animation
	if _ratio > _last_ratio:
		delta_positive.position.x = _get_bar_width() * _last_ratio
		delta_positive.size.x = _get_bar_width() * (_ratio - _last_ratio)
	elif _last_ratio > _ratio:
		delta_negative.position.x = _get_bar_width() * _ratio
		delta_negative.size.x = _get_bar_width() * (_last_ratio - _ratio)
	
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_method(_tween_delta, 0.0, 1.0, delta_tween_curve.get_domain_range())

# ---- Private Functions ----

func _tween_delta(x: float) -> void:
	var lerped_ratio := lerpf(_last_ratio, _ratio, delta_tween_curve.sample(x))
	
	delta_positive.position.x = _get_bar_width() * lerped_ratio
	delta_positive.size.x = _get_bar_width() * (_ratio - lerped_ratio)
	
	delta_negative.position.x = _get_bar_width() * _ratio
	delta_negative.size.x = _get_bar_width() * (lerped_ratio - _ratio)

func _get_ratio() -> float:
	if _max_health == 0 || _health == 0:
		return 0.0
	
	return _health / _max_health

func _get_bar_width() -> float:
	return health_bar_base.size.x
