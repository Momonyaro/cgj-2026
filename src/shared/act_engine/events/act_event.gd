@abstract
extends Resource
class_name ActEvent

signal finished()

enum { WALK, SWAP, WAIT, CONDITIONAL, SPAWN, CALL }

@abstract
func get_type() -> int

@abstract
func execute()
