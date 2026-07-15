extends Node3D

@export var life_time := 1.
@export var particles: Array[GPUParticles3D]

func _ready() -> void:
	for p in particles:
		p.emitting = true
	get_tree().create_timer(life_time).timeout.connect(queue_free)
