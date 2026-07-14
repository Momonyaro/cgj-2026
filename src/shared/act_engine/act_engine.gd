extends Node
class_name ActEngine

signal finished

const Magician := preload("res://src/shared/magician/magician.gd")

static var singleton: ActEngine = null

@export var loop := false
@export var act: ActCollection

@export_subgroup("Bindings")
@export var magician: Magician = null

var act_events: Array[ActEvent] = []

var _time_started_ms := 0
var _current_event: ActEvent


func _enter_tree() -> void:
	if singleton != null and is_instance_valid(singleton) and !singleton.is_queued_for_deletion():
		singleton.queue_free()
	singleton = self

func _ready():
	finished.connect(print.bind("Act Finished! (%dms)" % (Time.get_ticks_msec() - _time_started_ms)))
	finished.connect(Stage.level_loader.load_next)
	
	assert(act and act.events.size() > 0)	
	_start_act()


# -- API --
func execute_event(event: ActEvent):
	if act_events.size() > 0:
		var next = act_events.pop_front()
		event.finished.connect(func(): execute_event(next), CONNECT_ONE_SHOT)
	else:
		event.finished.connect(_finish, CONNECT_ONE_SHOT)
		if loop:
			_start_act(event)
			return

	_current_event = event
	event.execute()

func append_events(new_events: Array[ActEvent]):
	var target_index := act_events.find(_current_event) if !act_events.is_empty() else 0
	act_events = act_events.slice(0, target_index) + new_events.duplicate() + act_events.slice(target_index)
	_bind_events(act_events)
	
	if _current_event.finished.is_connected(_finish):
		_current_event.finished.disconnect(_finish)
	
	var next = act_events.pop_front()
	_current_event.finished.connect(func(): execute_event(next), CONNECT_ONE_SHOT)


# -- Event Handlers
func _start_act(starting_event: ActEvent = null):
	_time_started_ms = Time.get_ticks_msec()
	act_events = act.events.duplicate()
	_bind_events(act_events)
	
	if starting_event != null:
		execute_event(starting_event)
	else:
		execute_event(act_events.pop_front())

func _finish():
	finished.emit()


# -- Bindings --
func _bind_events(events):
	for event in events:
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
			ActEvent.CAPTIVATE:
				_bind_captivate_event(event)

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
	event.input_names = ["Stage"]
	event.inputs = [Stage]

func _bind_captivate_event(_event: CaptivateEvent):
	pass
