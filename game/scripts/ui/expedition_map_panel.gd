extends PanelContainer

const CELL_SIZE := Vector2(84, 52)

@onready var grid := $MarginContainer/VBoxContainer/GridContainer
@onready var title := $MarginContainer/VBoxContainer/Title

var _rooms: Array[Dictionary] = []


func set_rooms(rooms: Array[Dictionary]) -> void:
	_rooms = rooms.duplicate(true)
	_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if grid == null:
		return
	for child in grid.get_children():
		child.queue_free()
	if title != null:
		title.text = "Expedition Map\nArrows select | Enter travel | Backtrack allowed"
	var bounds := _get_bounds()
	grid.columns = max(bounds.size.x, 1)
	for y in range(bounds.position.y, bounds.position.y + bounds.size.y):
		for x in range(bounds.position.x, bounds.position.x + bounds.size.x):
			_add_cell(Vector2i(x, y))


func _add_cell(position: Vector2i) -> void:
	var room := _get_room_at(position)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = CELL_SIZE
	panel.add_theme_stylebox_override("panel", _make_style(room))
	grid.add_child(panel)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.text = _get_room_text(room)
	panel.add_child(label)


func _get_room_at(position: Vector2i) -> Dictionary:
	for room in _rooms:
		if room.get("position", Vector2i.ZERO) == position:
			return room
	return {}


func _get_bounds() -> Rect2i:
	if _rooms.is_empty():
		return Rect2i(Vector2i.ZERO, Vector2i.ONE)
	var min_x := 0
	var max_x := 0
	var min_y := 0
	var max_y := 0
	for room in _rooms:
		var position: Vector2i = room.get("position", Vector2i.ZERO)
		min_x = mini(min_x, position.x)
		max_x = maxi(max_x, position.x)
		min_y = mini(min_y, position.y)
		max_y = maxi(max_y, position.y)
	return Rect2i(Vector2i(min_x, min_y), Vector2i(max_x - min_x + 1, max_y - min_y + 1))


func _get_room_text(room: Dictionary) -> String:
	if room.is_empty() or not bool(room.get("revealed", false)):
		return "?"
	var marker := ""
	if bool(room.get("is_current", false)):
		marker = "@"
	elif bool(room.get("is_selected", false)):
		marker = ">"
	elif bool(room.get("cleared", false)):
		marker = "✓"
	var room_id := str(room.get("room_id", "room"))
	return "%s\n%s" % [marker, room_id.capitalize()]


func _make_style(room: Dictionary) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	if room.is_empty() or not bool(room.get("revealed", false)):
		style.bg_color = Color(0.07, 0.08, 0.08, 0.8)
		style.border_color = Color(0.18, 0.20, 0.20, 1.0)
	elif bool(room.get("is_current", false)):
		style.bg_color = Color(0.20, 0.32, 0.22, 0.95)
		style.border_color = Color(0.58, 1.0, 0.58, 1.0)
	elif bool(room.get("is_selected", false)):
		style.bg_color = Color(0.20, 0.24, 0.34, 0.95)
		style.border_color = Color(0.46, 0.78, 1.0, 1.0)
	elif bool(room.get("cleared", false)):
		style.bg_color = Color(0.18, 0.18, 0.16, 0.95)
		style.border_color = Color(0.72, 0.68, 0.46, 1.0)
	else:
		style.bg_color = Color(0.16, 0.17, 0.20, 0.95)
		style.border_color = Color(0.38, 0.44, 0.52, 1.0)
	return style
