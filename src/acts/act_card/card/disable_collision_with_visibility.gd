extends Node

@export var target: Node3D = null
@export var collider: CollisionShape3D = null

func _ready():
	target.visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()

func _on_visibility_changed():
	if target.visible:
		collider.disabled = false
	else:
		collider.disabled = true
