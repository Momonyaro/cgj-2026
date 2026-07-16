extends ActEvent
class_name WaitSceneReadyEvent

func get_type() -> int:
	return WAIT_SCENE_READY

func execute() -> void:
	var level_loader := Stage.level_loader
	var tree := level_loader.get_tree()
	while level_loader.is_loading:
		await tree.process_frame
	finished.emit()
