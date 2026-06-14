extends Node


func trigger_cell_event(cell: Vector2i, event_name: String, context: Dictionary = {}) -> bool:
	var piece_id := GardenManager.get_piece_id_at(cell)
	if piece_id.is_empty():
		return false
	var did_trigger := false
	for trigger in get_matching_triggers(piece_id, event_name):
		did_trigger = GardenManager.apply_trigger_request(cell, piece_id, trigger, context) or did_trigger
	return did_trigger


func trigger_global_event(event_name: String, context: Dictionary = {}) -> void:
	var cells := GardenManager.get_all_cells()
	for cell in cells.keys():
		trigger_cell_event(cell, event_name, context)


func get_matching_triggers(piece_id: String, event_name: String) -> Array:
	var matches: Array = []
	var piece := ContentDatabase.get_garden_piece(piece_id)
	for trigger in piece.get("triggers", []):
		if trigger.get("event", "") == event_name:
			matches.append(trigger)
	return matches
