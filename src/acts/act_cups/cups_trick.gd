@tool
extends StaticBody3D

@export var cups: Array[Cup]
@export var ball: GrabbableItem
@export_tool_button("Swap cups") var test_swap := play_trick
@export_tool_button("Reset cups") var do_reset := reset_cups
@export_tool_button("Reveal cup") var test_reveal := reveal.bind(1)
@export var cup_material: StandardMaterial3D

const Perfection := preload("res://src/acts/act_cups/perfect_cups_collection.tres")
const Bad := preload("res://src/acts/act_cups/bad_cups_collection.tres")

const SWAP_DURATION := 0.3
const REVEAL_DURATION := 0.2
const NUM_SWAPS := 10

var has_started := false
var is_playing := false
var has_grabbed_ball := false


func _ready() -> void:
	for i in len(cups):
		cups[i].index = i
		cups[i].interactable = false
	ball.grabbed.connect(func(): has_grabbed_ball = true)
	ball.axis_lock_linear_x = true


func play_and_check_if_done() -> bool:
	if not has_started:
		has_started = true
		play_trick()

	if not is_playing:
		has_started = false
		return true

	return false


func get_ball_mat() -> StandardMaterial3D:
	var ball_mesh := ball.get_node("BallMesh") as MeshInstance3D
	return ball_mesh.material_override as StandardMaterial3D


func has_placed_item() -> bool:
	get_ball_mat().no_depth_test = true
	ball.axis_lock_linear_x = false
	for cup in cups:
		cup.interactable = true
		if cup.is_full:
			get_ball_mat().no_depth_test = false
			ball.axis_lock_linear_x = true
			return true
	return false


func reveal_and_check_if_done() -> bool:
	if not has_started:
		has_started = true
		for cup in cups:
			cup.interactable = false
		play_reveal()

	if not is_playing:
		has_started = false
		return true

	return false


func play_trick() -> void:
	if Engine.is_editor_hint():
		return

	is_playing = true
	await reveal(0)
	await reveal(1)
	await reveal(2)
	await perform_swaps()
	ball.collision_layer |= 0x02
	is_playing = false


func play_reveal() -> void:
	is_playing = true
	ball.collision_layer &= ~0x02
	var perfection := 0
	if !cups[1].is_full and has_grabbed_ball:
		Stage.audience.excite(0.2)
		ScoreManager.add_score(87)
		print("ball gone wow")
		perfection += 1
	else:
		Stage.audience.bore(0.2)
		print("ball remains boo")
	await reveal(1)
	SFX.stop("drums")
	SFX.play("drum_roll_finish")
	if cups[2].is_full:
		Stage.audience.excite(0.6)
		ScoreManager.add_score(168)
		perfection += 1
	else:
		Stage.audience.bore(0.4)
		ScoreManager.add_score(16)
	await reveal(2)
	is_playing = false

	if ActEngine.singleton:
		if perfection >= 2:
			ActEngine.singleton.append_events(Perfection.events)
		else:
			ActEngine.singleton.append_events(Bad.events)


func perform_swaps() -> void:
	for i in NUM_SWAPS:
		var first := randi() % 3
		var second := posmod(first + randi() % 2 + 1, 3)
		assert(first != second)
		await swap_cups(first, second)


func reveal(cup_idx: int) -> void:
	var cup := cups[cup_idx].get_node("CupMesh")

	SFX.play("cup_reveal")

	var tween := create_tween()
	tween.tween_property(cup, "position:y", 0.4, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "position:z", -0.1, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "rotation_degrees:z", 45, REVEAL_DURATION)
	tween.tween_interval(1.0)
	tween.tween_callback(SFX.play.bind("cup_unreveal"))
	tween.tween_property(cup, "position:y", 0.0, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "position:z", 0.0, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "rotation_degrees:z", 0.0, REVEAL_DURATION)
	tween.tween_interval(0.3)

	await tween.finished


func swap_cups(first: int, second: int) -> void:
	SFX.play("cup_woosh")
	var first_cup := cups[first]
	var second_cup := cups[second]
	var first_pos := first_cup.position
	var second_pos := second_cup.position
	var tween := create_tween().set_parallel(true)
	tween.tween_property(first_cup, "position:x", second_pos.x, SWAP_DURATION)
	tween.tween_property(second_cup, "position:x", first_pos.x, SWAP_DURATION)
	tween.tween_method(circle_cup.bind(first_cup), 0.0, PI, SWAP_DURATION)
	tween.tween_method(circle_cup.bind(second_cup), PI, TAU, SWAP_DURATION)
	await tween.finished


func reset_cups() -> void:
	cups[0].position.x = -0.67
	cups[1].position.x = 0.0
	cups[2].position.x = 0.67
	for cup in cups:
		cup.position.z = 0.0


func circle_cup(t: float, cup: Node3D) -> void:
	cup.position.z = sin(t) * 0.3
