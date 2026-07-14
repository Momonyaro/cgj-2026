extends Node
class_name LevelLoader

const CurtainController := preload("res://src/stage/moving_curtains/curtain_controller.gd")

signal loaded_next

@export_category("Curtains")
@export var curtain_controller: CurtainController = null
@export var curtain_trans_close_durr := 1.
@export var curtain_rest_durr := 1.
@export var curtain_close_durr := 1.

var curtain_tween: Tween

var is_loading := false
var current_level: Node = null
var current_index := -1

func _ready():
	if get_child_count() > 0:
		push_error("Error Initializing")
	current_level = Levels.get_main_menu().instantiate()
	add_child(current_level)


# -- API --
func load_next():
	is_loading = true
	await _transition_in()
	
	current_level.queue_free()
	current_level = null
	
	if current_index < Levels.get_level_count() - 1:
		_load_next_act()
	else:
		_load_end_screen()

	add_child(current_level)
	
	await _transition_out()
	is_loading = false
	loaded_next.emit()


# -- Loads --
func _load_next_act():
	current_index += 1
	current_level = Levels.get_level_by_index(current_index).instantiate()

func _load_end_screen():
	current_level = Levels.get_end_screen().instantiate()


# -- Transition Handling --
func _transition_in():
	if curtain_tween && curtain_tween.is_valid(): curtain_tween.kill()
	curtain_tween = create_tween()
	curtain_tween.tween_property(curtain_controller, "move_amount", 1., curtain_trans_close_durr)
	await await_curtains()
	await get_tree().create_timer(curtain_close_durr).timeout


func _transition_out():
	if curtain_tween && curtain_tween.is_valid(): curtain_tween.kill()
	curtain_tween = create_tween()
	curtain_tween.tween_property(curtain_controller, "move_amount", 0., curtain_trans_close_durr)
	await await_curtains()

func await_curtains():
	await curtain_tween.finished
	await get_tree().create_timer(curtain_rest_durr).timeout
