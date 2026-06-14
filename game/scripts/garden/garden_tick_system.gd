extends Node

var _interval_timers: Dictionary = {}


func _ready() -> void:
	GardenManager.grid_reset.connect(reset)
	GardenManager.piece_placed.connect(_on_piece_placed)
	GardenManager.piece_removed.connect(_on_piece_removed)


func reset() -> void:
	_interval_timers.clear()


func clear_cell(cell: Vector2i) -> void:
	var prefix := "%s,%s:" % [cell.x, cell.y]
	for timer_key in _interval_timers.keys():
		if str(timer_key).begins_with(prefix):
			_interval_timers.erase(timer_key)


func process_intervals(delta: float) -> void:
	var cells := GardenManager.get_all_cells()
	for cell in cells.keys():
		var piece_id := str(cells.get(cell, ""))
		if piece_id.is_empty():
			continue
		for trigger in GardenTriggerSystem.get_matching_triggers(piece_id, "on_interval"):
			var cooldown := float(trigger.get("cooldown", 0.0))
			if cooldown <= 0.0:
				continue
			var timer_key := _get_interval_timer_key(cell, trigger)
			var next_time := float(_interval_timers.get(timer_key, 0.0)) + delta
			if next_time >= cooldown:
				next_time -= cooldown
				GardenManager.apply_trigger_request(cell, piece_id, trigger, {})
			_interval_timers[timer_key] = next_time


func _on_piece_placed(cell: Vector2i, _piece_id: String) -> void:
	clear_cell(cell)


func _on_piece_removed(cell: Vector2i, _piece_id: String) -> void:
	clear_cell(cell)


func _get_interval_timer_key(cell: Vector2i, trigger: Dictionary) -> String:
	return "%s,%s:%s" % [cell.x, cell.y, trigger.get("id", trigger.get("action", "on_interval"))]
