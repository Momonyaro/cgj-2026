extends ActEvent
class_name WaitExpressionEvent

const CONDITION_WAIT_LIMIT := 100000

## Context path should be relative to the ActEngine
@export_node_path var context: NodePath = ""
@export_multiline var expression: String = ""

var _time_started := 0


func get_type() -> int:
	return WAIT_EXPRESSION

## Wait's until the expression is true!
func execute() -> void:
	_time_started = Time.get_ticks_msec()
	var context_node := engine.get_node(context)
	
	if expression.strip_edges() == "":
		finished.emit()
	var e := Expression.new()
	var error := e.parse(expression, ["Stage"])
	
	if error != OK:
		push_error("INVALID EXPRESSION")
	
	while true:
		var result = e.execute([Stage], context_node)
		if e.has_execute_failed():
			push_error("Failed to execute condition: " + e.get_error_text())
			return
		
		if result is not bool:
			push_error("Conditional result is not a boolean:", result)
		
		if result == true:
			finished.emit()
			return
		
		await context_node.get_tree().process_frame
		if Time.get_ticks_msec() - _time_started > CONDITION_WAIT_LIMIT:
			push_warning("Condition has been evaluated for over %dms!" % CONDITION_WAIT_LIMIT)
