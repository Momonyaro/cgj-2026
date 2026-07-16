extends ActEvent
class_name SpawnEvent

@export_file("*.tscn") var scene := ""

@export var local := true
@export var parent := false
@export_node_path var spawn_from: NodePath = ""

@export var spawn_position := Vector3.ZERO
@export var track_spawned_node := true
@export var metadata: Dictionary[StringName, Variant] = {}


func get_type() -> int:
	return SPAWN

func execute():
	var scene_root := Stage.level_loader.current_level
	var spawner := scene_root.get_node(spawn_from)
	var node := (load(scene) as PackedScene).instantiate()
	
	
	assert(spawner, str(spawn_from.get_concatenated_names()))

	if parent:
		spawner.add_child(node)
	else:
		scene_root.add_child(node)
		
	if "position" in node:
		if local and parent:
			node.position = spawn_position
		elif local and "position" in spawner:
			node.position = spawner.position + spawn_position
		else:
			node.global_position = spawn_position
	
	for m in metadata:
		node.set_meta(m, metadata[m])

	if track_spawned_node:
		engine.spawned.append(node)
	
	finished.emit()
