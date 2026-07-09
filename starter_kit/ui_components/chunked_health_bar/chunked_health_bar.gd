extends Control

@onready var health_bar_base: Control = $VBoxContainer/HealthBarBase
@onready var current_health: Control = $VBoxContainer/HealthBarBase/CurrentHealth
@onready var chunk_parent: Control = $VBoxContainer/HealthBarBase/ChunkParent
@onready var hpchunk_pooler: ObjectPooler = $HPChunkPooler

var _max_health: float
var _health: float

# ---- Godot Events ---

func _ready() -> void:
	set_health_no_anim(100, 100)

# ---- Public Functions ----

## Use this function to initialize the bar with a health value without triggering the chunks
func set_health_no_anim(health: float, max_health: float) -> void:
	health = clamp(health, 0, max_health)
	max_health = max(max_health, 0)
	
	_health = health
	_max_health = max_health
	
	current_health.size.x = health_bar_base.size.x * _get_ratio()
	current_health.size.y = health_bar_base.size.y

func set_health(health: float, max_health: float) -> void:
	health = clamp(health, 0, max_health)
	max_health = max(max_health, 0)

	var last_ratio := _get_ratio()
	set_health_no_anim(health, max_health)
	var new_ratio := _get_ratio()
	
	# We've lost health, trigger a chunk animation
	if last_ratio > new_ratio:
		var ratio_diff := last_ratio - new_ratio
		var chunk := hpchunk_pooler.get_instance()
		chunk.position = chunk_parent.global_position + Vector2(_get_bar_width() * new_ratio, 0)
		chunk.size = Vector2(_get_bar_width() * ratio_diff, chunk_parent.size.y)
		chunk.show()
		chunk.set_process(true)
		chunk.activate()

# ---- Private Functions ----

func _get_ratio() -> float:
	if _max_health == 0 || _health == 0:
		return 0.0
	
	return _health / _max_health

func _get_bar_width() -> float:
	return health_bar_base.size.x
