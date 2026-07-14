extends Node3D

@export var target: Node3D = null
@export var speed := 1.

func _ready():
	global_position = target.global_position

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, target.global_position, delta * speed)
