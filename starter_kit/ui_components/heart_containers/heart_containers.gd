extends Control

@onready var heart_pooler: ObjectPooler = $HeartPooler

@export var _hearts_per_row: int = 5
@export var _health_per_heart: float = 2.0
@export var _heart_size: float = 16.0
@export var _heart_scale: float = 1.0

var _hearts: Array = []

func set_health(health: int, max_health: int) -> void:
	var heart_count := ceili(max_health / _health_per_heart)
	
	for heart in _hearts:
		heart.visible = false
		heart.set_process(false)
	
	_hearts.clear()
	
	for i in heart_count:
		var heart := heart_pooler.get_instance()
		
		var heart_range := i * _health_per_heart
		var heart_max := minf(max_health - heart_range, _health_per_heart)
		var heart_current := minf(health - heart_range, _health_per_heart)
		var health_ratio := clampf(heart_current / heart_max, 0, 1)
		_place_heart(heart, i, health_ratio)
		
		heart.visible = true
		heart.set_process(true)
		_hearts.push_back(heart)
		
func _place_heart(heart: Node, index: int, health_ratio: float) -> void:
	var x_index := index % _hearts_per_row
	var y_index := floori(index / float(_hearts_per_row))
	
	heart.set_health(health_ratio)
	
	heart.global_position = self.global_position + Vector2(x_index * _heart_size, y_index * _heart_size)
	heart.scale = Vector2(_heart_scale, _heart_scale)
	