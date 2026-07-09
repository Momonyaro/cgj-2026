class_name CameraShake2D extends Node

@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(100, 100)
@export var max_roll: float = 0.1

var _trauma: float = 0.0
var _trauma_power: int = 2

@onready var camera := get_parent() as Camera2D

# ---- Godot Events ----

func _ready() -> void:
	randomize()
	if not camera:
		push_warning("Must be a child of a Camera2D node!")
		set_process(false)

func _process(delta: float) -> void:
	if _trauma > 0.0:
		_trauma = max(_trauma - decay * delta, 0.0)
		_execute_shake()
	else:
		# Reset camera smoothly when shaking finishes
		camera.offset = Vector2.ZERO
		camera.rotation = 0.0

# ---- Public Functions ----

func add_trauma(amount: float) -> void:
	_trauma = min(_trauma + amount, 1.0)

# ---- Private Functions ----

func _execute_shake() -> void:
	var shake_intensity := pow(_trauma, _trauma_power)
	
	camera.rotation = max_roll * shake_intensity * randf_range(-1.0, 1.0)
	camera.offset.x = max_offset.x * shake_intensity * randf_range(-1.0, 1.0)
	camera.offset.y = max_offset.y * shake_intensity * randf_range(-1.0, 1.0)