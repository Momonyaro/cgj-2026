@tool
extends Node

const SPECTATOR_SCENE := preload("uid://cqk7fxxktr1da")
const Spectator := preload("res://src/audience/spectator/spectator.gd")

@export_category("Settings")
@export var rows := 1
@export var col_lengths: Array[int] = []

@export var spectator_height_padding := .75

@export var spectator_depth := 1.
@export var spectator_height := 1.
@export var spectator_width := 5.

@export_tool_button("Bake Audience") var bake_audience := spawn_audience

@export_category("Behaviour")
@export var magnitude := 1.
@export var speed := .5
@export_range(0., 1.) var exitement := .0

var _relax_tween: Tween
var _was_excited := false
var _spectators_rnd: Array[float] = []
var _spectators: Array[Node3D] = []


## -- Create Audience --
func spawn_audience():
	assert(rows == col_lengths.size())
	_clear()
	
	_create_audience()
	_spectators.shuffle()

func spawn_spectator(col: float, row: float, center: float) -> Node3D:
	var inv_r := rows - row - 1
	
	var spectator := SPECTATOR_SCENE.instantiate() as Spectator
	assert(spectator != null)
	
	add_child(spectator)
	spectator.position.x = center + col * spectator_width + spectator_width * .5
	spectator.position.y = inv_r * spectator_height + spectator_height + inv_r * spectator_height_padding
	spectator.position.z = 0 - inv_r * spectator_depth + spectator_depth
	return spectator

func _clear():
	var spectators := get_children()
	for spectator in spectators:
		spectator.queue_free()

func _create_audience():
	_spectators = []
	_spectators_rnd = []
	for row in rows:
		var col_length := col_lengths[row]
		
		var total_width := col_length * spectator_width
		
		for col in col_length:
			var spectator := spawn_spectator(
				col,
				row,
				total_width * -.5
			)
			_spectators.append(spectator)
			_spectators_rnd.append(.01 + randf() * .025)


# -- Audience Behaviour --
func _relax_audience():
	if _relax_tween and _relax_tween.is_valid():
		_relax_tween.kill()
	_relax_tween = create_tween()
	var relax := func(t: float):
		var s_size := _spectators.size()
		for idx in range(s_size):
			var offset := _spectators[idx].get_child(0) as Node3D
			var rnd := _spectators_rnd[idx]
			offset.position.y = lerpf(offset.position.y, 0., t + rnd)
	_relax_tween.tween_method(relax, 0., 1., .25)
	_relax_tween.play()

func _process(_delta: float):
	if exitement <= 0:
		if _was_excited:
			_was_excited = false
			_relax_audience()
		return
	var s_size := _spectators.size()
	for idx in range(s_size):
		var offset := _spectators[idx].get_child(0) as Node3D
		if idx > exitement * s_size:
			offset.position.y = offset.position.y * .8
			return
		var rnd := _spectators_rnd[idx]
		offset.position.y = pingpong(
		Time.get_ticks_msec() * speed * rnd,
		magnitude
		)
	_was_excited = true
