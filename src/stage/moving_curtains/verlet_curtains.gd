extends MeshInstance3D

@export var columns := 80
@export var rows := 30

@export var open_amount: float:
	set = update_open
@export var spacing := 0.1
@export var gravity := Vector3(0, -9.8, 0)
@export var iterations := 8
@export var damping := 0.995
@export var curtain_material: StandardMaterial3D

var _open_amount := 0.0
var _particles: Array[Particle] = []
var _constraints: Array[Constraint] = []
var _mesh := ArrayMesh.new()

# ---- Godot Events ----

func _ready() -> void:
	_create_particles()
	_create_constraints()
	mesh = _mesh
	_update_mesh()

func _physics_process(delta):
	_open_amount = lerp(_open_amount, open_amount, delta * 3)
	_move_top_row()
	_simulate(delta)
	
	for i in iterations:
		_solve_constraints()
	
	_update_mesh()

# ---- Private Functions ----

func update_open(x: float):
	open_amount = x

func _update_mesh():
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	
	_update_vertices(vertices)
	_update_uvs(uvs)
	_update_indices(indices)
	_update_normals(normals, vertices, indices)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	_mesh.clear_surfaces()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mesh.surface_set_material(0, curtain_material)

func _update_vertices(vertices: PackedVector3Array):
	for p in _particles:
		vertices.push_back(p.position)

func _update_uvs(uvs: PackedVector2Array):
	for y in rows:
		for x in columns:
			uvs.push_back(Vector2(
				float(x) / (columns - 1),
				float(y) / (rows - 1)
			))

func _update_indices(indices: PackedInt32Array):
	for y in rows - 1:
		for x in columns - 1:
			var a = _index(x, y)
			var b = _index(x + 1, y)
			var c = _index(x, y + 1)
			var d = _index(x + 1, y + 1)
			
			indices.push_back(a)
			indices.push_back(c)
			indices.push_back(b)
			
			indices.push_back(b)
			indices.push_back(c)
			indices.push_back(d)

func _update_normals(normals: PackedVector3Array, vertices: PackedVector3Array, indices: PackedInt32Array):
	normals.resize(vertices.size())

	for i in normals.size():
		normals[i] = Vector3.ZERO

	for i in range(0, indices.size(), 3):
		var ia = indices[i]
		var ib = indices[i + 1]
		var ic = indices[i + 2]

		var v0 = vertices[ia]
		var v1 = vertices[ib]
		var v2 = vertices[ic]

		var n = (v1 - v0).cross(v2 - v0).normalized()

		normals[ia] += n
		normals[ib] += n
		normals[ic] += n

	for i in normals.size():
		normals[i] = normals[i].normalized()

func _move_top_row():
	var center_column = (columns - 1) * 0.5

	for x in range(columns):
		var p = _particles[_index(x, 0)]
		var target_x: float
		if x < center_column:
			target_x = x * spacing - _open_amount
		else:
			target_x = x * spacing + _open_amount
		
		var new_position = Vector3(
			target_x,
			p.position.y,
			p.position.z
		)
		
		p.prev_position = p.position
		p.position = p.position.lerp(
			new_position,
			0.1
		)

func _simulate(delta: float):
	for p in _particles:
		if p.pinned:
			continue
		
		var velocity = (p.position - p.prev_position) * damping
		p.prev_position = p.position
		p.position += velocity
		p.position += gravity * delta * delta

func _solve_constraints():
	const stiffness := 0.8
	
	for c in _constraints:
		var a = _particles[c.a]
		var b = _particles[c.b]
		
		var delta = b.position - a.position
		var distance = delta.length()
		
		if distance == 0:
			continue
		
		var difference = (
			(distance - c.rest_length)
			/ distance
		) * c.stiffness
		
		if a.pinned:
			b.position -= delta * difference * stiffness
		elif b.pinned:
			b.position -= delta * difference * stiffness
		else:
			var correction = delta * difference * 0.5 * stiffness
			a.position += correction
			b.position -= correction

func _create_particles() -> void:
	for y in rows:
		for x in columns:
			var pos = Vector3(
				x * spacing,
				-y * spacing,
				0
			)
			
			var pinned = (y == 0)
			_particles.push_back(Particle.new(pos, pinned))
	pass

func _create_constraints() -> void:
	for y in rows:
		for x in columns:
			# Structural Constraints
			if x < columns - 1:
				_connect(_index(x, y), _index(x + 1, y), 0.5)
			if y < rows - 1:
				_connect(_index(x, y), _index(x, y + 1), 1.0)
			
			# Shear Constraints (alternating)
			if x < columns - 1 and y < rows - 1:
				if (x + y) % 2 == 0:
					_connect(_index(x, y), _index(x + 1, y + 1))
				else:
					_connect(_index(x + 1, y), _index(x, y + 1))
			
			# Bending Constraints
			if x < columns - 2:
				_connect(_index(x, y), _index(x + 2, y))
			if y < rows - 2:
				_connect(_index(x, y), _index(x, y + 2))
			
			if y < 5 and y < rows - 1:
				_connect(
					_index(x, y),
					_index(x, y + 1),
					1.5
				)

func _connect(a: int, b: int, strength := 1.0):
	var length = _particles[a].position.distance_to(
		_particles[b].position
	)
	
	_constraints.push_back(
		Constraint.new(a, b, length, strength)
	)

func _index(x: int, y: int) -> int:
	return y * columns + x

# -----

class Particle:
	var position: Vector3
	var prev_position: Vector3
	var pinned := false
	
	func _init(pos: Vector3, is_pinned := false):
		position = pos
		prev_position = pos
		pinned = is_pinned

class Constraint:
	var a: int
	var b: int
	var rest_length: float
	var stiffness: float
	
	func _init(a_index: int, b_index: int, length: float, strength := 1.0):
		a = a_index
		b = b_index
		rest_length = length
		stiffness = strength
