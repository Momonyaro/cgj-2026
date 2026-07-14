extends Node

const Magician := preload("res://src/shared/magician/magician.gd")

@export var loop := false
@export var act: ActCollection

@export_subgroup("Bindings")
@export var magician: Magician = null

var act_events: Array[ActEvent] = []

func _ready():
	assert(act and act.events.size() > 0)
	act_events = act.events.duplicate()
	
	_bind_events()
	execute_event(act_events.pop_front())


func execute_event(event: ActEvent):
	if act_events.size() > 0:
		var next = act_events.pop_front()
		event.finished.connect(func(): execute_event(next), CONNECT_ONE_SHOT)
	elif loop:
		act_events = act.events.duplicate()
		execute_event(event)
		return
	event.execute()


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

func _bind_walk_event(event: WalkEvent):
	event.magician = magician
	event.tween_spawner = self

func _bind_swap_event(event: SwapEvent):
	event.magician = magician

func _bind_wait_event(event: WaitEvent):
	event.timer_spawner = self

func _bind_spawn_event(event: SpawnEvent):
	event.root = self
