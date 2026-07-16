extends Area3D

const Smoke := preload("res://src/shared/interactables/smoke_bomb/smoke/smoke.gd")

var caught_smoke := false


func _ready():
	area_entered.connect(_on_area_entered)


func _on_area_entered(other_area: Area3D) -> void:
	print(other_area)
	if other_area is not Smoke:
		return
	caught_smoke = true
