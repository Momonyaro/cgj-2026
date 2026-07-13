extends Node3D

@export var curtain_l: MeshInstance3D
@export var curtain_r: MeshInstance3D

@export var min_max_move: Vector2
@export_range(0.0, 1.0) var move_amount: float:
	set = set_move_amount

func _ready():
	var l_move_amount = lerp(min_max_move.x, min_max_move.y, move_amount)
	var r_move_amount = lerp(min_max_move.x, min_max_move.y, move_amount)
	curtain_l._open_amount = l_move_amount
	curtain_l.open_amount = l_move_amount
	curtain_r._open_amount = r_move_amount
	curtain_r.open_amount = r_move_amount

func set_move_amount(x: float):
	move_amount = x
	var l_move_amount = lerp(min_max_move.x, min_max_move.y, x)
	var r_move_amount = lerp(min_max_move.x, min_max_move.y, x)
	
	if curtain_l:
		curtain_l.open_amount = l_move_amount
	if curtain_r:
		curtain_r.open_amount = r_move_amount
