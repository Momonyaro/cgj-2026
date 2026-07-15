class_name NotesBoard
extends Node3D

@export var animation: AnimationPlayer
@export var spawn_root: Node3D
@export var ui_root: Control

var currently_shown := false

var instantiated_notes: Node3D


func _ready() -> void:
	animation.play("enter", -1, 0.0)
	ui_root.hide()


func reveal(notes_scene: PackedScene) -> void:
	print("revealing notes")
	currently_shown = true
	instantiated_notes = notes_scene.instantiate()
	spawn_root.add_child(instantiated_notes)
	animation.play("enter")
	animation.animation_finished.connect(ui_root.show.unbind(1), CONNECT_ONE_SHOT)
	SFX.play("swoosh_1")


func dismiss() -> void:
	animation.play("exit")
	ui_root.hide()
	animation.animation_finished.connect(
		func(__):
			if instantiated_notes:
				instantiated_notes.queue_free()
			currently_shown = false,
		CONNECT_ONE_SHOT,
	)
	SFX.play("swoosh_2")
