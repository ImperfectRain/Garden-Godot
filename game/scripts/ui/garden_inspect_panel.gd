extends PanelContainer

@onready var title: Label = $MarginContainer/VBoxContainer/Title
@onready var body: RichTextLabel = $MarginContainer/VBoxContainer/Body

var inspected_cell := Vector2i.ZERO


func _ready() -> void:
	visible = false
	GardenManager.selected_cell_changed.connect(set_inspected_cell)
	GardenManager.piece_placed.connect(_on_grid_changed)
	GardenManager.piece_removed.connect(_on_grid_changed)


func set_inspected_cell(cell: Vector2i) -> void:
	inspected_cell = cell
	refresh()


func refresh() -> void:
	if title == null or body == null:
		return
	var piece_id := GardenManager.get_piece_id_at(inspected_cell)
	if piece_id.is_empty():
		title.text = "Garden Cell %s,%s" % [inspected_cell.x, inspected_cell.y]
		body.text = "Empty cell.\n\nUse reward placement to add a Flora, Fauna, or Object here."
		return
	var piece := ContentDatabase.get_garden_piece(piece_id)
	var lines: Array[String] = []
	title.text = "%s (%s)" % [piece.get("name", piece_id), _get_cell_role(piece)]
	lines.append(str(piece.get("simple_description", "")))
	lines.append("")
	lines.append(str(piece.get("detail_description", "")))
	lines.append("")
	lines.append("Tags: %s" % _join_values(piece.get("tags", [])))
	lines.append("Likes: %s" % _join_values(piece.get("likes", [])))
	lines.append("Synergies: %s" % _join_values(piece.get("synergies", [])))
	lines.append("")
	lines.append("Triggers:")
	lines.append_array(_get_trigger_lines(piece))
	lines.append_array(_get_storage_lines(piece_id, piece))
	body.text = "\n".join(PackedStringArray(lines))


func _get_cell_role(piece: Dictionary) -> String:
	if inspected_cell == GardenManager.HEART_CELL:
		return "Heart"
	return str(piece.get("category", "unknown")).capitalize()


func _get_trigger_lines(piece: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var triggers: Array = piece.get("triggers", [])
	for trigger_data in triggers:
		var trigger: Dictionary = trigger_data
		var parts: Array[String] = [
			str(trigger.get("event", "?")),
			str(trigger.get("action", "?"))
		]
		var resource := str(trigger.get("resource", ""))
		if not resource.is_empty():
			parts.append(resource)
		if trigger.has("amount"):
			parts.append("amount %s" % int(trigger.get("amount", 0)))
		if trigger.has("cost"):
			parts.append("cost %s" % int(trigger.get("cost", 0)))
		if trigger.has("cooldown"):
			parts.append("%.1fs" % float(trigger.get("cooldown", 0.0)))
		if trigger.has("capacity"):
			parts.append("cap %s" % int(trigger.get("capacity", 0)))
		lines.append("- %s" % " | ".join(PackedStringArray(parts)))
	if lines.is_empty():
		lines.append("- None")
	return lines


func _get_storage_lines(piece_id: String, piece: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var stores: Array = piece.get("stores", [])
	for store_data in stores:
		var store: Dictionary = store_data
		var resource := str(store.get("resource", ""))
		if resource.is_empty():
			continue
		var capacity := int(store.get("capacity", 0))
		var stored := GardenEffectResolver.get_stored_amount(inspected_cell, piece_id, resource)
		lines.append("Stored %s: %s/%s" % [resource, stored, capacity])
	return lines


func _join_values(values: Array) -> String:
	if values.is_empty():
		return "None"
	var strings: Array[String] = []
	for value in values:
		strings.append(str(value))
	return ", ".join(PackedStringArray(strings))


func _on_grid_changed(_cell: Vector2i, _piece_id: String) -> void:
	refresh()
