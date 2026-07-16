extends Node3D

@export var animation_player: AnimationPlayer
@export var animations_to_play: Array[StringName] = []
@export var detection_area: Area3D

var current_animation := &""
var show_complete := false

var _current_index := 0
var _started := false
var _running := false
var _paused  := false

func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	if not _started:
		return
	
	if not _running and not animation_player.is_playing():
		current_animation = animations_to_play[0]
		animation_player.play(current_animation)
		_running = true
		_paused = true # Prevent animation after intro from playing until we resume

	if _running and not _paused:
		var in_bounds = detection_area._target_in_bounds
		if in_bounds:
			Stage.audience.excite(_delta * 0.12)

func try_start() -> bool:
	_started = true
	return true

func drumroll_start() -> bool:
	SFX.play("drum_roll_looping")
	return true

func drumroll_end() -> bool:
	SFX.stop("drum_roll_looping")
	SFX.play("drum_roll_finish")
	return true

func bunny_ready_to_fly() -> bool:
	if detection_area._target_in_bounds:
		_paused = false
		_current_index += 1
		current_animation = animations_to_play[_current_index]
		animation_player.play(current_animation)
		return true
	return false

func _on_animation_finished(_name: StringName) -> void:
	current_animation = &""
	if not _paused:
		_current_index += 1
		if animations_to_play.size() <= _current_index:
			show_complete = true
			_running = false
			_started = false
			return
		current_animation = animations_to_play[_current_index]
		animation_player.play(current_animation)
