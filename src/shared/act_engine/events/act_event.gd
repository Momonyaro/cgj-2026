@abstract
extends Resource
class_name ActEvent

signal finished()

enum { WALK, SWAP, WAIT, WAIT_EXPRESSION, SPAWN, CALL }

@abstract
func get_type() -> int

@abstract
func execute()
