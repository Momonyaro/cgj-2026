class_name ScoreTicker extends Node

@export var key: StringName
@export var score_per_tick: int = 0
@export var tick_delay: float = 1.0

var active: bool = false:
	set = _on_active_set
var _tick_timer := 0.0

# ---- Godot Events ----

func _enter_tree():
	_tick_timer = tick_delay

# ---- Public Functions ----

func tick(delta: float) -> int:
	_tick_timer = maxf(_tick_timer - delta, 0)
	if _tick_timer == 0:
		reset()
		return score_per_tick
	return 0

func reset():
	_tick_timer = tick_delay

# ---- Private Functions ----

func _on_active_set(x: bool):
	active = x
	if not active:
		reset()
