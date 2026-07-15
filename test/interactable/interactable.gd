extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func grab(cursor: Cursor) -> CollisionObject3D:
	print("Grabbed by ", cursor)
	return self


func ungrab(cursor: Cursor) -> void:
	print("Released by ", cursor)
