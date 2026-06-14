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
var _resource_sources: Dictionary = {}
var _next_chain_index := 1


func _ready() -> void:
	reset_grid()


func reset_grid() -> void:
	cells.clear()
	_interval_timers.clear()
	_resource_sources.clear()
	_next_chain_index = 1
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
	return _trigger_piece_with_context(cell, event_name, {})


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
				_apply_trigger(cell, piece_id, trigger, {})
			_interval_timers[timer_key] = next_time


func produce_from_intervals() -> void:
	for cell in cells.keys():
		trigger_piece(cell, "on_interval")


func _trigger_piece_with_context(cell: Vector2i, event_name: String, context: Dictionary) -> bool:
	var piece_id := str(cells.get(cell, ""))
	if piece_id.is_empty():
		return false
	var piece := ContentDatabase.get_garden_piece(piece_id)
	for trigger in piece.get("triggers", []):
		if trigger.get("event", "") == event_name:
			return _apply_trigger(cell, piece_id, trigger, context)
	return false


func _trigger_event_for_all_pieces(event_name: String, context: Dictionary) -> void:
	for cell in cells.keys():
		_trigger_piece_with_context(cell, event_name, context)


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


func _apply_trigger(cell: Vector2i, piece_id: String, trigger: Dictionary, context: Dictionary = {}) -> bool:
	var action := str(trigger.get("action", ""))
	var trigger_context := _build_trigger_context(piece_id, trigger, context)
	var effect_result := {}
	var succeeded := false
	match action:
		"produce_resource":
			effect_result = GardenEffectResolver.resolve_effect(_build_effect_request(cell, piece_id, trigger, trigger_context))
			succeeded = bool(effect_result.get("success", false))
			if succeeded:
				_store_resource_source_from_effect(effect_result, trigger_context)
		"grant_player_shield":
			effect_result = GardenEffectResolver.resolve_effect(_build_effect_request(cell, piece_id, trigger, trigger_context))
			succeeded = bool(effect_result.get("success", false))
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
	Bloomchains.record_trigger(cell, piece_id, trigger, trigger_context)
	_dispatch_follow_up_events(trigger, trigger_context)
	return true


func _build_effect_request(cell: Vector2i, piece_id: String, trigger: Dictionary, context: Dictionary) -> Dictionary:
	return {
		"action": str(trigger.get("action", "")),
		"cell": cell,
		"piece_id": piece_id,
		"trigger": trigger.duplicate(true),
		"context": context.duplicate(true)
	}


func _store_resource_source_from_effect(result: Dictionary, context: Dictionary) -> void:
	var resource_id := str(result.get("resource", ""))
	if resource_id.is_empty():
		return
	_resource_sources[resource_id] = context.duplicate(true)


func _build_trigger_context(piece_id: String, trigger: Dictionary, context: Dictionary) -> Dictionary:
	var trigger_context := context.duplicate(true)
	var resource_id := str(trigger.get("resource", ""))
	if trigger.get("action", "") == "grant_player_shield" and trigger_context.get("chain_id", "") == "" and _resource_sources.has(resource_id):
		trigger_context = _resource_sources[resource_id].duplicate(true)
	if str(trigger_context.get("chain_id", "")).is_empty():
		trigger_context["chain_id"] = _make_chain_id(piece_id, trigger)
	trigger_context["source_piece_id"] = piece_id
	trigger_context["source_trigger_id"] = trigger.get("id", trigger.get("action", ""))
	return trigger_context


func _dispatch_follow_up_events(trigger: Dictionary, context: Dictionary) -> void:
	for event_name in trigger.get("follow_up_events", []):
		_trigger_event_for_all_pieces(str(event_name), context)


func _make_chain_id(piece_id: String, trigger: Dictionary) -> String:
	var chain_id := "%s:%s:%s" % [piece_id, trigger.get("id", trigger.get("action", "")), _next_chain_index]
	_next_chain_index += 1
	return chain_id


func _get_interval_timer_key(cell: Vector2i, trigger: Dictionary) -> String:
	return "%s,%s:%s" % [cell.x, cell.y, trigger.get("id", trigger.get("action", "on_interval"))]


func _clear_interval_timers_for_cell(cell: Vector2i) -> void:
	var prefix := "%s,%s:" % [cell.x, cell.y]
	for timer_key in _interval_timers.keys():
		if str(timer_key).begins_with(prefix):
			_interval_timers.erase(timer_key)
