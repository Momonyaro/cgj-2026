extends Area3D

signal bunny_entered
signal non_bunny_entered
signal anything_entered

const Bunny := preload("res://src/acts/act1/bunny/bunny.gd")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	var grabbable := body as GrabbableItem
	if not grabbable:
		return
	if not grabbable.is_grabbed and not grabbable.is_on_floor():
		grabbable.enter_hat()
		anything_entered.emit()
		if grabbable is Bunny:
			bunny_entered.emit()
		else:
			non_bunny_entered.emit()
