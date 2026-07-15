extends Node

signal score_changed

@export var debug_label: Label 
@export var debug_enable: bool = false

## Actual value
var _score: int = 0
## Lerped value for presentation
var score: int = 0

# ---- Godot Events ----

func _process(delta: float):
	_update_tickers(delta)
	
	score = ceili(lerpf(score, _score, delta * 1.5))
	if debug_enable:
		debug_label.text = str("actual: %d, lerped: %d" % [_score, score])

func _unhandled_input(event):
	if event.is_pressed() and debug_enable:
		if event is InputEventKey:
			if event.keycode == KEY_SPACE:
				add_score(randi_range(1, 100))

# ---- Public Functions ----

func add_score(points: int) -> void:
	_score += points
	score_changed.emit()

func clear_score() -> void:
	_score = 0
	score_changed.emit()

func set_ticker(key: String, enabled: bool) -> void:
	var children = get_children()
	for child in children: 
		if child is ScoreTicker:
			if child.key == key:
				child.active = enabled

# ---- Private Functions ----

func _update_tickers(delta: float) -> void:
	var children = get_children()
	for child in children: 
		if child is ScoreTicker:
			if child.active:
				_score += child.tick(delta)
