extends Node3D

const BOMB := preload("res://src/shared/interactables/smoke_bomb/smoke_bomb.tscn")

func grab(p_cursor: Cursor) ->  CollisionObject3D:
	var bomb := BOMB.instantiate() as Node3D
	Stage.level_loader.current_level.add_child(bomb)
	bomb.global_position = global_position + Vector3.UP
	return bomb.grab(p_cursor)
