extends Node

signal grid_reset
signal piece_placed(cell: Vector2i, piece_id: String)
signal piece_removed(cell: Vector2i, piece_id: String)
signal piece_triggered(cell: Vector2i, piece_id: String, trigger: Dictionary)
signal placement_failed(cell: Vector2i, piece_id: String, reason: String)

const GRID_SIZE := Vector2i(3, 3)
const HEART_CELL := Vector2i(1, 1)

var cells: Dictionary = {}
var selected_cell := HEART_CELL
var last_trigger: Dictionary = {}
var _interval_timers: Dictionary = {}


func _ready() -> void:
	reset_grid()


func reset_grid() -> void:
	cells.clear()
	_interval_timers.clear()
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			cells[Vector2i(x, y)] = ""
	place_piece(HEART_CELL, "saintmoth", true)
	grid_reset.emit()


func place_piece(cell: Vector2i, piece_id: String, allow_heart := false) -> bool:
	if not is_valid_cell(cell):
		placement_failed.emit(cell, piece_id, "Cell is outside the 3x3 garden")
		return false
	if cell == HEART_CELL and not allow_heart:
		placement_failed.emit(cell, piece_id, "Heart Tile is reserved for the companion")
		return false
	if not cells.get(cell, "").is_empty():
		placement_failed.emit(cell, piece_id, "Cell already has a garden piece")
		return false
	if ContentDatabase.get_garden_piece(piece_id).is_empty():
		placement_failed.emit(cell, piece_id, "Unknown garden piece id")
		return false
	cells[cell] = piece_id
	_clear_interval_timers_for_cell(cell)
	piece_placed.emit(cell, piece_id)
	return true


func place_piece_in_first_empty_cell(piece_id: String) -> Vector2i:
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var cell := Vector2i(x, y)
			if cell == HEART_CELL:
				continue
			if not str(cells.get(cell, "")).is_empty():
				continue
			if place_piece(cell, piece_id):
				return cell
	return Vector2i(-1, -1)


func remove_piece(cell: Vector2i) -> String:
	if not is_valid_cell(cell) or cell == HEART_CELL:
		return ""
	var piece_id := str(cells.get(cell, ""))
	if piece_id.is_empty():
		return ""
	cells[cell] = ""
	_clear_interval_timers_for_cell(cell)
	piece_removed.emit(cell, piece_id)
	return piece_id


func trigger_piece(cell: Vector2i, event_name: String) -> bool:
	var piece_id := str(cells.get(cell, ""))
	if piece_id.is_empty():
		return false
	var piece := ContentDatabase.get_garden_piece(piece_id)
	for trigger in piece.get("triggers", []):
		if trigger.get("event", "") == event_name:
			return _apply_trigger(cell, piece_id, trigger)
	return false


func pulse_selected() -> bool:
	return trigger_piece(selected_cell, "on_pulse")


func process_intervals(delta: float) -> void:
	for cell in cells.keys():
		var piece_id := str(cells.get(cell, ""))
		if piece_id.is_empty():
			continue
		var piece := ContentDatabase.get_garden_piece(piece_id)
		for trigger in piece.get("triggers", []):
			if trigger.get("event", "") != "on_interval":
				continue
			var cooldown := float(trigger.get("cooldown", 0.0))
			if cooldown <= 0.0:
				continue
			var timer_key := _get_interval_timer_key(cell, trigger)
			var next_time := float(_interval_timers.get(timer_key, 0.0)) + delta
			if next_time >= cooldown:
				next_time -= cooldown
				_apply_trigger(cell, piece_id, trigger)
			_interval_timers[timer_key] = next_time


func produce_from_intervals() -> void:
	for cell in cells.keys():
		trigger_piece(cell, "on_interval")


func get_piece_at(cell: Vector2i) -> Dictionary:
	var piece_id := str(cells.get(cell, ""))
	if piece_id.is_empty():
		return {}
	return ContentDatabase.get_garden_piece(piece_id)


func get_neighbors(cell: Vector2i, include_diagonal := false) -> Array[Vector2i]:
	var offsets: Array[Vector2i] = [
		Vector2i(0, -1),
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(-1, 0)
	]
	if include_diagonal:
		offsets.append_array([
			Vector2i(-1, -1),
			Vector2i(1, -1),
			Vector2i(1, 1),
			Vector2i(-1, 1)
		])
	var result: Array[Vector2i] = []
	for offset in offsets:
		var neighbor := cell + offset
		if is_valid_cell(neighbor):
			result.append(neighbor)
	return result


func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_SIZE.x and cell.y >= 0 and cell.y < GRID_SIZE.y


func as_debug_rows() -> Array[String]:
	var rows: Array[String] = []
	for y in range(GRID_SIZE.y):
		var row: Array[String] = []
		for x in range(GRID_SIZE.x):
			var id := str(cells.get(Vector2i(x, y), ""))
			row.append(id if not id.is_empty() else ".")
		rows.append(" | ".join(PackedStringArray(row)))
	return rows


func _apply_trigger(cell: Vector2i, piece_id: String, trigger: Dictionary) -> bool:
	var action := str(trigger.get("action", ""))
	var succeeded := false
	match action:
		"produce_resource":
			succeeded = _apply_produce_resource(trigger)
		"grant_player_shield":
			succeeded = _apply_grant_player_shield_cost(trigger)
		_:
			succeeded = false
	if not succeeded:
		return false
	last_trigger = {
		"cell": cell,
		"piece_id": piece_id,
		"trigger": trigger.duplicate(true)
	}
	piece_triggered.emit(cell, piece_id, trigger)
	Bloomchains.record_trigger(cell, piece_id, trigger)
	return true


func _apply_produce_resource(trigger: Dictionary) -> bool:
	var resource_id := str(trigger.get("resource", ""))
	var amount := int(trigger.get("amount", 1))
	if resource_id.is_empty() or amount <= 0:
		return false
	GardenResources.add(resource_id, amount)
	return true


func _apply_grant_player_shield_cost(trigger: Dictionary) -> bool:
	var resource_id := str(trigger.get("resource", ""))
	var cost := int(trigger.get("cost", 0))
	if resource_id.is_empty() or cost <= 0:
		return false
	# Shield is applied by CompanionController after this successful trigger emits.
	return GardenResources.spend(resource_id, cost)


func _get_interval_timer_key(cell: Vector2i, trigger: Dictionary) -> String:
	return "%s,%s:%s" % [cell.x, cell.y, trigger.get("id", trigger.get("action", "on_interval"))]


func _clear_interval_timers_for_cell(cell: Vector2i) -> void:
	var prefix := "%s,%s:" % [cell.x, cell.y]
	for timer_key in _interval_timers.keys():
		if str(timer_key).begins_with(prefix):
			_interval_timers.erase(timer_key)
