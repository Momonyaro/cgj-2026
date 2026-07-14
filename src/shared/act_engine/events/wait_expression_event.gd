extends ActEvent
class_name WaitExpressionEvent

const CONDITION_WAIT_LIMIT := 100000

@export_multiline var expression: String = ""

var _time_started := 0

# -- Binds --
var inputs := []
var context: Node


func get_type() -> int:
	return WAIT_EXPRESSION

func execute() -> void:
	_time_started = Time.get_ticks_msec()
	if expression.strip_edges() == "":
		finished.emit()
	var e := Expression.new()
	var error := e.parse(expression)
	
	if error != OK:
		push_error("INVALID EXPRESSION")
	
	while true:
		var result = e.execute(inputs, context)
		if e.has_execute_failed():
			push_error("Failed to execute condition: " + e.get_error_text())
			return
		
		if result is not bool:
			push_error("Conditional result is not a boolean:", result)
		
		if result:
			finished.emit()
			return
		
		await context.get_tree().process_frame
		if Time.get_ticks_msec() - _time_started > CONDITION_WAIT_LIMIT:
			push_warning("Condition has been evaluated for over %dms!" % CONDITION_WAIT_LIMIT)
