extends Node

signal grid_reset
signal piece_placed(cell: Vector2i, piece_id: String)
signal piece_removed(cell: Vector2i, piece_id: String)
signal piece_triggered(cell: Vector2i, piece_id: String, trigger: Dictionary)
signal placement_failed(cell: Vector2i, piece_id: String, reason: String)
signal selected_cell_changed(cell: Vector2i)

const GRID_SIZE := Vector2i(3, 3)
const HEART_CELL := Vector2i(1, 1)
const RESOLVER_ACTIONS := [
	"produce_resource",
	"grant_player_shield",
	"consume_resource",
	"store_resource",
	"damage_enemy",
	"damage_nearby_enemies",
	"spawn_helper",
	"repeat_last_trigger",
	"move_resource",
	"copy_output",
	"modify_production",
	"protect_adjacent_living",
	"connect_adjacent_flora"
]
const RESOURCE_CONSUMING_ACTIONS := [
	"grant_player_shield",
	"consume_resource",
	"store_resource",
	"spawn_helper",
	"repeat_last_trigger"
]

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
	GardenEffectResolver.reset()
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
	_dispatch_placement_passives(cell)
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
	var offsets: Array[Vector2i] = [
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(1, 1),
		Vector2i(-1, 1)
	]
	for offset in offsets:
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


func get_production_bonus_for_cell(cell: Vector2i) -> int:
	var bonus := 0
	for neighbor in get_adjacent_piece_cells(cell):
		var piece := get_piece_at(neighbor)
		for effect in piece.get("effects", []):
			if str(effect.get("action", "")) == "protect_adjacent_living":
				bonus += int(effect.get("production_bonus", 0))
	return bonus


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
	var trigger_context := _build_trigger_context(cell, piece_id, trigger, context)
	var effect_result := {}
	var succeeded := false
	if RESOLVER_ACTIONS.has(action):
		effect_result = GardenEffectResolver.resolve_effect(_build_effect_request(cell, piece_id, trigger, trigger_context))
		succeeded = bool(effect_result.get("success", false))
		if succeeded and ["produce_resource", "copy_output"].has(action) and not str(effect_result.get("resource", "")).is_empty():
			_store_resource_source_from_effect(effect_result, trigger_context)
		elif succeeded and RESOURCE_CONSUMING_ACTIONS.has(action):
			_consume_resource_source_from_effect(effect_result)
	if not succeeded:
		return false
	var previous_trigger := last_trigger.duplicate(true)
	last_trigger = {
		"cell": cell,
		"piece_id": piece_id,
		"trigger": trigger.duplicate(true)
	}
	piece_triggered.emit(cell, piece_id, trigger)
	Bloomchains.record_trigger(cell, piece_id, trigger, trigger_context)
	if action == "repeat_last_trigger":
		_repeat_last_trigger(previous_trigger, effect_result, trigger_context)
	_dispatch_follow_up_events(trigger, trigger_context)
	_dispatch_effect_events(effect_result, trigger_context)
	_dispatch_mirror_events(cell, piece_id, effect_result, trigger_context)
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
	var source := context.duplicate(true)
	var cell: Vector2i = result.get("cell", Vector2i(-1, -1))
	source["resource_id"] = resource_id
	source["amount"] = int(result.get("amount", 0))
	source["origin_cell"] = cell
	source["origin_piece_id"] = str(result.get("piece_id", ""))
	source["adjacent_cells"] = get_adjacent_piece_cells(cell)
	source["adjacent_flora_cells"] = get_adjacent_cells_by_category(cell, "flora")
	source["adjacent_fauna_cells"] = get_adjacent_cells_by_category(cell, "fauna")
	source["adjacent_object_cells"] = get_adjacent_cells_by_category(cell, "object")
	if not _resource_sources.has(resource_id):
		_resource_sources[resource_id] = []
	_resource_sources[resource_id].append(source)


func _consume_resource_source_from_effect(result: Dictionary) -> void:
	var resource_id := str(result.get("resource", ""))
	if resource_id.is_empty() or not _resource_sources.has(resource_id):
		return
	var amount := _get_resource_amount_from_result(result)
	if amount <= 0:
		return
	var remaining := amount
	var sources: Array = _resource_sources[resource_id]
	var result_context: Dictionary = result.get("context", {})
	var start_index := int(result_context.get("resource_source_index", _find_preferred_source_index(resource_id, result.get("cell", Vector2i(-1, -1)))))
	while remaining > 0 and not sources.is_empty():
		var index := clampi(start_index, 0, sources.size() - 1)
		var source: Dictionary = sources[index]
		var source_amount := int(source.get("amount", 0))
		if source_amount <= remaining:
			remaining -= source_amount
			sources.remove_at(index)
			start_index = 0
		else:
			source["amount"] = source_amount - remaining
			sources[index] = source
			remaining = 0
	if sources.is_empty():
		_resource_sources.erase(resource_id)
	else:
		_resource_sources[resource_id] = sources


func _build_trigger_context(cell: Vector2i, piece_id: String, trigger: Dictionary, context: Dictionary) -> Dictionary:
	var trigger_context := context.duplicate(true)
	var resource_id := str(trigger.get("resource", ""))
	var action := str(trigger.get("action", ""))
	if RESOURCE_CONSUMING_ACTIONS.has(action) and trigger_context.get("chain_id", "") == "" and _resource_sources.has(resource_id):
		var source_context := _peek_resource_source_context(resource_id, cell)
		if not source_context.is_empty():
			trigger_context = source_context
	if str(trigger_context.get("chain_id", "")).is_empty():
		trigger_context["chain_id"] = _make_chain_id(piece_id, trigger)
	trigger_context["source_piece_id"] = piece_id
	trigger_context["source_trigger_id"] = trigger.get("id", trigger.get("action", ""))
	return trigger_context


func _peek_resource_source_context(resource_id: String, consumer_cell := Vector2i(-1, -1)) -> Dictionary:
	var sources: Array = _resource_sources.get(resource_id, [])
	if sources.is_empty():
		return {}
	var index := _find_preferred_source_index(resource_id, consumer_cell)
	if index < 0:
		return {}
	var source: Dictionary = sources[index]
	var result := source.duplicate(true)
	result["resource_source_index"] = index
	return result


func _find_preferred_source_index(resource_id: String, consumer_cell: Vector2i) -> int:
	var sources: Array = _resource_sources.get(resource_id, [])
	if sources.is_empty():
		return -1
	if is_valid_cell(consumer_cell):
		for index in range(sources.size()):
			var source: Dictionary = sources[index]
			var origin_cell: Vector2i = source.get("origin_cell", Vector2i(-1, -1))
			if origin_cell == consumer_cell or are_cells_adjacent(origin_cell, consumer_cell):
				return index
	return 0


func _get_resource_amount_from_result(result: Dictionary) -> int:
	var cost := int(result.get("cost", 0))
	if cost > 0:
		return cost
	return int(result.get("amount", 0))


func _dispatch_follow_up_events(trigger: Dictionary, context: Dictionary) -> void:
	for event_name in trigger.get("follow_up_events", []):
		GardenTriggerSystem.trigger_global_event(str(event_name), context)


func _dispatch_placement_passives(cell: Vector2i) -> void:
	GardenTriggerSystem.trigger_cell_event(cell, "placement_passive", {"placed_cell": cell})
	for neighbor in get_adjacent_piece_cells(cell):
		GardenTriggerSystem.trigger_cell_event(neighbor, "placement_passive", {"placed_cell": cell})


func _dispatch_effect_events(effect_result: Dictionary, context: Dictionary) -> void:
	match str(effect_result.get("action", "")):
		"produce_resource", "copy_output":
			_dispatch_resource_available(effect_result, context)
		"store_resource":
			_dispatch_storage_threshold(effect_result, context)


func _dispatch_resource_available(effect_result: Dictionary, context: Dictionary) -> void:
	var resource_id := str(effect_result.get("resource", ""))
	if resource_id.is_empty():
		return
	var resource_context := context.duplicate(true)
	resource_context["resource"] = resource_id
	resource_context["amount"] = int(effect_result.get("amount", 0))
	resource_context["origin_cell"] = effect_result.get("cell", Vector2i(-1, -1))
	GardenTriggerSystem.trigger_global_event("resource_available", resource_context)
	var origin_cell: Vector2i = resource_context.get("origin_cell", Vector2i(-1, -1))
	for neighbor in get_adjacent_piece_cells(origin_cell):
		GardenTriggerSystem.trigger_cell_event(neighbor, "resource_available_adjacent", resource_context)
	for trellis_cell in get_adjacent_cells_by_tag(origin_cell, "connection"):
		for connected_cell in get_adjacent_cells_by_category(trellis_cell, "flora"):
			if connected_cell != origin_cell:
				GardenTriggerSystem.trigger_cell_event(connected_cell, "resource_available_adjacent", resource_context)


func _dispatch_storage_threshold(effect_result: Dictionary, context: Dictionary) -> void:
	var capacity := int(effect_result.get("capacity", 0))
	var stored := int(effect_result.get("stored", 0))
	if capacity <= 0 or stored < capacity:
		return
	var storage_context := context.duplicate(true)
	storage_context["resource"] = str(effect_result.get("resource", ""))
	storage_context["stored"] = stored
	storage_context["threshold"] = capacity
	var cell: Vector2i = effect_result.get("cell", Vector2i(-1, -1))
	GardenTriggerSystem.trigger_cell_event(cell, "stored_resource_threshold", storage_context)
	GardenEffectResolver.clear_stored_amount(cell, str(effect_result.get("piece_id", "")), str(effect_result.get("resource", "")))


func _dispatch_mirror_events(source_cell: Vector2i, source_piece_id: String, effect_result: Dictionary, context: Dictionary) -> void:
	if source_piece_id == "mirror_shard":
		return
	var mirror_context := context.duplicate(true)
	mirror_context["copied_source_cell"] = source_cell
	for output in effect_result.get("outputs", []):
		match str(output.get("type", "")):
			"resource":
				mirror_context["copied_resource"] = str(output.get("resource", ""))
				mirror_context["copied_amount"] = int(output.get("amount", 0))
			"enemy_damage":
				mirror_context["copied_enemy_damage"] = int(output.get("amount", 0))
	if not mirror_context.has("copied_resource") and not mirror_context.has("copied_enemy_damage"):
		return
	for mirror_cell in get_cells_by_tag("copy"):
		var opposite := Vector2i(GRID_SIZE.x - 1 - mirror_cell.x, GRID_SIZE.y - 1 - mirror_cell.y)
		if opposite == source_cell:
			GardenTriggerSystem.trigger_cell_event(mirror_cell, "opposite_tile_triggered", mirror_context)


func _repeat_last_trigger(previous_trigger: Dictionary, effect_result: Dictionary, context: Dictionary) -> void:
	if int(context.get("repeat_depth", 0)) > 0:
		return
	if previous_trigger.is_empty():
		return
	var source_trigger: Dictionary = previous_trigger.get("trigger", {})
	if str(source_trigger.get("action", "")) == "repeat_last_trigger":
		return
	var source_cell: Vector2i = previous_trigger.get("cell", Vector2i(-1, -1))
	var source_piece_id := str(previous_trigger.get("piece_id", ""))
	if not is_valid_cell(source_cell) or get_piece_id_at(source_cell) != source_piece_id:
		return
	var repeated_trigger := source_trigger.duplicate(true)
	repeated_trigger["id"] = "%s_repeat" % source_trigger.get("id", source_trigger.get("action", "trigger"))
	if repeated_trigger.has("amount"):
		var scalar := float(effect_result.get("scalar", 1.0))
		repeated_trigger["amount"] = maxi(1, int(floor(float(repeated_trigger["amount"]) * scalar)))
	repeated_trigger["follow_up_events"] = []
	var repeat_context := context.duplicate(true)
	repeat_context["repeat_depth"] = int(repeat_context.get("repeat_depth", 0)) + 1
	apply_trigger_request(source_cell, source_piece_id, repeated_trigger, repeat_context)


func _make_chain_id(piece_id: String, trigger: Dictionary) -> String:
	var chain_id := "%s:%s:%s" % [piece_id, trigger.get("id", trigger.get("action", "")), _next_chain_index]
	_next_chain_index += 1
	return chain_id
