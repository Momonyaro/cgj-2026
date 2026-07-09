extends AudioStreamPlayer2D

func _enter_tree() -> void:
	finished.connect(_on_stream_finished)
	
func _on_stream_finished() -> void:
	stop()
	queue_free()