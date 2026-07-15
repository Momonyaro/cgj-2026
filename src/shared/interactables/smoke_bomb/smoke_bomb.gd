extends GrabbableItem

const SMOKE := preload("res://src/shared/interactables/smoke_bomb/smoke/smoke.tscn")

func _process(_delta: float) -> void:
	if is_on_floor() and is_grabbed == false:
			_spawn_smoke()
			queue_free.call_deferred()

func _spawn_smoke():
	var smoke := SMOKE.instantiate() as Node3D
	Stage.level_loader.current_level.add_child(smoke)
	smoke.global_position = global_position + Vector3.BACK + Vector3.UP
