extends ActEvent
class_name HideEvent

## Context path should be relative to the ActEngine
@export_node_path var target: NodePath = ""


func get_type() -> int:
	return VISIBILITY


func execute() -> void:
	var target_node := engine.get_node(target)
	target_node.hide()
