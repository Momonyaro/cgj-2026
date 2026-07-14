extends Node

signal finished

const Magician := preload("res://src/shared/magician/magician.gd")

@export var loop := false
@export var act: ActCollection

@export_subgroup("Bindings")
@export var magician: Magician = null

var act_events: Array[ActEvent] = []

var _time_started_ms := 0


func _ready():
	finished.connect(print.bind("Act Finished! (%dms)" % (Time.get_ticks_msec() - _time_started_ms)))
	assert(act and act.events.size() > 0)	
	_start_act()

func execute_event(event: ActEvent):
	if act_events.size() > 0:
		var next = act_events.pop_front()
		event.finished.connect(func(): execute_event(next), CONNECT_ONE_SHOT)
	else:
		event.finished.connect(func(): finished.emit(), CONNECT_ONE_SHOT)
		if loop:
			_start_act(event)
			return

	event.execute()

func _start_act(starting_event: ActEvent = null):
	_time_started_ms = Time.get_ticks_msec()
	act_events = act.events.duplicate()
	_bind_events()
	
	if starting_event != null:
		execute_event(starting_event)
	else:
		execute_event(act_events.pop_front())
		

# -- Bindings --
func _bind_events():
	for event in act_events:
		match event.get_type():
			ActEvent.WALK:
				_bind_walk_event(event)
			ActEvent.SWAP:
				_bind_swap_event(event)
			ActEvent.WAIT:
				_bind_wait_event(event)
			ActEvent.SPAWN:
				_bind_spawn_event(event)
			ActEvent.WAIT_EXPRESSION:
				_bind_condition_event(event)

func _bind_walk_event(event: WalkEvent):
	event.magician = magician
	event.tween_spawner = self

func _bind_swap_event(event: SwapEvent):
	event.magician = magician

func _bind_wait_event(event: WaitEvent):
	event.timer_spawner = self

func _bind_spawn_event(event: SpawnEvent):
	event.root = self

func _bind_condition_event(event: WaitExpressionEvent):
	event.context = self
	event.inputs = []
