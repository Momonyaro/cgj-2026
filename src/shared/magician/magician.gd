class_name Magician
extends Node3D

signal finished_spin

# Front and back relative to the camera
@export var front_material: StandardMaterial3D
@export var back_material: StandardMaterial3D
@export var spin_duration: float = 0.2
@export var default_texture: Texture2D

@export_subgroup("Debug")
@export var debug_enabled: bool = false
@export var debug_textures: Array[Texture2D] = []

@onready var face_root: Node3D = $BodyPivot/ObjRoot/FaceRoot

var texture: Texture2D:
	set = swap_texture

var _tween: Tween
var _spin_direction: int = 1 # -1 or 1
var _current_index: int = 0

static var current_magician: Node3D

# ---- Godot Events ----


func _ready() -> void:
	front_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, default_texture)
	back_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, default_texture)
	current_magician = self


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and debug_enabled:
		if event is InputEventKey:
			if event.keycode == KEY_SPACE:
				_current_index = (_current_index + 1) % debug_textures.size()
				texture = debug_textures[_current_index]

# ---- Public Functions ----


func swap_texture(_texture: Texture2D) -> void:
	# Set back buffer to current front before replacing it.
	var current_front: Texture2D = front_material.get_texture(BaseMaterial3D.TEXTURE_ALBEDO)
	back_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, current_front)

	# Set front to new texture and prepare for the flip anim
	front_material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, _texture)
	_do_spin()
	SFX.play("flip_woosh")

# ---- Private Functions ---


func _do_spin() -> void:
	if _tween:
		_tween.kill()
		_tween = null

	_spin_direction = 1 if randf() >= 0.5 else -1

	face_root.rotation_degrees.y = 180 * _spin_direction
	_tween = create_tween()
	_tween.tween_method(_spin_tween, 0.0, 1.0, spin_duration)
	_tween.finished.connect(finished_spin.emit)


func _spin_tween(x: float) -> void:
	if _spin_direction > 0:
		face_root.rotation_degrees.y = 180.0 - (180.0 * x)
	else:
		face_root.rotation_degrees.y = -180.0 + (180.0 * x)
