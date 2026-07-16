@tool
extends Node3D

@export var cups: Array[Node3D]
@export_tool_button("Swap cups") var test_swap := play_trick
@export_tool_button("Reset cups") var do_reset := reset_cups
@export_tool_button("Reveal cup") var test_reveal := reveal.bind(1)

const SWAP_DURATION := 0.3
const REVEAL_DURATION := 0.2
const NUM_SWAPS := 10

var has_started := false
var is_playing := false


func play_and_check_if_done() -> bool:
	if not has_started:
		has_started = true
		play_trick()

	if not is_playing:
		has_started = false
		return true

	return false


func has_placed_item() -> bool:
	return true


func reveal_and_check_if_done() -> bool:
	if not has_started:
		has_started = true
		play_reveal()

	if not is_playing:
		has_started = false
		return true

	return false


func play_trick() -> void:
	is_playing = true
	await reveal(0)
	await reveal(1)
	await reveal(2)
	await perform_swaps()
	is_playing = false


func play_reveal() -> void:
	is_playing = true
	await reveal(1)
	await reveal(0)
	await reveal(2)
	is_playing = false


func perform_swaps() -> void:
	for i in NUM_SWAPS:
		var first := randi() % 3
		var second := posmod(first + randi() % 2 + 1, 3)
		assert(first != second)
		await swap_cups(first, second)


func reveal(cup_idx: int) -> void:
	var cup := cups[cup_idx]
	if cup.has_node("CupMesh"):
		cup = cup.get_node("CupMesh")

	var tween := create_tween()
	tween.tween_property(cup, "position:y", 0.2, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "position:z", -0.1, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "rotation_degrees:x", -45, REVEAL_DURATION)
	tween.tween_interval(1.0)
	tween.tween_property(cup, "position:y", 0.0, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "position:z", 0.0, REVEAL_DURATION)
	tween.parallel().tween_property(cup, "rotation_degrees:x", 0.0, REVEAL_DURATION)

	await tween.finished


func swap_cups(first: int, second: int) -> void:
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
