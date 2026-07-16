@tool
extends Area3D

signal target_updated(in_bounds: bool)

@export var target_object: StringName = &"Bunny"
@export var area_material: StandardMaterial3D

var _material: StandardMaterial3D
var _target_in_bounds := false:
	set(value):
		_target_in_bounds = value
		target_updated.emit(value)
var _is_ready := false

@export var bounds: Vector3 = Vector3(1, 1, 6):
	set = update_bounds

func _enter_tree():
	if Engine.is_editor_hint():
		return
	
	_material = area_material.duplicate()
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	target_updated.connect(_on_target_update)

func _ready():
	_is_ready = true
	
	if not Engine.is_editor_hint():
		$MeshInstance3D.mesh.material = _material

func _exit_tree():
	ScoreManager.set_ticker("TargetInDetectArea", false)

func update_bounds(value: Vector3):
	bounds = value
	if Engine.is_editor_hint() or _is_ready:
		$CollisionShape3D.shape.size = bounds
		$CollisionShape3D.position = Vector3(0, 0, -bounds.z / 2.0)
		$MeshInstance3D.mesh.size = Vector2(bounds.x, bounds.y)

func _on_body_enter(body: Node3D) -> void:
	if body.name == target_object:
		_target_in_bounds = true

func _on_body_exit(body: Node3D) -> void:
	if body.name == target_object:
		_target_in_bounds = false

func _on_target_update(in_bounds: bool) -> void:
	if not _is_ready:
		return
	
	ScoreManager.set_ticker("TargetInDetectArea", in_bounds)
	_material.albedo_color = Color.WHITE if in_bounds else Color.RED
