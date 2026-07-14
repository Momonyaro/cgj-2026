extends Area3D

signal anything_entered

const Bunny := preload("res://src/acts/act1/bunny/bunny.gd")
const BunnyInHat = preload("res://src/acts/act1/act1_bunny_in_hat.tres")
const BunnyNotInHat = preload("res://src/acts/act1/act1_bunny_not_in_hat.tres")

var is_full := false

func _on_body_entered(body: Node3D) -> void:
	if body is not GrabbableItem:
		return
	var grabbable := body as GrabbableItem
	if not grabbable.is_grabbed and not grabbable.is_on_floor():
		grabbable.enter_hat()
		anything_entered.emit()
		SFX.play("eat_up")
		if grabbable is Bunny:
			if ActEngine.singleton:
				ActEngine.singleton.append_events(BunnyInHat.events)
		else:
			if ActEngine.singleton:
				ActEngine.singleton.append_events(BunnyNotInHat.events)
		is_full = true
