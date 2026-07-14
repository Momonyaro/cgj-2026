@tool
extends Node3D

@export var mesh_instance: MeshInstance3D
@export var base_material: StandardMaterial3D

@export var note_texture: Texture2D:
	get:
		return note_texture
	set(value):
		note_texture = value
		update_material.call_deferred()


func update_material() -> void:
	prints("mesh", mesh_instance)
	var mat := base_material.duplicate()
	mat.albedo_texture = note_texture
	mesh_instance.material_overlay = mat
