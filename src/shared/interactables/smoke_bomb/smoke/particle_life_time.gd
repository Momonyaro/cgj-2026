extends Node

@export var life_time := 1.
@export var remove_target: Node = null
@export var particles: Array[GPUParticles3D]

func _ready() -> void:
	for p in particles:
		p.emitting = true
	get_tree().create_timer(life_time).timeout.connect(remove_target.queue_free)
