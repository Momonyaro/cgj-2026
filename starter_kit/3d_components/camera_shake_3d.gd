class_name CameraShake3D extends Node

@export var decay: float = 0.9
@export var max_offset: Vector2 = Vector2(.8, .8)

var _trauma: float = 0.0
var _trauma_power: int = 2

@onready var camera := get_parent() as Camera3D

# ---- Godot Events ----

func _ready() -> void:
	randomize()
	if not camera:
		push_warning("Must be a child of a Camera3D node!")
		set_process(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if event is InputEventKey:
			if event.keycode == KEY_SPACE:
				add_trauma(1)

func _process(delta: float) -> void:
	if _trauma > 0.0:
		_trauma = max(_trauma - decay * delta, 0.0)
		_execute_shake()
	else:
		# Reset camera smoothly when shaking finishes
		camera.h_offset = 0.0
		camera.v_offset = 0.0

# ---- Public Functions ----

func add_trauma(amount: float) -> void:
	_trauma = min(_trauma + amount, 1.0)

# ---- Private Functions ----

func _execute_shake() -> void:
	var shake_intensity := pow(_trauma, _trauma_power)
	
	camera.h_offset = max_offset.x * shake_intensity * randf_range(-1.0, 1.0)
	camera.v_offset = max_offset.y * shake_intensity * randf_range(-1.0, 1.0)
