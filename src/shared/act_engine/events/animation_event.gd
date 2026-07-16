extends ActEvent
class_name AnimationEvent

@export_node_path var animator: NodePath = ""
@export var animation: StringName = ""
@export var async := false


func get_type():
	return ANIMATION

func execute():
	var animator_node := engine.get_node(animator) as AnimationPlayer
	animator_node.play(animation)
	if async:
		finished.emit()
	else:
		animator_node.animation_finished.connect(func(anim: StringName): finished.emit(), CONNECT_ONE_SHOT)
	
