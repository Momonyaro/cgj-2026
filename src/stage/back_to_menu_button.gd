extends TextureButton

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = Stage.level_loader.current_index >= 0
