extends Node

class_name LevelLoader

const CurtainController := preload("res://src/stage/moving_curtains/curtain_controller.gd")

signal loaded_next

@export_category("Curtains")
@export var curtain_controller: CurtainController = null
@export var curtain_trans_close_durr := 1.
@export var curtain_rest_durr := 1.
@export var curtain_close_durr := 2.

var curtain_tween: Tween

var is_loading := false
var current_level: Node = null
var current_index := -1

@onready var shared_props_placeholder := $"../SharedProps" as InstancePlaceholder
var shared_props_instance: Node


func _ready():
	if get_child_count() > 0:
		push_error("Error Initializing")
	current_level = Levels.get_main_menu().instantiate()
	add_child(current_level)
	_reset_shared_props.call_deferred()


# -- API --
func load_next():
	is_loading = true
	await _transition_in()

	current_level.queue_free()
	current_level = null

	Stage.audience.reset_excitement()
	if current_index < Levels.get_level_count() - 1:
		_load_next_act()
	else:
		_load_end_screen()

	add_child(current_level)
	_reset_shared_props()

	if current_index > -1:
		await await_notes()
		await _transition_out()

	is_loading = false
	loaded_next.emit()

func load_main_menu():
	is_loading = true
	if current_level != null:
		current_level.queue_free()
	current_level = Levels.get_main_menu().instantiate()
	add_child(current_level)
	await _transition_out()
	is_loading = false
	loaded_next.emit()

# -- Loads --
func _load_next_act():
	current_index += 1
	current_level = Levels.get_level_by_index(current_index).instantiate()


func _load_end_screen():
	if Levels.get_end_screen():
		current_level = Levels.get_end_screen().instantiate()
	else:
		current_level = Levels.get_main_menu().instantiate()
	current_index = -1


# -- Transition Handling --
func _transition_in():
	if curtain_tween && curtain_tween.is_valid():
		curtain_tween.kill()
	curtain_tween = create_tween()
	curtain_tween.tween_property(curtain_controller, "move_amount", 1., curtain_trans_close_durr)
	SFX.play("curtain_pull")
	await await_curtains()
	await get_tree().create_timer(curtain_close_durr).timeout


func _transition_out():
	if curtain_tween && curtain_tween.is_valid():
		curtain_tween.kill()
	curtain_tween = create_tween()
	curtain_tween.tween_property(curtain_controller, "move_amount", 0., curtain_trans_close_durr)
	SFX.play("curtain_pull")
	await await_curtains()


func _reset_shared_props():
	if shared_props_instance:
		shared_props_instance.queue_free()
	_create_props.call_deferred()

func _create_props():
	shared_props_instance = shared_props_placeholder.create_instance()
	shared_props_instance.name = "SharedPropsInstance"


func await_notes():
	while Stage.notes_board.currently_shown:
		await get_tree().process_frame


func await_curtains():
	await curtain_tween.finished
	await get_tree().create_timer(curtain_rest_durr).timeout
