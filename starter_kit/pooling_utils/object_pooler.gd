class_name ObjectPooler extends Node

# Currently this is a basic component but we could expand this to have a parent autoload
# in order to prevent pool reloads when changing scenes.

@export var _pool_object: PackedScene
@export var _pool_size: int = 25
@export var _pool_expand_by: int = 1

var _pool: Array = []

# ---- Godot Events ----

func _enter_tree() -> void:
	if not _pool_object:
		push_warning("ObjectPooler: no object to pool!")
		return
	
	for i in _pool_size:
		var instance := _pool_object.instantiate()
		add_child(instance)
		if instance.has_method("hide"):
			instance.hide()
		instance.set_process(false)
		_pool.push_back(instance)

# ---- Public Functions ----

func get_instance() -> Node:
	for item in _pool:
		# Item is hidden and probably also disabled, so we can use it.
		if not item.visible:
			return item
	
	# No hidden items, so we need to expand the pool.
	push_warning("Pool <", name, "> exhausted, expanding by ", _pool_expand_by)
	for i in _pool_expand_by:
		var instance := _pool_object.instantiate()
		add_child(instance)
		if instance.has_method("hide"):
			instance.hide()
		instance.set_process(false)
		_pool.push_back(instance)
	
	return _pool.back()
	