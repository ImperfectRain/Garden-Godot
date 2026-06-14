extends RefCounted

var duration_seconds := 30.0
var elapsed_seconds := 0.0
var is_active := false
var is_complete := false


func start(duration: float) -> void:
	duration_seconds = max(duration, 0.1)
	elapsed_seconds = 0.0
	is_active = true
	is_complete = false


func process(delta: float) -> bool:
	if not is_active or is_complete:
		return false
	elapsed_seconds = min(elapsed_seconds + delta, duration_seconds)
	if elapsed_seconds >= duration_seconds:
		is_complete = true
		is_active = false
		return true
	return false


func get_remaining_seconds() -> float:
	return max(duration_seconds - elapsed_seconds, 0.0)
