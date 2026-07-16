@abstract
extends Resource
class_name ActEvent

signal finished()

enum { WALK, SWAP, WAIT, WAIT_EXPRESSION, WAIT_SCENE_READY, SPAWN, CAPTIVATE, CALL, VISIBILITY, ANGLE_SPOTLIGHT, SOUND_EFFECT, ANIMATION }

# -- Bindings --
var engine: ActEngine = null

@abstract
func get_type() -> int

@abstract
func execute()
