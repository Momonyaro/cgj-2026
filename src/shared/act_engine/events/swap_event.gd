extends ActEvent
class_name SwapEvent

const Magician := preload("res://src/shared/magician/magician.gd")

@export var next_sprite: Texture2D = null

# -- Binds --
var magician: Magician


func get_type() -> int:
	return SWAP

func execute():
	magician.finished_spin.connect(func(): finished.emit(), CONNECT_ONE_SHOT)
	magician.swap_texture(next_sprite)
	engine.clear_spawned()
	
	
