extends Node3D

@export var target: Node3D
@export var up := Vector3.UP

func _physics_process(_delta: float) -> void:
	look_at(target.position, up, true)
