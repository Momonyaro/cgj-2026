class_name Cup
extends Area3D

signal anything_entered

const Bunny := preload("res://src/acts/act1/bunny/bunny.gd")
const BunnyInHat = preload("res://src/acts/act1/act1_bunny_in_hat.tres")
const BunnyNotInHat = preload("res://src/acts/act1/act1_bunny_not_in_hat.tres")

var is_full := false
var interactable := false
var index: int


func _on_body_entered(body: Node3D) -> void:
	if is_full or not interactable:
		return
	if body is not GrabbableItem:
		return
	var grabbable := body as GrabbableItem
	if not grabbable.is_grabbed and not grabbable.in_hat:
		grabbable.enter_hat(false)
		if grabbable.get_parent():
			grabbable.get_parent().remove_child.call_deferred(grabbable)
		grabbable.collision_layer &= ~0x02
		add_child.call_deferred(grabbable)
		grabbable.position = Vector3(0.0, 0.15, 0.0)
		anything_entered.emit()
		SFX.play("eat_up")
		if grabbable is Bunny:
			ScoreManager.add_score(92)
		elif index != 1:
			ScoreManager.add_score(16)
		is_full = true
