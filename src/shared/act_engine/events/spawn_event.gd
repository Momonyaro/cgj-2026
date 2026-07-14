extends ActEvent
class_name SpawnEvent

@export_file("*.tscn") var scene := ""

@export var local := true
@export var parent := false
@export_node_path var spawn_from: NodePath = ""

@export var spawn_position := Vector3.ZERO

# -- Binds --
var root: Node

func get_type() -> int:
	return SPAWN

func execute():
	var node := (load(scene) as PackedScene).instantiate()
	var spawner := root.get_node(spawn_from)
	
	assert(spawner, str(spawn_from.get_concatenated_names()))

	if parent:
		spawner.add_child(node)
	else:
		Stage.level_loader.current_level.add_child(node)
		
	if "position" in node:
		if local and parent:
			node.position = spawn_position
		elif local and "position" in spawner:
			node.position = spawner.position + spawn_position
		else:
			node.global_position = spawn_position
	finished.emit()
