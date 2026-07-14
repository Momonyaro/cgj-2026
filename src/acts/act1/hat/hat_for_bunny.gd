extends Area3D

signal bunny_entered

const Bunny := preload("res://src/acts/act1/bunny/bunny.gd")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	var bunny := body as Bunny
	if not bunny:
		return
	if not bunny.is_grabbed and not bunny.on_floor:
		bunny.enter_hat()
		bunny_entered.emit()
