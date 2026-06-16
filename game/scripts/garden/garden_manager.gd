extends Node

signal grid_reset
signal piece_placed(cell: Vector2i, piece_id: String)
signal piece_removed(cell: Vector2i, piece_id: String)
signal piece_triggered(cell: Vector2i, piece_id: String, trigger: Dictionary)
signal placement_failed(cell: Vector2i, piece_id: String, reason: String)
signal selected_cell_changed(cell: Vector2i)

const GRID_SIZE := Vector2i(3, 3)
const HEART_CELL := Vector2i(1, 1)

var cells: Dictionary = {}
var selected_cell := HEART_CELL
var last_trigger: Dictionary = {}
var _resource_sources: Dictionary = {}
var _next_chain_index := 1


func _ready() -> void:
	reset_grid()


func reset_grid() -> void:
	cells.clear()
	_resource_sources.clear()
	_next_chain_index = 1
	set_selected_cell(HEART_CELL)
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			cells[Vector2i(x, y)] = ""
	place_piece(HEART_CELL, "saintmoth", true)
	grid_reset.emit()


func place_piece(cell: Vector2i, piece_id: String, allow_heart := false) -> bool:
	var error := get_placement_error(cell, piece_id, allow_heart)
	if not error.is_empty():
		placement_failed.emit(cell, piece_id, error)
		return false
	cells[cell] = piece_id
	piece_placed.emit(cell, piece_id)
	return true


func can_place_piece(cell: Vector2i, piece_id: String, allow_heart := false) -> bool:
	return get_placement_error(cell, piece_id, allow_heart).is_empty()


func get_placement_error(cell: Vector2i, piece_id: String, allow_heart := false) -> String:
	if not is_valid_cell(cell):
		return "Cell is outside the 3x3 garden"
	if cell == HEART_CELL and not allow_heart:
		return "Heart Tile is reserved for the companion"
	if not cells.get(cell, "").is_empty():
		return "Cell already has a garden piece"
	if ContentDatabase.get_garden_piece(piece_id).is_empty():
		return "Unknown garden piece id"
	return ""


func place_piece_in_first_empty_cell(piece_id: String) -> Vector2i:
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var cell := Vector2i(x, y)
			if can_place_piece(cell, piece_id) and place_piece(cell, piece_id):
				return cell
	return Vector2i(-1, -1)


func remove_piece(cell: Vector2i) -> String:
	if not is_valid_cell(cell) or cell == HEART_CELL:
		return ""
	var piece_id := str(cells.get(cell, ""))
	if piece_id.is_empty():
		return ""
	cells[cell] = ""
	piece_removed.emit(cell, piece_id)
	return piece_id


func trigger_piece(cell: Vector2i, event_name: String) -> bool:
	return GardenTriggerSystem.trigger_cell_event(cell, event_name, {})


func set_selected_cell(cell: Vector2i) -> bool:
	if not is_valid_cell(cell):
		return false
	if selected_cell == cell:
		return true
	selected_cell = cell
	selected_cell_changed.emit(selected_cell)
	return true


func select_heart_cell() -> void:
	set_selected_cell(HEART_CELL)


func move_selected_cell(offset: Vector2i) -> bool:
	var next_cell := selected_cell + offset
	next_cell.x = clampi(next_cell.x, 0, GRID_SIZE.x - 1)
	next_cell.y = clampi(next_cell.y, 0, GRID_SIZE.y - 1)
	return set_selected_cell(next_cell)


func pulse_selected() -> bool:
	return trigger_piece(selected_cell, "on_pulse")


func apply_trigger_request(cell: Vector2i, piece_id: String, trigger: Dictionary, context: Dictionary = {}) -> bool:
	if str(cells.get(cell, "")) != piece_id:
		return false
	return _apply_trigger(cell, piece_id, trigger, context)


func get_piece_at(cell: Vector2i) -> Dictionary:
	var piece_id := get_piece_id_at(cell)
	if piece_id.is_empty():
		return {}
	return ContentDatabase.get_garden_piece(piece_id)


func get_piece_id_at(cell: Vector2i) -> String:
	return str(cells.get(cell, ""))


func get_all_cells() -> Dictionary:
	return cells.duplicate()


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


func get_orthogonal_neighbors(cell: Vector2i) -> Array[Vector2i]:
	return get_neighbors(cell, false)


func get_diagonal_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for offset in [
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(1, 1),
		Vector2i(-1, 1)
	]:
		var neighbor := cell + offset
		if is_valid_cell(neighbor):
			result.append(neighbor)
	return result


func get_opposite_cell(origin_cell: Vector2i, pivot_cell: Vector2i) -> Vector2i:
	var opposite := pivot_cell + (pivot_cell - origin_cell)
	return opposite if is_valid_cell(opposite) else Vector2i(-1, -1)


func are_cells_adjacent(a: Vector2i, b: Vector2i, include_diagonal := false) -> bool:
	return get_neighbors(a, include_diagonal).has(b)


func get_adjacent_piece_cells(cell: Vector2i, include_diagonal := false) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for neighbor in get_neighbors(cell, include_diagonal):
		if not get_piece_id_at(neighbor).is_empty():
			result.append(neighbor)
	return result


func get_adjacent_piece_ids(cell: Vector2i, include_diagonal := false) -> Array[String]:
	var result: Array[String] = []
	for neighbor in get_adjacent_piece_cells(cell, include_diagonal):
		result.append(get_piece_id_at(neighbor))
	return result


func get_adjacent_cells_by_category(cell: Vector2i, category: String, include_diagonal := false) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for neighbor in get_adjacent_piece_cells(cell, include_diagonal):
		if get_piece_category_at(neighbor) == category:
			result.append(neighbor)
	return result


func get_adjacent_cells_by_tag(cell: Vector2i, tag: String, include_diagonal := false) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for neighbor in get_adjacent_piece_cells(cell, include_diagonal):
		if get_piece_tags_at(neighbor).has(tag):
			result.append(neighbor)
	return result


func get_cells_by_category(category: String) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in cells.keys():
		if get_piece_category_at(cell) == category:
			result.append(cell)
	return result


func get_cells_by_tag(tag: String) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in cells.keys():
		if get_piece_tags_at(cell).has(tag):
			result.append(cell)
	return result


func get_piece_category_at(cell: Vector2i) -> String:
	return str(get_piece_at(cell).get("category", ""))


func get_piece_tags_at(cell: Vector2i) -> Array:
	return get_piece_at(cell).get("tags", [])


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
	# Temporary bridge: keep new action mechanics in GardenEffectResolver, not here.
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
		GardenTriggerSystem.trigger_global_event(str(event_name), context)


func _make_chain_id(piece_id: String, trigger: Dictionary) -> String:
	var chain_id := "%s:%s:%s" % [piece_id, trigger.get("id", trigger.get("action", "")), _next_chain_index]
	_next_chain_index += 1
	return chain_id
